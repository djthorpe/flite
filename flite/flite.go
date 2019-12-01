/*
  Go Language Raspberry Pi Interface
  (c) Copyright David Thorpe 2019
  All Rights Reserved
  For Licensing and Usage information, please see LICENSE.md
*/

package flite

////////////////////////////////////////////////////////////////////////////////
// CGO

/*
#cgo pkg-config: flite
#include <flite/flite.h>
*/
import "C"

////////////////////////////////////////////////////////////////////////////////
// TYPES

type (
	Error C.int
)

////////////////////////////////////////////////////////////////////////////////
// CONSTS

const (
	FLITE_ERR_NONE Error = 0
)

////////////////////////////////////////////////////////////////////////////////
// FUNCTIONS

func Init() error {
	if err := Error(C.flite_init()); err != FLITE_ERR_NONE {
		return err
	} else {
		return nil
	}
}

////////////////////////////////////////////////////////////////////////////////
// ERRORS

func (e Error) Error() string {
	switch e {
	case FLITE_ERR_NONE:
		return "FLITE_ERR_NONE"
	default:
		return "[ ?? Invalid Error value ]"
	}
}
