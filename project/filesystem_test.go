package main

import (
	"testing"
)

func TestPigeonHomeDir(t *testing.T) {
	result := pigeonHomeDir()
	expected := "./testdata"
	if result != expected {
		t.Fail()
	}
}
