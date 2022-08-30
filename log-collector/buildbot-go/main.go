package main

import (
	"context"
	"database/sql"
	"flag"
	"fmt"
	"os"
	"os/signal"
	"sync/atomic"
	"time"

	"buildbot-go/buildbot"

	_ "github.com/lib/pq"
	"github.com/pkg/errors"
	"github.com/rs/zerolog"
	"golang.org/x/sync/errgroup"
)

func main() {
	var err error

	// Flags
	// -----

	var dbHost = flag.String("db-host", "0.0.0.0", "the postgres host")
	var dbPort = flag.Int("db-port", 5433, "the postgres port")
	var dbUser = flag.String("db-user", "postgres", "the postgres username")
	var dbPass = flag.String("db-pass", "postgres_password", "the postgres password")
	var dbName = flag.String("db-name", "logs", "the postgres database name")

	var buildbotInstance = flag.String("buildbot-instance", "staging", "the instance (staging or buildbot) to use")
	var buildbotApiBase = flag.String("buildbot-api-base", "https://lab.llvm.org/staging/api/v2", "the HTTP API base URL")

	var numGoRoutines = flag.Int("num-go-routines", 10, "number of go routines to use")

	var debug = flag.Bool("debug", false, "sets log level to debug")
	var logJson = flag.Bool("log-json", false, "outputs logs as JSON")

	flag.Parse()

	fmt.Printf("Running with these settings:\n")
	fmt.Printf("----------------------------\n")
	flag.VisitAll(func(f *flag.Flag) {
		if f.Name != "db-pass" {
			fmt.Printf("%s: %s\n", f.Name, f.Value.String())
		}
	})

	// Setup Logging
	// -------------

	logger := zerolog.New(os.Stderr).With().Timestamp().Logger()

	// Add file and line number to loghttps://github.com/rs/zerolog#add-file-and-line-number-to-log
	logger = logger.With().Caller().Logger()

	// Default level for this example is info, unless debug flag is present
	zerolog.SetGlobalLevel(zerolog.InfoLevel)
	if *debug {
		zerolog.SetGlobalLevel(zerolog.DebugLevel)
	}

	if !*logJson {
		logger = logger.Output(zerolog.ConsoleWriter{Out: os.Stderr, TimeFormat: time.RFC3339})
	}

	// Validate CLI arguments
	// ----------------------

	if *numGoRoutines < 2 {
		logger.Fatal().Msg("cannot run with -num-go-routines < 2")
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
		logger.Fatal().AnErr("error", err).Msg("failed to ping postgres")
	}

	// Begin processing
	// ----------------

	b, err := buildbot.New(*buildbotInstance, *buildbotApiBase, db, logger)
	if err != nil {
		logger.Fatal().AnErr("error", err).Msg("failed to construct main buildbot object")
	}

	allBuildersResp, err := b.GetAllBuilders()
	if err != nil {
		logger.Fatal().AnErr("error", err).Msg("failed to get all builders")
	}

	// Setup ctr+c exit handler
	c := make(chan os.Signal, 1)
	signal.Notify(c, os.Interrupt)
	go func() {
		for sig := range c {
			logger.Warn().Str("signal", sig.String()).Msg("caught interrupt exiting")
			os.Exit(0)
			// sig is a ^C, handle it
		}
	}()

	g, ctx := errgroup.WithContext(context.Background())
	g.SetLimit(*numGoRoutines) // limit the number of active goroutines

	batchSize := 10

	// When a build is ready, we send it to this buffered channel to have it
	// consumed for insertion
	buildChan := make(chan buildbot.Build, batchSize)

	// Consumer
	g.Go(func() error {
		logger.Debug().Msg("starting insertRoutine")
		for {
			select {
			case <-ctx.Done():
				logger.Debug().Msg("context is done")
				return errors.WithStack(ctx.Err())
			case build, ok := <-buildChan:
				logger.Debug().Msgf("XXXX got build: %d", ok)
				if ok {
					builder, err := b.GetBuilderById(build.Builderid)
					if err != nil {
						logger.Err(err).Int("builderId", build.Buildid).Msg("failed to get builder")
						return errors.WithStack(err)
					}
					err = b.InsertOrUpdateBuildLogs(*builder, build)
					if err != nil {
						logger.Err(err).
							Int("builderId", builder.Builderid).
							Msg("failed to insert/update build log")
						return errors.WithStack(err)

					}
				}
			}
		}
	})

	// Producers
	buildersLeftToProcess := int32(len(allBuildersResp.Builders))
	for _, builder := range allBuildersResp.Builders {
		myBuilder := builder

		g.Go(func() error {
			defer func() {
				// Last one out closes shop
				if atomic.AddInt32(&buildersLeftToProcess, -1) == 0 {
					close(buildChan)
				}
			}()
			logger.Debug().Int("builderId", myBuilder.Builderid).Msg("processing builder")
			lastBuildNumber, _ := b.GetBuildersLastBuildNumber(myBuilder.Builderid)
			buildResp, _ := b.GetBuildsForBuilder(myBuilder.Builderid, lastBuildNumber, batchSize)
			// augment builds with change information
			numBuilds := len(buildResp.Builds)
			for i := 0; i < numBuilds; i++ {
				logger.Info().
					Int("buildId", buildResp.Builds[i].Buildid).
					Msgf("getting changes for %d/%d builds", i+1, numBuilds)
				changesResp, err := b.GetChangesForBuild(buildResp.Builds[i].Buildid)
				if err != nil {
					logger.Err(err).
						Int("buildId", buildResp.Builds[i].Buildid).
						Stack().
						Msg("failed to get changes for build")
					return errors.WithStack(err)
				}
				buildResp.Builds[i].Changes = changesResp.Changes

				logger.Debug().Msg("sending build to channel")
				buildChan <- buildResp.Builds[i]
				logger.Debug().Msg("done sending build to channel")
			}
			return nil
		})
	}

	if err := g.Wait(); err != nil {
		logger.Fatal().AnErr("error", err).Stack().Msg("and error occured")
	}
}
