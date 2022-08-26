package main

import "encoding/json"

// See https://mholt.github.io/json-to-go/ for generating structs from responses

// Meta appears in almost all list responses
type Meta struct {
	Total int `json:"total"`
}

// -----------------------------------------------------------------------------

// See https://lab.llvm.org/staging/api/v2/builders/209/builds?number__gt=219&limit=2&order=number
type BuildsResponse struct {
	Builds []Build `json:"builds"`
	Meta   Meta    `json:"meta"`
}

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

// -----------------------------------------------------------------------------

// See https://lab.llvm.org/staging/api/v2/builders
type BuildersResponse struct {
	Builders []Builder `json:"builders"`
	Meta     Meta      `json:"meta"`
}

type Builder struct {
	Builderid   int         `json:"builderid"`
	Description interface{} `json:"description"`
	Masterids   []int       `json:"masterids"`
	Name        string      `json:"name"`
	Tags        []string    `json:"tags"`
}

// -----------------------------------------------------------------------------

type ChangesResponse struct {
	Changes []Change `json:"changes"`
	Meta    Meta     `json:"meta"`
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

// -----------------------------------------------------------------------------

// PrettyPrint to print struct in a readable way
func PrettyPrint(i interface{}) string {
	s, _ := json.MarshalIndent(i, "", "\t")
	return string(s)
}
