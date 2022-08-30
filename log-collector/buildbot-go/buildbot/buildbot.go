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
	"github.com/pkg/errors"
	"github.com/rs/zerolog"
)

type builderByIdMap map[int]Builder
type builderByNameMap map[string]Builder
type buildersByTagMap map[string][]Builder

// Buildbot describes everything we need to query information from a buildbot
// instance. It has messages to get builders, their builds, and associated
// changes.
type Buildbot struct {
	instance string         // either "buildbot" or "staging"
	apiBase  string         // the HTTP Rest endpoint to use
	db       *sql.DB        // a database handle ready to use
	logger   zerolog.Logger // a logger ready to use

	preparedStatements map[string]*sql.Stmt // see GetBuildersLastBuildNumber

	allBuildersLock sync.RWMutex      // guards the builder response and maps
	allBuilders     *BuildersResponse // you should use the GetBuilderByXXX() functions
	buildersById    builderByIdMap    // use GetBuilderById()
	buildersByName  builderByNameMap  // use GetBuilderByName()
	buildersByTag   buildersByTagMap  // use GetBuildersByTag()
}

// New returns a new Buildbot object which allows you to talk to the Buildbot's
// REST API as well as to the Logging Database.
func New(instance string, apiBase string, db *sql.DB, logger zerolog.Logger) (*Buildbot, error) {
	b := &Buildbot{
		instance: instance,
		apiBase:  apiBase,
		db:       db,
		logger:   logger,
	}
	err := b.prepareStatements()
	logEvent := b.logger.Debug()
	if err != nil {
		logEvent = b.logger.Error().Err(err)
	}
	logEvent.Str("ApiBase", apiBase).
		Str("instance", instance).
		Msg("creating new buildbot object")
	return b, errors.WithStack(err)
}

// Close closes the database connection and all prepared statements.
func (b *Buildbot) Close() error {
	for name, stmt := range b.preparedStatements {
		err := stmt.Close()
		b.logger.Debug().Err(err).Str("name", name).Msg("closing prepared statement")
		if err != nil {
			return errors.WithStack(err)
		}
	}
	err := b.db.Close()
	b.logger.Debug().Err(err).Msg("closing database connection")
	return errors.WithStack(err)
}

const (
	getMaxBuildNumerStmt = "getMaxBuildNumer"
)

// prepareStatments sets up the database with a bunch of queries we want to use
// late in the code.
func (b *Buildbot) prepareStatements() error {
	var err error
	b.preparedStatements = make(map[string]*sql.Stmt)

	b.preparedStatements[getMaxBuildNumerStmt], err = b.db.Prepare(`
	SELECT COALESCE(max(build_number), 0)
	FROM buildbot_build_logs
	WHERE
	  build_complete_at IS NOT NULL 
	  AND builder_builderid=$1 
	  AND buildbot_instance=$2`)
	b.logger.Debug().Err(err).Str("name", getMaxBuildNumerStmt).Msg("creating prepared statement")
	if err != nil {
		return errors.WithStack(err)
	}

	return nil
}

// TODO(kwk): This could need some cleanup *cough*
func (b *Buildbot) InsertOrUpdateBuildLogs(builder Builder, builds ...Build) error {
	if len(builds) == 0 {
		return nil
	}

	placeholderListArr := []string{}
	placeholderNumberContinuous := 0
	params := []interface{}{}
	paramsLen := 0

	for bId, build := range builds {
		params = append(params, builder.postgresValueList()...)
		params = append(params, build.postgresValueList()...)
		params = append(params, b.instance)
		if bId == 0 {
			paramsLen = len(params)
		}

		// Create placeholder list (e.g. $1,$2,$3,$4,$5,$6,$7,$8,$9,$10)
		// NOTE: Postgres counts placeholders beginning at 1 NOT 0.

		placeholderList := make([]string, paramsLen)
		for i := 0; i < len(placeholderList); i++ {
			placeholderNumberContinuous++
			placeholderList[i] = fmt.Sprintf("$%d", placeholderNumberContinuous)
		}
		placeholderListArr = append(placeholderListArr, "("+strings.Join(placeholderList, ",")+")\n")
	}

	query := `
		INSERT INTO buildbot_build_logs (
		` + builder.postgresFieldList() + "," + builds[0].postgresFieldList() + "," + "buildbot_instance" +
		`) VALUES
		` + strings.Join(placeholderListArr, ",") + `
		ON CONFLICT ON CONSTRAINT buildbot_build_logs_pkey
		DO UPDATE SET
			` + builder.postgresOnUpdateSetList() + `,
			` + builds[0].postgresOnUpdateSetList() + `,
			buildbot_instance=excluded.buildbot_instance
		;`

	_, err := b.db.Exec(query, params...)

	logEvent := b.logger.Debug()
	if err != nil {
		logEvent = b.logger.Error().Err(err)
	}
	logEvent.
		Str("builderName", builder.Name).
		// Str("query", query).
		Msg("inserting or updating build logs")
	return errors.WithStack(err)
}

// getRestApi performs an HTTP GET request on the given URL and tries to
// unmarshal the response into the given target. NOTE: Make sure to pass int a
// pointer to a target type to properly unmarshall into the target.
func (b *Buildbot) getRestApi(url string, target interface{}) error {
	resp, err := http.Get(url)
	b.logger.Debug().Err(err).Str("url", url).Msg("querying REST")
	if err != nil {
		return errors.WithStack(err)
	}
	defer resp.Body.Close()
	if !(resp.StatusCode >= 200 && resp.StatusCode <= 299) {
		return errors.Errorf("request failed with status: %s (%d)", resp.Status, resp.StatusCode)
	}
	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		return errors.WithStack(err)
	}
	err = json.Unmarshal(body, &target)
	return errors.WithStack(err)
}
