package buildbot

// Meta appears in almost all list responses
// TODO(kwk): I'm not sure but I think there are potentially more fields
type Meta struct {
	Total int `json:"total"`
}
