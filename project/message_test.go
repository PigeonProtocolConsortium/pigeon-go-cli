package main

import (
	"testing"
)

func TestMessageExists(t *testing.T) {
	resetDB()
	message := "TEXT.49S2F3Y6AXHDD8F62RKXPFWC2BYBV5D16VQY34F40NTQFZW1R0G0"
	ok := messageExists(message)
	if ok {
		t.Fail()
	}
}
