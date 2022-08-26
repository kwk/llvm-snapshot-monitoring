package main

import (
	"database/sql"
	"flag"
	"fmt"
	"os"
	"time"

	_ "github.com/lib/pq"
	"github.com/rs/zerolog"
)

func main() {
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

	// Out main object
	// ---------------

	b := Buildbot{
		ApiBase:  *buildbotApiBase,
		Instance: *buildbotInstance,
	}

	// Setup Logging
	// -------------

	b.Logger = zerolog.New(os.Stderr).With().Timestamp().Logger()

	// Default level for this example is info, unless debug flag is present
	zerolog.SetGlobalLevel(zerolog.InfoLevel)
	if *debug {
		zerolog.SetGlobalLevel(zerolog.DebugLevel)
	}

	if !*logJson {
		b.Logger = b.Logger.Output(zerolog.ConsoleWriter{Out: os.Stderr, TimeFormat: time.RFC3339})
	}

	// Connect to Database
	// -------------------

	var err error
	dsn := fmt.Sprintf("host=%s port=%d user=%s "+
		"password=%s dbname=%s sslmode=disable",
		*dbHost, *dbPort, *dbUser, *dbPass, *dbName)
	b.Db, err = sql.Open("postgres", dsn)
	if err != nil {
		// This will not be a connection error, but a DSN parse error or
		// another initialization error.
		b.Logger.Fatal().AnErr("error", err).Msg("unable to use data source name")
		//Msg("unable to use data source name").AnErr("error", err)
		// log.Print("hello world")
	}
	defer b.Close()

	// By calling db.Ping() we force our code to actually open up a connection
	// to the database which will validate whether or not our connection string
	// was 100% correct.
	err = b.Db.Ping()
	if err != nil {
		b.Logger.Fatal().AnErr("error", err).Msg("failed to ping postgres")
	}

	// Begin processing
	// ----------------

	b.prepareStatements()

	builderName := "standalone-build-x86_64"
	builder, _ := b.GetBuilderByName(builderName)
	lastBuildNumber, _ := b.GetBuildersLastBuildNumber(builder.Builderid)
	batchSize := 2
	buildResp, _ := b.GetBuildsForBuilder(builder.Builderid, lastBuildNumber, batchSize)
	fmt.Println(PrettyPrint(buildResp))
	for _, build := range buildResp.Builds {
		err = b.InsertOrUpdateBuildLog(*builder, build)
		b.Logger.Err(err).Msg("inserting or updating build log")
	}

	// lastNumber, err := b.GetBuildersLastBuildNumber(209)
	// if err != nil {
	// 	b.Logger.Log().AnErr("error", err)
	// }
	// fmt.Println("Last number: ", lastNumber)
	// res, err := b.GetBuildsForBuilder(209, lastNumber, 2)
	// if err != nil {
	// 	b.Logger.Log().AnErr("error", err)
	// }
	// fmt.Println(PrettyPrint(res))

	// allBuilders, err := b.GetAllBuilders()
	// if err != nil {
	// 	b.Logger.Log().AnErr("error", err)
	// }
	// _, err = b.GetAllBuilders()
	// if err != nil {
	// 	b.Logger.Log().AnErr("error", err)
	// }
	// _ = allBuilders
	// fmt.Println(PrettyPrint(allBuilders))
}
