package buildbot

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
