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
	batchSize                int
	changesBatchSize         int
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
		if d.virtualProducersLeftToProcess == nil {
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

		d.logger.Debug().Msg("starting producer")
		defer func() {
			// Just keep track of how many producers we have active
			atomic.AddInt32(d.activeProducers, -1)

			// Last one out closes shop
			if atomic.AddInt32(d.virtualProducersLeftToProcess, -1) == 0 {
				d.logger.Info().Msg("all producers done. closing build channel")
				close(d.buildChan)
			}
		}()

		finishBuilder := func(err error) error {
			if err != nil {
				d.logger.Error().Err(err).Msg("cancelling builder")
				d.canceledBuilderIdsLock.Lock()
				defer d.canceledBuilderIdsLock.Unlock()
				d.canceledBuilderStatusMap[d.builder.Name] = errors.WithStack(err)
			} else {
				d.logger.Error().Msg("builder finished without errors")
				d.finishedBuilderIdsLock.Lock()
				defer d.finishedBuilderIdsLock.Unlock()
				d.finishedBuilderIds = append(d.finishedBuilderIds, d.builder.Builderid)
			}
			return errors.WithStack(err)
		}

		// Fetch builds in batches
		for {
			lastBuildNumber, err := d.b.GetBuildersLastBuildNumber(d.builder.Builderid)
			if err != nil {
				return finishBuilder(err)
			}
			buildResp, err := d.b.GetBuildsForBuilder(d.builder.Builderid, lastBuildNumber, d.batchSize)
			if err != nil {
				return finishBuilder(err)
			}
			// augment builds with change information
			numBuilds := len(buildResp.Builds)
			if numBuilds == 0 {
				d.logger.Info().Msg("no more builds to process")
				break
			}

			for i := 0; i < numBuilds; i++ {
				build := buildResp.Builds[i]
				select {
				case <-d.ctx.Done():
					d.logger.Debug().Msg("context is done")
					return errors.WithStack(d.ctx.Err())
				default:
				}

				changeList, err := d.b.GetChangesForBuild(d.ctx, build.Buildid, d.changesBatchSize)
				if err != nil {
					return finishBuilder(err)
				}

				build.Changes = changeList
				// d.logger.Debug().Msg("sending build to channel")
				select {
				case <-d.ctx.Done():
					// d.logger.Debug().Msg("context is done")
					return finishBuilder(d.ctx.Err())
				case d.buildChan <- build:
					// d.logger.Debug().Msg("done sending build to channel")
					// default:
				}
			}
		}
		return finishBuilder(nil)
	}
}
