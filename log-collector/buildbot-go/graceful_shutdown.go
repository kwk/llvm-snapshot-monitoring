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
	producersLeftToProcess *int32
	consumersLeftToProcess *int32
}

func makeGracefulShutdown(d gracefulShutdownData) func() error {
	return func() error {
		d.logger.Debug().Msg("starting signal handler")
		defer d.logger.Debug().Msg("exiting signal handler")

		signalChannel := make(chan os.Signal, 1)
		signal.Notify(signalChannel, os.Interrupt, syscall.SIGTERM)

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
			// default:
			// 	if producersLeftToProcess == 0 || consumersLeftToProcess == 0 {
			// 		logger.Debug().Msg("XXXXXX XXXX XXXX stopping grace handler")
			// 		ctxCancelFunc()
			// 		return nil
			// 	}
		}

		if *d.producersLeftToProcess == 0 /*int32(*numProducers)*/ {
			d.logger.Warn().Msg("all producers have finished")
			d.ctxCancelFunc()
		} else {
			d.logger.Warn().Int32("producersLeftToProcess", *d.producersLeftToProcess).Msg("not all builders finished")
		}

		return nil
	}
}
