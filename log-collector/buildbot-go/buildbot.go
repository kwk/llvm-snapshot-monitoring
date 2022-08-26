package main

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"strconv"
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

// PrepareStatments sets up the database with a bunch of queries we want to use
// late in the code.
func (b *Buildbot) prepareStatements() error {
	var err error
	var name string
	b.preparedStatements = make(map[string]*sql.Stmt)

	name = "getMaxBuildNumer"
	b.preparedStatements[name], err = b.Db.Prepare(`
	SELECT max(build_number)
	FROM buildbot_build_logs
	WHERE
	  build_complete_at IS NOT NULL 
	  AND builder_builderid=$1 
	  AND buildbot_instance=$2`)
	b.Logger.Debug().AnErr("error", err).Str("name", name).Msg("creating prepared statement")
	if err != nil {
		return err
	}

	return nil
}

// GetBuildersLastBuildNumber returns the highest build number for a given
// builder by Id in our database. Only builds that are `Complete` are respected.
func (b *Buildbot) GetBuildersLastBuildNumber(builderId int) (int, error) {
	var lastNumber int
	err := b.preparedStatements["getMaxBuildNumer"].QueryRow(builderId, b.Instance).Scan(&lastNumber)
	if err != nil {
		return 0, err
	}
	return lastNumber, nil
}

func intSliceToStringSlice(in []int) []string {
	out := []string{}
	for _, i := range in {
		out = append(out, strconv.Itoa(i))
	}
	return out
}

func intSlicesToPgIntArray(in []int) string {
	return fmt.Printf("ARRAY[%s]::integer[]", strings.Join(intSliceToStringSlice(in), ",")
}

func (b *Buildbot) InsertOrUpdateBuildLog(builder Builder, build Build) error {
	fmt.Printf("%#s\n", strings.Join([]int{1, 2, 3, 4}, ", "))
	return nil
	_, err := b.Db.Exec(`
	INSERT INTO buildbot_build_logs (
	    builder_builderid,
	    builder_description,
	    builder_masterids,
	    builder_name,
	    builder_tags,
	    build_buildid,
	    build_buildrequestid,
	    build_complete,
	    build_masterid,
	    build_number,
	    build_results,
	    build_workerid,
	    build_state_string,
	    build_properties,
	    build_complete_at,
	    build_started_at,
	    buildbot_instance
	) VALUES
	($1,$1,$3,$4,$5,$6,$7,$8,$9,$10,$11,$11,$12,$13,$14,$15,$16,$17)
	ON CONFLICT ON CONSTRAINT buildbot_build_logs_pkey
	    DO UPDATE SET
	        builder_description=excluded.builder_description,
	        builder_masterids=excluded.builder_masterids,
	        builder_name=excluded.builder_name,
	        builder_tags=excluded.builder_tags,
	        build_complete=excluded.build_complete,
	        build_masterid=excluded.build_masterid,
	        build_number=excluded.build_number,
	        build_results=excluded.build_results,
	        build_workerid=excluded.build_workerid,
	        build_state_string=excluded.build_state_string,
	        build_properties=excluded.build_properties,
	        build_complete_at=excluded.build_complete_at,
	        buildbot_instance=excluded.buildbot_instance,
	    ;
	`, builder.Builderid, builder.Description, intSlicesToPgIntArray(builder.Masterids), builder.Name, builder.Tags,
		build.Builderid, build.Buildrequestid, build.Complete, build.Masterid,
		build.Number, build.Results, build.Workerid, build.StateString,
		build.Properties, build.CompleteAt, build.StartedAt, b.Instance)
	b.Logger.Err(err).Int("buildId", build.Buildid).Str("builderName", builder.Name).Msg("inserting or updating build log")
	if err != nil {
		return err
	}
	return nil
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

// GetBuildsForBuilder returns all the builds for a given builder by Id which
// have a number that is greater than the provided number. The amount of builds
// returned is not greater than the provided batch size. TODO(kwk): Check
// Meta.Total and if it matches batchSize. If it doesn't stop querying for more.
// return false if there're no more entries to fetch
func (b *Buildbot) GetBuildsForBuilder(builderId int, greaterThanNumber int, batchSize int) (*BuildsResponse, error) {
	url := fmt.Sprintf(b.ApiBase+"/builders/%d/builds?number__gt=%d&limit=%d&order=number", builderId, greaterThanNumber, batchSize)
	var res BuildsResponse
	err := b.getRestApi(url, &res)
	b.Logger.Err(err).
		Str("url", url).
		Stack().
		Int("builderId", builderId).
		Int("greaterThanNumber", greaterThanNumber).
		Int("batchSize", batchSize).
		Msg("getting builds for builder")
	return &res, err
}

// getAllBuilders returns all builders for the current buildbot instance.
func (b *Buildbot) getAllBuilders() (*BuildersResponse, error) {
	// b.allBuildersLock.RLock()
	// defer b.allBuildersLock.RUnlock()
	b.allBuildersLock.Lock()
	defer b.allBuildersLock.Unlock()

	if b.allBuilders == nil {
		url := b.ApiBase + "/builders"
		err := b.getRestApi(url, &b.allBuilders)
		b.Logger.Err(err).
			Str("url", url).
			Msg("getting all builders")

		// build a LUT by Id and name for faster lookups
		b.buildersById = make(builderByIdMap)
		b.buildersByName = make(builderByNameMap)
		b.buildersByTag = make(buildersByTagMap)
		for _, builder := range b.allBuilders.Builders {
			b.buildersById[builder.Builderid] = builder
			b.buildersByName[builder.Name] = builder
			// for _, tag := range builder.Tags {
			// 	b.buildersByTag[tag] = append(b
			// }
		}
		// build a LUT by name
	} else {
		b.Logger.Debug().Msg("using cached builders")
	}
	return b.allBuilders, nil
}

// GetBuilderById returns the builder with the given Id.
//
// NOTE: Only the first call to one of the `GetBuilder(s)ByXXX()` actually
// queries the REST API of buildbot. Consecutive calls will rely on a cached
// result and are therefore faster.
func (b *Buildbot) GetBuilderById(builderId int) (*Builder, error) {
	_, err := b.getAllBuilders()
	b.Logger.Err(err).
		Int("builderId", builderId).
		Msg("getting builder by Id")
	if err != nil {
		return nil, err
	}
	builder, ok := b.buildersById[builderId]
	if !ok {
		return nil, fmt.Errorf("failed to find builder with Id: %d", builderId)
	}
	return &builder, nil
}

// GetBuilderByName returns the builder with the given name.
//
// NOTE: Only the first call to one of the `GetBuilder(s)ByXXX()` actually
// queries the REST API of buildbot. Consecutive calls will rely on a cached
// result and are therefore faster.
func (b *Buildbot) GetBuilderByName(builderName string) (*Builder, error) {
	_, err := b.getAllBuilders()
	b.Logger.Err(err).
		Str("builderName", builderName).
		Msg("getting builder by name")
	if err != nil {
		return nil, err
	}
	builder, ok := b.buildersByName[builderName]
	if !ok {
		return nil, fmt.Errorf("failed to find builder with name: %s", builderName)
	}
	return &builder, nil
}

// GetBuildersByTag returns all builders that have a certain tag.
//
// NOTE: Only the first call to one of the `GetBuilder(s)ByXXX()` actually
// queries the REST API of buildbot. Consecutive calls will rely on a cached
// result and are therefore faster.
func (b *Buildbot) GetBuildersByTag(tag string) ([]Builder, error) {
	_, err := b.getAllBuilders()
	b.Logger.Err(err).
		Str("tag", tag).
		Msg("getting builders by tag")
	if err != nil {
		return nil, err
	}
	builders, ok := b.buildersByTag[tag]
	if !ok {
		return nil, fmt.Errorf("failed to find builders with tag: %s", tag)
	}
	return builders, nil
}
