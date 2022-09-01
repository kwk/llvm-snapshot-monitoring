package main

import (
	"fmt"
	"os"
	"os/signal"
	"strings"
	"syscall"
)

type gracefulShutdownData struct {
	commonData
}

func makeGracefulShutdown(d gracefulShutdownData) func() error {
	return func() error {
		d.logger.Debug().Msg("starting signal handler")
		defer d.logger.Debug().Msg("exiting signal handler")

		signalChannel := make(chan os.Signal, 1)
		signal.Notify(signalChannel, os.Interrupt, syscall.SIGTERM)

		for {
			select {
			case sig := <-signalChannel:
				str := fmt.Sprintf("caught signal: %s. gracefully shutting down", sig.String())
				border := strings.Repeat("-", len(str))
				fmt.Fprintf(os.Stderr, "\n%s\n%s\n%s\n\n", border, str, border)
				d.logger.Warn().Str("signal", sig.String()).Msg("received signal")
				d.ctxCancelFunc()
			case <-d.ctx.Done():
				d.logger.Warn().Msg("closing signal go routine")
				return d.ctx.Err()
			default:
				if *d.virtualProducersLeftToProcess == 0 || *d.consumersLeftToProcess == 0 {
					d.logger.Debug().Msg("all producers and consumers stopped, shutting down")
					d.ctxCancelFunc()
					return nil
				}
			}
		}
	}
}
