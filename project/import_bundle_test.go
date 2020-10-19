package main

import "testing"

func TestImportBundle(t *testing.T) {
	error := importBundle("../fixtures/has_blobs/messages.pgn")
	if error != nil {
		t.Fatalf("Error while importing: %s", error)
	}
}
