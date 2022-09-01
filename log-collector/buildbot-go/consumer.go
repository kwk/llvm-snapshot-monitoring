package main

import (
	"buildbot-go/buildbot"
	"sync/atomic"
	"time"

	"github.com/pkg/errors"
)

// consumerData bundles everything a consumer needs
type consumerData struct {
	commonData
	consumerNo             int
	consumersLeftToProcess *int32
	numStoredBuildLogs     *int32
}

// makeConsumer returns a function that can be used to run as a consumer
// go-routine.
func makeConsumer(d consumerData) func() error {
	return func() error {
		// Sanity checks
		if d.consumersLeftToProcess == nil {
			return errors.Errorf("consumersLeftToProcess must not be nil")
		}
		if d.numStoredBuildLogs == nil {
			return errors.Errorf("numStoredBuildLogs must not be nil")
		}
		if d.b == nil {
			return errors.Errorf("b must not be nil")
		}

		d.logger.Debug().Msg("starting build consumer no")
		defer func() {
			// Last one out closes shop
			if atomic.AddInt32(d.consumersLeftToProcess, -1) == 0 {
				d.logger.Info().Msg("all consumers done")
			}
		}()

		defer d.logger.Debug().Msgf("exiting build consumer")
		for {
			_startTime := time.Now()
			var ok bool
			var build buildbot.Build

			select {
			case <-d.ctx.Done():
				d.logger.Debug().Msg("context is done")
				return errors.WithStack(d.ctx.Err())
			case build, ok = <-d.buildChan:
				if !ok {
					d.logger.Debug().Msg("build channel is closed. stopping consumer")
					return nil
				}

				builder, err := d.b.GetBuilderById(build.Builderid)
				if err != nil {
					d.logger.Err(err).Int("builderId", build.Buildid).Msg("failed to get builder")
					return errors.WithStack(err)
				}
				err = d.b.InsertOrUpdateBuildLogs(*builder, build)
				d.logger.Err(err).
					Int("builderId", builder.Builderid).
					Str("builderName", builder.Name).
					Int("buildId", build.Buildid).
					Int("buildNumber", build.Number).
					Msgf("insert/update build log in %s", time.Since(_startTime))
				if err != nil {
					return errors.WithStack(err)
				}
				atomic.AddInt32(d.numStoredBuildLogs, 1)
			default:
			}
		}
	}
}
