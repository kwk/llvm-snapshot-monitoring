package buildbot

import (
	"strings"
	"testing"

	"github.com/stretchr/testify/require"
)

func TestBuild(t *testing.T) {
	t.Run("number of fields and values match", func(t *testing.T) {
		b := Build{}
		require.Equal(t, strings.Count(b.postgresFieldList(), ",")+1, len(b.postgresValueList()))
	})
}
