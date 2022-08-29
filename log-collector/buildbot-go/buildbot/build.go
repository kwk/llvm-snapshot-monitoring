package buildbot

import (
	"fmt"
	"time"

	"github.com/lib/pq"
)

// See https://lab.llvm.org/staging/api/v2/builders/209/builds?number__gt=219&limit=2&order=number
type BuildsResponse struct {
	Builds []Build `json:"builds"`
	Meta   Meta    `json:"meta"`
}

// TODO(kwk): Apparently no builder has these set at the moment. Flesh out
// later.
type BuildProperties struct {
}

type Build struct {
	Builderid      int             `json:"builderid"`
	Buildid        int             `json:"buildid"`
	Buildrequestid int             `json:"buildrequestid"`
	Complete       bool            `json:"complete"`
	CompleteAt     int64           `json:"complete_at"`
	Masterid       int             `json:"masterid"`
	Number         int             `json:"number"`
	Properties     BuildProperties `json:"properties"`
	Results        int             `json:"results"`
	StartedAt      int64           `json:"started_at"`
	StateString    string          `json:"state_string"`
	Workerid       int             `json:"workerid"`
}

// postgresFieldList returns the list of field names that can be used in
// conjunction with postgresValueList() to get the values in the matching order.
func (b Build) postgresFieldList() string {
	return `
	build_buildid,        -- 1
	build_buildrequestid, -- 2
	build_complete,       -- 3
	build_masterid,       -- 4
	build_number,         -- 5
	build_results,        -- 6
	build_workerid,       -- 7
	build_state_string,   -- 8
	build_properties,     -- 9
	build_complete_at,    -- 10
	build_started_at      -- 11
	`
}

// postgresValueList returns the array of values corresponding to the list of
// fields as defined by postgresFieldList().
func (b Build) postgresValueList() []interface{} {
	return []interface{}{
		b.Builderid,      // 1
		b.Buildrequestid, // 2
		b.Complete,       // 3
		b.Masterid,       // 4
		b.Number,         // 5
		b.Results,        // 6
		b.Workerid,       // 7
		b.StateString,    // 8
		"{}",             // 9 aka b.Properties
		pq.FormatTimestamp(time.Unix(b.CompleteAt, 0)), // 10
		pq.FormatTimestamp(time.Unix(b.StartedAt, 0)),  // 11
	}
}

// postgresOnUpdateSetList returns a string with instructions on how to update a
// build on duplicate entries.
func (b Build) postgresOnUpdateSetList() string {
	return `
	build_complete     = excluded.build_complete,
	build_masterid     = excluded.build_masterid,
	build_number       = excluded.build_number,
	build_results      = excluded.build_results,
	build_workerid     = excluded.build_workerid,
	build_state_string = excluded.build_state_string,
	build_properties   = excluded.build_properties,
	build_complete_at  = excluded.build_complete_at
	`
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
	num_total_builds := 0
	num_builds_in_batch := 0
	if err == nil {
		num_total_builds = res.Meta.Total
		num_builds_in_batch = len(res.Builds)
	}
	b.Logger.Err(err).
		Str("url", url).
		Stack().
		Int("builderId", builderId).
		Int("greaterThanNumber", greaterThanNumber).
		Int("batchSize", batchSize).
		Int("num_total_builds", num_total_builds).
		Int("num_builds_in_batch", num_builds_in_batch).
		Msg("getting builds for builder")
	return &res, err
}
