package buildbot

import (
	"context"
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

// GetChangesForBuild returns all the changes associated with a build. When
// batchSize is 0 all changes are tried to be fetched in one go; otherwise small
// batches of changes are fetched and returned as one.
func (b *Buildbot) GetChangesForBuild(ctx context.Context, buildId int, batchSize int) (ChangeList, error) {
	limit := ""
	if batchSize > 0 {
		limit = fmt.Sprintf("&limit=%d", batchSize)
	}

	changeList := ChangeList{}
	nextChangeId := 0
	for {
		select {
		case <-ctx.Done():
			b.logger.Debug().Msg("context is done")
			return nil, errors.WithStack(ctx.Err())
		default:
		}

		var res ChangesResponse
		url := fmt.Sprintf(b.apiBase+"/builds/%d/changes?changeid__gt=%d&order=changeid%s", buildId, nextChangeId, limit)
		err := b.getRestApi(url, &res)

		if err != nil {
			b.logger.Error().Err(err).Str("url", url).Msg("failed to get changes")
			return nil, errors.WithStack(err)
		}

		// No more changes to process?
		numChanges := len(res.Changes)
		if numChanges == 0 {
			break
		}
		changeList = append(changeList, res.Changes...)

		// fetch next batch of changes for changes with a higher id than the
		// last change
		nextChangeId = changeList[len(changeList)-1].Changeid

		b.logger.Debug().
			Int("buildId", buildId).
			Int("meta_total_changes", res.Meta.Total).
			Int("num_changes_in_batch", len(res.Changes)).
			Int("changes_in_list", len(changeList)).
			Msg("got changes")
	}
	return changeList, nil
}
