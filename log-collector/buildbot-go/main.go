package main

import (
	"database/sql"
	"flag"
	"fmt"
	"os"
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

	var debug = flag.Bool("debug", false, "sets log level to debug")
	var logJson = flag.Bool("log-json", false, "outputs logs as JSON")

	flag.Parse()

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

	g := new(errgroup.Group)
	g.SetLimit(10) // limit the number of active goroutines

	for _, builder := range allBuildersResp.Builders {
		myBuilder := builder
		g.Go(func() error {
			lastBuildNumber, _ := b.GetBuildersLastBuildNumber(myBuilder.Builderid)
			batchSize := 100 // -1 means infinity
			buildResp, _ := b.GetBuildsForBuilder(myBuilder.Builderid, lastBuildNumber, batchSize)
			// augment builds with change information
			for i := 0; i < len(buildResp.Builds); i++ {
				changesResp, err := b.GetChangesForBuild(buildResp.Builds[i].Buildid)
				if err != nil {
					logger.Err(err).
						Int("buildId", buildResp.Builds[i].Buildid).
						Msg("failed to get changes for build")
					return errors.WithStack(err)
				}
				buildResp.Builds[i].Changes = changesResp.Changes
			}
			// insert builds into log DB
			err = b.InsertOrUpdateBuildLogs(myBuilder, buildResp.Builds...)
			if err != nil {
				logger.Err(err).
					Int("num_total_builds", buildResp.Meta.Total).
					Int("num_builds_in_batch", len(buildResp.Builds)).
					Int("builderId", myBuilder.Builderid).
					Int("batchSize", batchSize).
					Msg("failed to insert/update build log")
				return errors.WithStack(err)
			}
			return nil
		})
	}

	if err := g.Wait(); err != nil {
		logger.Fatal().AnErr("error", err).Stack().Msg("and error occured")
	}
}
