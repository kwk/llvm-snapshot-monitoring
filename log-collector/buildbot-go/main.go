package main

import (
	"context"
	"database/sql"
	"flag"
	"fmt"
	"os"
	"os/signal"
	"strings"
	"sync/atomic"
	"syscall"
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

	var logLevel = flag.String("log-level", "info", "sets log level")
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
	switch *logLevel {
	case "debug":
		zerolog.SetGlobalLevel(zerolog.DebugLevel)
	case "warn":
		zerolog.SetGlobalLevel(zerolog.WarnLevel)
	case "info":
		zerolog.SetGlobalLevel(zerolog.InfoLevel)
	}

	if !*logJson {
		logger = logger.Output(zerolog.ConsoleWriter{Out: os.Stderr, TimeFormat: time.RFC3339})
	}

	// Validate CLI arguments
	// ----------------------

	if *numGoRoutines < 3 {
		logger.Fatal().Msg("cannot run with -num-go-routines < 3")
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

	ctx, done := context.WithCancel(context.Background())
	g, gctx := errgroup.WithContext(ctx)
	// Limit the number of active goroutines.
	g.SetLimit(*numGoRoutines)

	// Graceful shutdown handler
	g.Go(func() error {
		logger.Debug().Msg("starting signal handler")
		defer logger.Debug().Msg("existing signal handler")

		signalChannel := make(chan os.Signal, 1)
		signal.Notify(signalChannel, os.Interrupt, syscall.SIGTERM)

		select {
		case sig := <-signalChannel:
			str := fmt.Sprintf("caught signal: %s. gracefully shutting down", sig.String())
			border := strings.Repeat("-", len(str))
			fmt.Fprintf(os.Stderr, "\n%s\n%s\n%s\n\n", border, str, border)
			logger.Warn().Str("signal", sig.String()).Msg("received signal")
			done()
		case <-gctx.Done():
			logger.Warn().Msg("closing signal go routine")
			return gctx.Err()
		}

		return nil
	})

	batchSize := 300

	// When a build is ready, we send it to this buffered channel to have it
	// consumed for insertion
	buildChan := make(chan buildbot.Build, batchSize)

	// Consumer
	g.Go(func() error {
		logger.Debug().Msg("starting build consumer")
		defer logger.Debug().Msg("existing build consumer")
		for {
			select {
			case <-gctx.Done():
				logger.Debug().Msg("context is done")
				return errors.WithStack(gctx.Err())
			case build, ok := <-buildChan:
				logger.Debug().Msgf("XXXX got build: %d", ok)
				if ok {
					builder, err := b.GetBuilderById(build.Builderid)
					if err != nil {
						logger.Err(err).Int("builderId", build.Buildid).Msg("failed to get builder")
						return errors.WithStack(err)
					}
					err = b.InsertOrUpdateBuildLogs(*builder, build)
					logger.Err(err).
						Int("builderId", builder.Builderid).
						Str("builderName", builder.Name).
						Int("buildId", build.Buildid).
						Msg("insert/update build log")
					if err != nil {
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
			logger.Debug().Str("builderName", myBuilder.Name).Msgf("starting build producer")
			defer logger.Debug().Str("builderName", myBuilder.Name).Msgf("exiting build producer")
			defer func() {
				// Last one out closes shop
				logger.Debug().Msgf("decreasing buildersLeftToProcess: %d", buildersLeftToProcess)
				if atomic.AddInt32(&buildersLeftToProcess, -1) == 0 {
					logger.Debug().Msg("closing buildChan")
					close(buildChan)
				}
				logger.Debug().Msgf("done decreasing buildersLeftToProcess: %d", buildersLeftToProcess)
			}()
			logger.Debug().Int("builderId", myBuilder.Builderid).Msg("processing builder")
			lastBuildNumber, err := b.GetBuildersLastBuildNumber(myBuilder.Builderid)
			if err != nil {
				return errors.WithStack(err)
			}
			buildResp, err := b.GetBuildsForBuilder(myBuilder.Builderid, lastBuildNumber, batchSize)
			if err != nil {
				return errors.WithStack(err)
			}
			// augment builds with change information
			numBuilds := len(buildResp.Builds)
			for i := 0; i < numBuilds; i++ {
				select {
				case <-gctx.Done():
					logger.Debug().Msg("context is done")
					return errors.WithStack(gctx.Err())
				default:
				}
				logger.Debug().
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

	// wait for all errgroup goroutines
	if err := g.Wait(); err != nil {
		if errors.Is(err, context.Canceled) {
			logger.Warn().AnErr("error", err).Stack().Msg("context was canceled")
		} else {
			logger.Error().AnErr("error", err).Stack().Msg("got an error")
		}
	} else {
		logger.Info().Stack().Msg("clean finish")
	}
}
