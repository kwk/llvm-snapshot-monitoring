package main

import (
	"database/sql"
	"encoding/json"
	"flag"
	"fmt"
	"os"
	"time"

	"buildbot-go/buildbot"

	_ "github.com/lib/pq"
	"github.com/rs/zerolog"
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

	bp := buildbot.BuildProperties{}
	j, err := json.MarshalIndent(bp, "  ", "  ")
	if err != nil {
		panic(nil)
	}
	fmt.Println(string(j))

	// Setup Logging
	// -------------

	logger := zerolog.New(os.Stderr).With().Timestamp().Logger()

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
		panic(err)
	}

	// builderName := "standalone-build-x86_64"
	// builder, _ := b.GetBuilderByName(builderName)
	// lastBuildNumber, _ := b.GetBuildersLastBuildNumber(builder.Builderid)
	// batchSize := 1
	// buildResp, _ := b.GetBuildsForBuilder(builder.Builderid, lastBuildNumber, batchSize)
	// fmt.Println(PrettyPrint(buildResp))
	// for _, build := range buildResp.Builds {
	// 	err = b.InsertOrUpdateBuildLog(*builder, build)
	// 	logger.Err(err).Msg("inserting or updating build log")
	// }

	allBuildersResp, err := b.GetAllBuilders()
	if err != nil {
		logger.Fatal().AnErr("error", err).Msg("failed to get all builders")
	}
	for _, builder := range allBuildersResp.Builders {
		lastBuildNumber, _ := b.GetBuildersLastBuildNumber(builder.Builderid)
		batchSize := 1
		buildResp, _ := b.GetBuildsForBuilder(builder.Builderid, lastBuildNumber, batchSize)
		for _, build := range buildResp.Builds {
			err = b.InsertOrUpdateBuildLog(builder, build)
			logger.Err(err).Msg("inserting or updating build log")
		}
	}
	// lastNumber, err := b.GetBuildersLastBuildNumber(209)
	// if err != nil {
	// 	logger.Log().AnErr("error", err)
	// }
	// fmt.Println("Last number: ", lastNumber)
	// res, err := b.GetBuildsForBuilder(209, lastNumber, 2)
	// if err != nil {
	// 	logger.Log().AnErr("error", err)
	// }
	// fmt.Println(PrettyPrint(res))

	// allBuilders, err := b.GetAllBuilders()
	// if err != nil {
	// 	logger.Log().AnErr("error", err)
	// }
	// _, err = b.GetAllBuilders()
	// if err != nil {
	// 	logger.Log().AnErr("error", err)
	// }
	// _ = allBuilders
	// fmt.Println(PrettyPrint(allBuilders))
}

// PrettyPrint to print struct in a readable way
func PrettyPrint(i interface{}) string {
	s, _ := json.MarshalIndent(i, "", "\t")
	return string(s)
}
