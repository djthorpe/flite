/*
  Go Language Raspberry Pi Interface
  (c) Copyright David Thorpe 2019
  All Rights Reserved
  For Licensing and Usage information, please see LICENSE.md
*/

package flite

import (
	"fmt"
	"strconv"
)

////////////////////////////////////////////////////////////////////////////////
// CGO

/*
#cgo pkg-config: flite
#include <flite/flite.h>

cst_voice* register_cmu_us_awb();
*/
import "C"

////////////////////////////////////////////////////////////////////////////////
// TYPES

type (
	Error   C.int
	Voice   C.cst_voice
	WavFile C.cst_wave
)

////////////////////////////////////////////////////////////////////////////////
// CONSTS

const (
	FLITE_ERR_NONE Error = 0
	FLITE_ERR_BADPARAM
)

////////////////////////////////////////////////////////////////////////////////
// INIT

func Init() error {
	if err := Error(C.flite_init()); err != FLITE_ERR_NONE {
		return err
	} else {
		return nil
	}
}

////////////////////////////////////////////////////////////////////////////////
// CRESTE

func TextToSpeech(text string, voice *Voice) (*WavFile, error) {
	if voice == nil {
		return nil, FLITE_ERR_BADPARAM
	} else {
		cstr := C.CString(text)
		defer C.free(cstr)
		return C.flite_text_to_wave(cstr, voice)
	}
}

////////////////////////////////////////////////////////////////////////////////
// VOICE

func (this *Voice) Name() string {
	voice := (*C.cst_voice)(this)
	if this == nil || voice.name == nil {
		return "<nil>"
	} else {
		return C.GoString(voice.name)
	}
}

func (this *Voice) String() string {
	if this == nil {
		return fmt.Sprintf("<flite.Voice>{ nil }")
	} else {
		return fmt.Sprintf("<flite.Voice>{ name=%v }", strconv.Quote(this.Name()))
	}
}

////////////////////////////////////////////////////////////////////////////////
// ERRORS

func (e Error) Error() string {
	switch e {
	case FLITE_ERR_NONE:
		return "FLITE_ERR_NONE"
	case FLITE_ERR_BADPARAM:
		return "FLITE_ERR_BADPARAM"
	default:
		return "[ ?? Invalid Error value ]"
	}
}
