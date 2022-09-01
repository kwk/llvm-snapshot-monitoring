package main

import (
	"context"
	"database/sql"
	"flag"
	"fmt"
	"os"
	"sync"
	"time"

	"buildbot-go/buildbot"

	_ "github.com/lib/pq"
	"github.com/pkg/errors"
	"github.com/rs/zerolog"
	"golang.org/x/sync/errgroup"
)

// commonData holds information used by consumers and producers
type commonData struct {
	ctx           context.Context
	ctxCancelFunc context.CancelFunc
	logger        zerolog.Logger
	b             *buildbot.Buildbot
	buildChan     chan buildbot.Build
}

func main() {
	var err error
	startTime := time.Now()

	// Flags
	// -----

	var dbHost = flag.String("db-host", "0.0.0.0", "the postgres host")
	var dbPort = flag.Int("db-port", 5433, "the postgres port")
	var dbUser = flag.String("db-user", "postgres", "the postgres username")
	var dbPass = flag.String("db-pass", "postgres_password", "the postgres password")
	var dbName = flag.String("db-name", "logs", "the postgres database name")

	var buildbotInstance = flag.String("buildbot-instance", "staging", "the instance (staging or buildbot) to use")
	var buildbotApiBase = flag.String("buildbot-api-base", "https://lab.llvm.org/staging/api/v2", "the HTTP API base URL")

	var numProducers = flag.Int("num-producers", 0, "number of producer go routines to use leave at 0 to get as many producers as there are buildbot builders")
	var numConsumers = flag.Int("num-consumers", 10, "number of consumer go routines to use")

	var logLevelFlag = flag.String("log-level", "info", "sets log level (e.g. info, debug, warn)")
	var logJson = flag.Bool("log-json", false, "outputs logs as JSON")

	flag.Parse()

	fmt.Printf("Running with these settings:\n")
	fmt.Printf("----------------------------\n")
	flag.VisitAll(func(f *flag.Flag) {
		// avoid outputting sensitive information
		val := f.Value.String()
		if f.Name == "db-pass" {
			val = "******HIDDEN-SECRET*******"
		}
		fmt.Printf("%s: %s (%s)\n", f.Name, val, f.Usage)
	})

	// Setup Logging
	// -------------

	logger := zerolog.New(os.Stderr).With().Timestamp().Logger()

	// Add file and line number to log https://github.com/rs/zerolog#add-file-and-line-number-to-log
	logger = logger.With().Caller().Logger()

	if !*logJson {
		logger = logger.Output(zerolog.ConsoleWriter{Out: os.Stderr, TimeFormat: time.RFC3339})
	}

	// Default level for this example is info, unless debug flag is present
	logLevel, err := zerolog.ParseLevel(*logLevelFlag)
	if err != nil {
		logger.Fatal().Err(err).Str("log-level", *logLevelFlag).Msg("failed to set log level")
	}
	zerolog.SetGlobalLevel(logLevel)

	// Validate CLI arguments
	// ----------------------

	if *numConsumers < 1 {
		logger.Fatal().Int("num-consumers", *numConsumers).Msg("cannot run with -num-consumers < 1")
	}

	// Connect to Database
	// -------------------

	dsn := fmt.Sprintf(
		"host=%s port=%d user=%s password=%s dbname=%s sslmode=disable",
		*dbHost, *dbPort, *dbUser, *dbPass, *dbName)
	db, err := sql.Open("postgres", dsn)
	if err != nil {
		// This will not be a connection error, but a DSN parse error or
		// another initialization error.
		logger.Fatal().AnErr("error", err).Msg("unable to initialize postgres")
	}
	defer db.Close()

	// By calling db.Ping() we force our code to actually open up a connection
	// to the database which will validate whether or not our connection string
	// was 100% correct.
	err = db.Ping()
	if err != nil {
		logger.Fatal().AnErr("error", err).Msg("failed to ping database")
	}

	// Begin processing
	// ----------------

	b, err := buildbot.New(
		*buildbotInstance,
		*buildbotApiBase,
		db,
		logger.
			With().
			Str("is", "buildbot").
			Str("buildbotInstance", *buildbotInstance).
			Str("buildbotApiBase", *buildbotApiBase).
			Logger())
	if err != nil {
		logger.Fatal().AnErr("error", err).Msg("failed to construct main buildbot object")
	}

	allBuildersResp, err := b.GetAllBuilders()
	if err != nil {
		logger.Fatal().AnErr("error", err).Msg("failed to get all builders")
	}

	if *numProducers <= 0 {
		*numProducers = len(allBuildersResp.Builders)
	}

	ctx, ctxCancelFunc := context.WithCancel(context.Background())
	g, gctx := errgroup.WithContext(ctx)
	// Limit the number of active goroutines
	// One additional for the shutdown handler
	g.SetLimit(*numProducers + *numConsumers + 1)

	producersLeftToProcess := int32(*numProducers)
	consumersLeftToProcess := int32(*numConsumers)

	logger = logger.Hook(zerolog.HookFunc(
		func(e *zerolog.Event, l zerolog.Level, msg string) {
			e.Int32("producersLeftToProcess", producersLeftToProcess).
				Int32("consumersLeftToProcess", consumersLeftToProcess)
		}))

	batchSize := 10

	// When a build is ready, we send it to this buffered channel to have it
	// consumed for insertion
	buildChan := make(chan buildbot.Build, batchSize)

	// This stores the total log entries that were stored. Use atomic.AddInt32
	// on it only to make it usable concurrently.
	var numStoredBuildLogs int32 = 0

	// shared data between producers and consumers
	sharedData := commonData{
		ctx:           gctx,
		logger:        logger,
		b:             b,
		ctxCancelFunc: ctxCancelFunc,
		buildChan:     buildChan,
	}

	// Graceful shutdown handler
	// -------------------------

	d := gracefulShutdownData{
		commonData:             sharedData,
		producersLeftToProcess: &producersLeftToProcess,
		consumersLeftToProcess: &consumersLeftToProcess,
	}
	d.logger = d.logger.
		With().
		Str("is", "shutdownHandler").
		Logger()
	g.Go(makeGracefulShutdown(d))

	// Consumers
	// ---------

	for i := 0; i < *numConsumers; i++ {
		d := consumerData{
			commonData:             sharedData,
			numStoredBuildLogs:     &numStoredBuildLogs,
			consumersLeftToProcess: &consumersLeftToProcess,
			consumerNo:             i + 1,
		}
		d.logger = d.logger.
			With().
			Str("is", "consumer").
			Int("consumerNo", d.consumerNo).
			Logger()
		g.Go(makeConsumer(d))
	}

	// Producers
	// ---------

	finishedBuilderIds := []int{}
	finishedBuilderIdsLock := sync.RWMutex{}
	canceledBuilderStatusMap := map[string]error{} // builderName -> error why canceled
	canceledBuilderIdsLock := sync.RWMutex{}

	for i := 0; i < *numProducers; i++ {
		builder := allBuildersResp.Builders[i]
		d := producerData{
			commonData:               sharedData,
			producersLeftToProcess:   &producersLeftToProcess,
			finishedBuilderIds:       finishedBuilderIds,
			canceledBuilderStatusMap: canceledBuilderStatusMap,
			finishedBuilderIdsLock:   &finishedBuilderIdsLock,
			canceledBuilderIdsLock:   &canceledBuilderIdsLock,
			producerNo:               i + 1,
			builder:                  builder,
		}
		d.logger = d.logger.
			With().
			Str("is", "producer").
			Int("producerNo", d.producerNo).
			Str("builderName", d.builder.Name).
			Int("builderId", d.builder.Builderid).
			Logger()
		g.Go(makeProducer(d))
	}

	// Wait for all errgroup goroutines
	// --------------------------------

	if err := g.Wait(); err != nil {
		//close(buildChan) // HOW TO AVOID panic: close of closed channel
		if errors.Is(err, context.Canceled) {
			logger.Warn().AnErr("error", err).Stack().Msg("context was canceled")
		} else {
			logger.Error().AnErr("error", err).Stack().Msg("got an error")
		}
	} else {
		logger.Info().Stack().Msg("clean finish")
	}

	// Build summary
	// -------------

	s := summaryData{
		commonData:               sharedData,
		startTime:                startTime,
		numStoredBuildLogs:       numStoredBuildLogs,
		totalBuilders:            len(allBuildersResp.Builders),
		finishedBuilderIds:       finishedBuilderIds,
		canceledBuilderStatusMap: canceledBuilderStatusMap,
	}
	d.logger = d.logger.
		With().
		Str("is", "summary").
		Logger()
	printSummary(s)
}
