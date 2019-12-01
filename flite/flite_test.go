package flite_test

import (
	"testing"

	// Frameworks
	flite "github.com/djthorpe/flite/flite"
)

////////////////////////////////////////////////////////////////////////////////
// TEST ENUMS

func Test_000(t *testing.T) {
	t.Log("Test_000")
}

func Test_001(t *testing.T) {
	if err := flite.Init(); err != nil {
		t.Error(err)
	}
}
