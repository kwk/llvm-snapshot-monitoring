package buildbot

import (
	"strings"
	"testing"

	"github.com/stretchr/testify/require"
)

func TestBuilder(t *testing.T) {
	t.Run("number of fields and values match", func(t *testing.T) {
		b := Builder{}
		require.Equal(t, strings.Count(b.postgresFieldList(), ",")+1, len(b.postgresValueList()))
	})
}
