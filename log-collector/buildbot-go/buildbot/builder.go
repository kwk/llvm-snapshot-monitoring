package buildbot

import (
	"github.com/lib/pq"
	"github.com/pkg/errors"
)

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

// postgresFieldList returns the list of field names that can be used in
// conjunction with postgresValueList() to get the values in the matching order.
func (b Builder) postgresFieldList() string {
	return `
	builder_builderid,    -- 1
	builder_description,  -- 2
	builder_masterids,    -- 3
	builder_name,         -- 4
	builder_tags          -- 5
	`
}

// postgresValueList returns the array of values corresponding to the list of
// fields as defined by postgresFieldList().
func (b Builder) postgresValueList() []interface{} {
	return []interface{}{
		b.Builderid,           // 1
		b.Description,         // 2
		pq.Array(b.Masterids), // 3
		b.Name,                // 4
		pq.Array(b.Tags),      // 5
	}
}

// postgresOnUpdateSetList returns a string with instructions on how to update a
// builder on duplicate entries.
func (b Builder) postgresOnUpdateSetList() string {
	return `
		builder_description = excluded.builder_description,
		builder_masterids   = excluded.builder_masterids,
		builder_name        = excluded.builder_name,
		builder_tags        = excluded.builder_tags
	`
}

// GetAllBuilders returns all builders for the current buildbot instance.
func (b *Buildbot) GetAllBuilders() (*BuildersResponse, error) {
	// b.allBuildersLock.RLock()
	// defer b.allBuildersLock.RUnlock()
	b.allBuildersLock.Lock()
	defer b.allBuildersLock.Unlock()

	if b.allBuilders == nil {
		url := b.apiBase + "/builders"
		err := b.getRestApi(url, &b.allBuilders)
		num_total_builders := 0
		if err == nil {
			num_total_builders = b.allBuilders.Meta.Total
		}
		b.logger.Err(err).
			Str("url", url).
			Int("num_total_builders", num_total_builders).
			Msg("getting all builders")
		if err != nil {
			return b.allBuilders, errors.WithStack(err)
		}

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
		b.logger.Debug().Msg("using cached builders")
	}
	return b.allBuilders, nil
}

// GetBuilderById returns the builder with the given Id.
//
// NOTE: Only the first call to one of the `GetBuilder(s)ByXXX()` actually
// queries the REST API of  Consecutive calls will rely on a cached
// result and are therefore faster.
func (b *Buildbot) GetBuilderById(builderId int) (*Builder, error) {
	_, err := b.GetAllBuilders()
	b.logger.Err(err).
		Int("builderId", builderId).
		Msg("getting builder by Id")
	if err != nil {
		return nil, errors.WithStack(err)
	}
	builder, ok := b.buildersById[builderId]
	if !ok {
		return nil, errors.Errorf("failed to find builder with Id: %d", builderId)
	}
	return &builder, nil
}

// GetBuilderByName returns the builder with the given name.
//
// NOTE: Only the first call to one of the `GetBuilder(s)ByXXX()` actually
// queries the REST API of  Consecutive calls will rely on a cached
// result and are therefore faster.
func (b *Buildbot) GetBuilderByName(builderName string) (*Builder, error) {
	_, err := b.GetAllBuilders()
	b.logger.Err(err).
		Str("builderName", builderName).
		Msg("getting builder by name")
	if err != nil {
		return nil, errors.WithStack(err)
	}
	builder, ok := b.buildersByName[builderName]
	if !ok {
		return nil, errors.Errorf("failed to find builder with name: %s", builderName)
	}
	return &builder, nil
}

// GetBuildersByTag returns all builders that have a certain tag.
//
// NOTE: Only the first call to one of the `GetBuilder(s)ByXXX()` actually
// queries the REST API of  Consecutive calls will rely on a cached
// result and are therefore faster.
func (b *Buildbot) GetBuildersByTag(tag string) ([]Builder, error) {
	_, err := b.GetAllBuilders()
	b.logger.Err(err).
		Str("tag", tag).
		Msg("getting builders by tag")
	if err != nil {
		return nil, errors.WithStack(err)
	}
	builders, ok := b.buildersByTag[tag]
	if !ok {
		return nil, errors.Errorf("failed to find builders with tag: %s", tag)
	}
	return builders, nil
}
