package main

import (
	"context"
	"database/sql"
	"flag"
	"fmt"
	"os"
	"os/signal"
	"strings"
	"sync"
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

	var numProducers = flag.Int("num-producers", 10, "number of producer go routines to use")
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

	// Add file and line number to loghttps://github.com/rs/zerolog#add-file-and-line-number-to-log
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

	if *numProducers < 1 {
		logger.Fatal().Int("num-producers", *numProducers).Msg("cannot run with -num-producers < 1")
	}
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
	// Limit the number of active goroutines
	// One additional for the shutdown handler
	g.SetLimit(*numProducers + *numConsumers + 1)

	producersLeftToProcess := int32(len(allBuildersResp.Builders))
	consumersLeftToProcess := int32(*numConsumers)

	batchSize := 10

	// When a build is ready, we send it to this buffered channel to have it
	// consumed for insertion
	buildChan := make(chan buildbot.Build, batchSize)

	var numStoredBuildLogs int32 = 0

	// Graceful shutdown handler
	g.Go(func() error {
		logger.Debug().Msg("starting signal handler")
		defer logger.Debug().Msg("exiting signal handler")

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
			// default:
			// 	if producersLeftToProcess == 0 || consumersLeftToProcess == 0 {
			// 		logger.Debug().Msg("XXXXXX XXXX XXXX stopping grace handler")
			// 		done()
			// 		return nil
			// 	}
		}

		if producersLeftToProcess == 0 /*int32(*numProducers)*/ {
			logger.Warn().Msgf("all %d producers have finished", *numProducers)
			done()
		} else {
			logger.Warn().Int32("producersLeftToProcess", producersLeftToProcess).Msg("not all builders finished")
		}

		return nil
	})

	// Consumers
	for i := 0; i < *numConsumers; i++ {
		consumerNo := i + 1
		g.Go(func() error {
			logger.Debug().Msgf("starting build consumer no %d/%d", consumerNo, *numConsumers)
			defer func() {
				// Last one out closes shop
				logger.Debug().Msgf("decreasing consumersLeftToProcess: %d", consumersLeftToProcess)
				if atomic.AddInt32(&consumersLeftToProcess, -1) == 0 {
					logger.Info().Msg("all consumers done")
				}
				logger.Debug().Msgf("done decreasing consumersLeftToProcess: %d", producersLeftToProcess)
			}()

			defer logger.Debug().Msgf("exiting build consumer %d/%d", consumerNo, *numConsumers)
			for {
				_startTime := time.Now()
				var ok bool
				var build buildbot.Build

				select {
				case <-gctx.Done():
					logger.Debug().Msgf("consumer %d: context is done", consumerNo)
					return errors.WithStack(gctx.Err())
				case build, ok = <-buildChan:
					if !ok {
						logger.Debug().Msgf("build channel is closed. stopping consumer %d", consumerNo)
						return nil
					}

					builder, err := b.GetBuilderById(build.Builderid)
					if err != nil {
						logger.Err(err).Int("builderId", build.Buildid).Msg("failed to get builder")
						return errors.WithStack(err)
					}
					err = b.InsertOrUpdateBuildLogs(*builder, build)
					logger.Err(err).
						Int("consumerNo", consumerNo).
						Int("builderId", builder.Builderid).
						Str("builderName", builder.Name).
						Int("buildId", build.Buildid).
						Int("buildNumber", build.Number).
						Msgf("insert/update build log in %s", time.Since(_startTime))
					if err != nil {
						return errors.WithStack(err)
					}
					atomic.AddInt32(&numStoredBuildLogs, 1)
				default:
				}
			}
		})
	}

	// Idea:
	// 1. Stop just one builder if we run into a HTTP 504 timeout. Let the others continue.
	// 2. Collect data about inserts/updates and cancelled builders in the end.

	// TODO(kwk): Have two log targets, one JSON file and one console writer

	finishedBuilderIds := []int{}
	finishedBuilderIdsLock := sync.RWMutex{}
	canceledBuilderStatusMap := map[string]error{} // builderName -> error why canceled
	canceledBuilderIdsLock := sync.RWMutex{}

	// Producers
	for idx, builder := range allBuildersResp.Builders {
		myBuilder := builder
		// TODO(kwk): Remove this if when going into production
		// if idx >= *numProducers {
		// 	break
		// }
		_ = idx
		g.Go(func() error {
			logger.Debug().Str("builderName", myBuilder.Name).Msgf("starting build producer")
			defer func() {
				// Last one out closes shop
				logger.Debug().Msgf("decreasing producersLeftToProcess: %d", producersLeftToProcess)
				if atomic.AddInt32(&producersLeftToProcess, -1) == 0 {
					logger.Info().Msg("all producers done")
					logger.Debug().Msg("closing buildChan")
					close(buildChan)
				}
				logger.Debug().Msgf("done decreasing producersLeftToProcess: %d", producersLeftToProcess)
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
				build := buildResp.Builds[i]
				select {
				case <-gctx.Done():
					logger.Debug().Msg("producer: context is done")
					return errors.WithStack(gctx.Err())
				default:
				}
				logger.Debug().
					Int("buildId", build.Buildid).
					Msgf("getting changes for %d/%d builds", i+1, numBuilds)
				changesResp, err := b.GetChangesForBuild(build.Buildid)
				if err != nil {
					logger.Err(err).
						Int("buildId", build.Buildid).
						Stack().
						Msg("failed to get changes for build")
					defer canceledBuilderIdsLock.Unlock()
					canceledBuilderStatusMap[myBuilder.Name] = errors.WithStack(err)
					return errors.WithStack(err)
				}
				if changesResp != nil {
					build.Changes = changesResp.Changes
				} else {
					logger.Warn().
						Int("buildId", build.Buildid).
						Str("builderName", myBuilder.Name).
						Int("builderId", myBuilder.Builderid).
						Msg("something went wrong when getting changes for build. cancelling collection of logs for builder")
					// Store in cancelled builder array
					canceledBuilderIdsLock.Lock()
					defer canceledBuilderIdsLock.Unlock()
					canceledBuilderStatusMap[myBuilder.Name] = errors.Errorf("something went wrong")
					return nil
				}

				logger.Debug().Msg("sending build to channel")
				select {
				case <-gctx.Done():
					logger.Debug().Msg("producer: context is done")
					return errors.WithStack(gctx.Err())
				case buildChan <- build:
					logger.Debug().Msg("done sending build to channel")
				default:
				}
			}
			// Store in completed builder array
			finishedBuilderIdsLock.Lock()
			defer finishedBuilderIdsLock.Unlock()
			finishedBuilderIds = append(finishedBuilderIds, myBuilder.Builderid)
			return nil
		})
	}

	// Wait for all errgroup goroutines
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

	// Print summary
	logger.Info().MsgFunc(func() string {
		doneDuration := time.Since(startTime)
		averageStoreDuration := time.Duration(int64(float64(doneDuration) / float64(numStoredBuildLogs)))
		estimateDuration := 2500000 * averageStoreDuration
		// TODO(kwk): Fix time
		d := estimateDuration / (time.Hour * 24)
		h := (estimateDuration - d*time.Hour) / time.Hour
		m := (estimateDuration - h*time.Hour) / time.Minute
		s := (estimateDuration - m*time.Minute) / time.Second

		res := "\nSummary\n"
		res += "-------\n"
		res += fmt.Sprintf("Elapsed time                            : %s\n", doneDuration)
		res += fmt.Sprintf("Avg store time                          : %s\n", averageStoreDuration)
		res += fmt.Sprintf("Estimated time for 2,500,000 log entries: %d day(s) %d hour(s) %d minute(s) %d second(s)\n", d, h, m, s)
		res += fmt.Sprintf("Estimated time for 2,500,000 log entries: %s\n", averageStoreDuration*2500000)
		res += fmt.Sprintf("Total stored log entries                : %d\n", numStoredBuildLogs)
		res += fmt.Sprintf("Total builders                          : %d\n", len(allBuildersResp.Builders))
		res += fmt.Sprintf("Total finished builders                 : %d\n", len(finishedBuilderIds))
		res += fmt.Sprintf("Total canceled builders                 : %d\n", len(canceledBuilderStatusMap))
		res += fmt.Sprintf("Canceled builder names                  : \n%s\n", func() string {
			res := make([]string, len(canceledBuilderStatusMap))
			i := 0
			for builderName, err := range canceledBuilderStatusMap {
				res[i] = fmt.Sprintf(" * %40s: %#v", builderName, err)
				i++
			}
			return strings.Join(res, "\n")
		}())
		return res
	})
}
