package main

import (
	"buildbot-go/buildbot"
	"sync"
	"sync/atomic"

	"github.com/pkg/errors"
)

// producerData bundles everything a producer needs
type producerData struct {
	commonData
	builder                  buildbot.Builder
	producerNo               int
	producersLeftToProcess   *int32
	finishedBuilderIds       []int
	finishedBuilderIdsLock   *sync.RWMutex
	canceledBuilderStatusMap map[string]error // builderName -> error why canceled
	canceledBuilderIdsLock   *sync.RWMutex
}

// makeProducer returns a function that can be used to run as a producer
// go-routine.
func makeProducer(d producerData) func() error {
	return func() error {
		// Sanity checks
		if d.producersLeftToProcess == nil {
			return errors.Errorf("consumersLeftToProcess must not be nil")
		}
		if d.b == nil {
			return errors.Errorf("b must not be nil")
		}
		if d.canceledBuilderIdsLock == nil {
			return errors.Errorf("canceledBuilderIdsLock must not be null")
		}
		if d.finishedBuilderIdsLock == nil {
			return errors.Errorf("finishedBuilderIdsLock must not be null")
		}

		d.logger.Debug().Str("builderName", d.builder.Name).Msg("starting build producer")
		defer func() {
			// Last one out closes shop
			if atomic.AddInt32(d.producersLeftToProcess, -1) == 0 {
				d.logger.Info().Msg("all producers done")
				d.logger.Debug().Msg("closing buildChan")
				close(d.buildChan)
			}
		}()
		lastBuildNumber, err := d.b.GetBuildersLastBuildNumber(d.builder.Builderid)
		if err != nil {
			return errors.WithStack(err)
		}
		batchSize := 10
		buildResp, err := d.b.GetBuildsForBuilder(d.builder.Builderid, lastBuildNumber, batchSize)
		if err != nil {
			return errors.WithStack(err)
		}
		// augment builds with change information
		numBuilds := len(buildResp.Builds)
		for i := 0; i < numBuilds; i++ {
			build := buildResp.Builds[i]
			select {
			case <-d.ctx.Done():
				d.logger.Debug().Msg("context is done")
				return errors.WithStack(d.ctx.Err())
			default:
			}
			d.logger.Debug().
				Int("buildId", build.Buildid).
				Msgf("getting changes for %d/%d builds", i+1, numBuilds)
			changesResp, err := d.b.GetChangesForBuild(build.Buildid)
			if err != nil {
				d.logger.Err(err).
					Int("buildId", build.Buildid).
					Msg("failed to get changes for build")
				d.canceledBuilderIdsLock.Lock()
				defer d.canceledBuilderIdsLock.Unlock()
				d.canceledBuilderStatusMap[d.builder.Name] = errors.WithStack(err)
				return errors.WithStack(err)
			}
			if changesResp != nil {
				build.Changes = changesResp.Changes
			} else {
				d.logger.Warn().
					Int("buildId", build.Buildid).
					Msg("something went wrong when getting changes for build. cancelling collection of logs for builder")
				// Store in cancelled builder array
				d.canceledBuilderIdsLock.Lock()
				defer d.canceledBuilderIdsLock.Unlock()
				d.canceledBuilderStatusMap[d.builder.Name] = errors.Errorf("something went wrong")
				return nil
			}

			d.logger.Debug().Msg("sending build to channel")
			select {
			case <-d.ctx.Done():
				d.logger.Debug().Msg("context is done")
				return errors.WithStack(d.ctx.Err())
			case d.buildChan <- build:
				d.logger.Debug().Msg("done sending build to channel")
			default:
			}
		}
		// Store in completed builder array
		d.finishedBuilderIdsLock.Lock()
		defer d.finishedBuilderIdsLock.Unlock()
		d.finishedBuilderIds = append(d.finishedBuilderIds, d.builder.Builderid)
		return nil
	}
}
