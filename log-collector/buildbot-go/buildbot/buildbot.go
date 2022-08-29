package buildbot

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"strings"
	"sync"

	_ "github.com/lib/pq"
	"github.com/rs/zerolog"
)

type builderByIdMap map[int]Builder
type builderByNameMap map[string]Builder
type buildersByTagMap map[string][]Builder

// Buildbot describes everything we need to query information from a buildbot
// instance. It has messages to get builders, their builds, and associated
// changes.
type Buildbot struct {
	Instance string         // either "buildbot" or "staging"
	ApiBase  string         // the HTTP Rest endpoint to use
	Db       *sql.DB        // a database handle ready to use
	Logger   zerolog.Logger // a logger ready to use

	preparedStatements map[string]*sql.Stmt // see GetBuildersLastBuildNumber
	// getMaxBuildNumerStmt *sql.Stmt // see GetBuildersLastBuildNumber

	allBuildersLock sync.RWMutex      // guards the builder response and maps
	allBuilders     *BuildersResponse // you should use the GetBuilderByXXX() functions
	buildersById    builderByIdMap    // use GetBuilderById()
	buildersByName  builderByNameMap  // use GetBuilderByName()
	buildersByTag   buildersByTagMap  // use GetBuildersByTag()
}

// New returns a new Buildbot object which allows you to talk to the Buildbot's
// REST API as well as to the Logging Database.
func New(Instance string, ApiBase string, Db *sql.DB, Logger zerolog.Logger) (*Buildbot, error) {
	b := &Buildbot{
		Instance: Instance,
		ApiBase:  ApiBase,
		Db:       Db,
		Logger:   Logger,
	}
	err := b.prepareStatements()
	b.Logger.Err(err).
		Str("ApiBase", ApiBase).
		Str("instance", Instance).
		Msg("creating new buildbot object")
	return b, err
}

// Close closes the database connection and all prepared statements.
func (b *Buildbot) Close() error {
	for name, stmt := range b.preparedStatements {
		err := stmt.Close()
		b.Logger.Debug().AnErr("error", err).Str("name", name).Msg("closing prepared statement")
		if err != nil {
			return err
		}
	}
	err := b.Db.Close()
	b.Logger.Debug().AnErr("error", err).Msg("closing database connection")
	return err
}

const (
	getMaxBuildNumerStmt = "getMaxBuildNumer"
)

// prepareStatments sets up the database with a bunch of queries we want to use
// late in the code.
func (b *Buildbot) prepareStatements() error {
	var err error
	b.preparedStatements = make(map[string]*sql.Stmt)

	b.preparedStatements[getMaxBuildNumerStmt], err = b.Db.Prepare(`
	SELECT max(build_number)
	FROM buildbot_build_logs
	WHERE
	  build_complete_at IS NOT NULL 
	  AND builder_builderid=$1 
	  AND buildbot_instance=$2`)
	b.Logger.Debug().AnErr("error", err).Str("name", getMaxBuildNumerStmt).Msg("creating prepared statement")
	if err != nil {
		return err
	}

	return nil
}

// GetBuildersLastBuildNumber returns the highest build number for a given
// builder by Id in our database. Only builds that are `Complete` are respected.
func (b *Buildbot) GetBuildersLastBuildNumber(builderId int) (int, error) {
	var lastNumber int
	err := b.preparedStatements[getMaxBuildNumerStmt].QueryRow(builderId, b.Instance).Scan(&lastNumber)
	if err != nil {
		return 0, err
	}
	return lastNumber, nil
}

func (b *Buildbot) InsertOrUpdateBuildLog(builder Builder, build Build) error {
	params := []interface{}{}
	params = append(params, builder.postgresValueList()...)
	params = append(params, build.postgresValueList()...)
	params = append(params, b.Instance)

	// Create placeholder list (e.g. $1,$2,$3,$4,$5,$6,$7,$8,$9,$10)
	// NOTE: Postgres counts placeholders beginning at 1 NOT 0.
	placeholderList := make([]string, len(params))
	for i := 0; i < len(placeholderList); i++ {
		placeholderList[i] = fmt.Sprintf("$%d", i+1)
	}
	placeholderListStr := strings.Join(placeholderList, ",")

	query := `
	INSERT INTO buildbot_build_logs (
	` + builder.postgresFieldList() + "," + build.postgresFieldList() + "," + "buildbot_instance" +
		`) VALUES(
		` + placeholderListStr + `
	)
	ON CONFLICT ON CONSTRAINT buildbot_build_logs_pkey
	DO UPDATE SET
		` + builder.postgresOnUpdateSetList() + `,
		` + build.postgresOnUpdateSetList() + `,
		buildbot_instance=excluded.buildbot_instance
	;
	`

	_, err := b.Db.Exec(query, params...)

	b.Logger.Err(err).Stack().Int("buildId", build.Buildid).Str("builderName", builder.Name).Str("query", query).Msg("inserting or updating build log")
	return err
}

// getRestApi performs an HTTP GET request on the given URL and tries to
// unmarshal the response into the given target. NOTE: Make sure to pass int a
// pointer to a target type to properly unmarshall into the target.
func (b *Buildbot) getRestApi(url string, target interface{}) error {
	resp, err := http.Get(url)
	if err != nil {
		return err
	}
	defer resp.Body.Close()
	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		return err
	}
	if err := json.Unmarshal(body, &target); err != nil {
		return err
	}
	return nil
}
