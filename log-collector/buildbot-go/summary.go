package main

import (
	"fmt"
	"strings"
	"time"
)

type summaryData struct {
	commonData
	startTime                time.Time
	numStoredBuildLogs       int32
	totalBuilders            int
	finishedBuilderIds       []int
	canceledBuilderStatusMap map[string]error // builderName -> error why canceled
}

func printSummary(d summaryData) {
	d.logger.Info().MsgFunc(func() string {
		doneDuration := time.Since(d.startTime)
		averageStoreDuration := time.Duration(int64(float64(doneDuration) / float64(d.numStoredBuildLogs)))
		estimateDuration := 2500000 * averageStoreDuration

		res := "\nSummary\n"
		res += "-------\n"
		res += fmt.Sprintf("Elapsed time                            : %s\n", doneDuration)
		res += fmt.Sprintf("Avg store time                          : %s\n", averageStoreDuration)
		res += fmt.Sprintf("Estimated time for 2,500,000 log entries: %s\n", estimateDuration)
		res += fmt.Sprintf("Total stored log entries                : %d\n", d.numStoredBuildLogs)
		res += fmt.Sprintf("Total builders                          : %d\n", d.totalBuilders)
		res += fmt.Sprintf("Total finished builders                 : %d\n", len(d.finishedBuilderIds))
		res += fmt.Sprintf("Total canceled builders                 : %d\n", len(d.canceledBuilderStatusMap))
		res += fmt.Sprintf("Canceled builder names                  : \n%s\n", func() string {
			res := make([]string, len(d.canceledBuilderStatusMap))
			i := 0
			for builderName, err := range d.canceledBuilderStatusMap {
				res[i] = fmt.Sprintf(" * %40s: %#v", builderName, err)
				i++
			}
			return strings.Join(res, "\n")
		}())
		return res
	})
}
