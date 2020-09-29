package main

import (
	"testing"
)

func TestPathForBlob(t *testing.T) {
	mhash := "FILE.FV0FJ0YZADY7C5JTTFYPKDBHTZJ5JVVP5TCKP0605WWXYJG4VMRG"
	expected := "FV0FJ0Y/ZADY7C5/JTTFYPK/DBHTZJ5/JVVP5TC/KP0605W/WXYJG4V.MRG"
	if pathFor(mhash) != expected {
		t.Fail()
	}
}
