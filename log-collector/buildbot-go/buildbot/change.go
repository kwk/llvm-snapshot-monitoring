package buildbot

import (
	"database/sql/driver"
	"encoding/json"
	"fmt"

	"github.com/pkg/errors"
)

type ChangeList []Change

// ChangeList implements the driver.Valuer interface. This method
// simply returns the JSON-encoded representation of the struct.
func (a ChangeList) Value() (driver.Value, error) {
	return json.Marshal(a)
}

type ChangesResponse struct {
	Changes ChangeList `json:"changes"`
	Meta    Meta       `json:"meta"`
}

type ChangeProperties struct {
}

type Sourcestamp struct {
	Branch     string      `json:"branch"`
	Codebase   string      `json:"codebase"`
	CreatedAt  int         `json:"created_at"`
	Patch      interface{} `json:"patch"`
	Project    string      `json:"project"`
	Repository string      `json:"repository"`
	Revision   string      `json:"revision"`
	Ssid       int         `json:"ssid"`
}

type Change struct {
	Author          string           `json:"author"`
	Branch          string           `json:"branch"`
	Category        interface{}      `json:"category"`
	Changeid        int              `json:"changeid"`
	Codebase        string           `json:"codebase"`
	Comments        string           `json:"comments"`
	Committer       interface{}      `json:"committer"`
	Files           []string         `json:"files"`
	ParentChangeids []int            `json:"parent_changeids"`
	Project         string           `json:"project"`
	Properties      ChangeProperties `json:"properties"`
	Repository      string           `json:"repository"`
	Revision        string           `json:"revision"`
	Revlink         string           `json:"revlink"`
	Sourcestamp     Sourcestamp      `json:"sourcestamp"`
	WhenTimestamp   int              `json:"when_timestamp"`
}

// GetChangeForBuild returns all the changes associated with a build.
func (b *Buildbot) GetChangeForBuild(buildId int) (*ChangesResponse, error) {
	url := fmt.Sprintf(b.ApiBase+"/builds/%d/changes", buildId)
	var res ChangesResponse
	err := b.getRestApi(url, &res)
	num_total_changes := 0
	num_changes_in_batch := 0
	if err == nil {
		num_total_changes = res.Meta.Total
		num_changes_in_batch = len(res.Changes)
	}
	b.Logger.Err(err).
		Str("url", url).
		Stack().
		Int("buildId", buildId).
		Int("num_total_changes", num_total_changes).
		Int("num_changes_in_batch", num_changes_in_batch).
		Msg("getting changes for build")
	return &res, errors.WithStack(err)
}
