package main

import (
	"io/ioutil"
	"log"
	"testing"
)

func TestParser(t *testing.T) {
	content, err1 := ioutil.ReadFile("../fixture.pgn")
	if err1 != nil {
		log.Fatal(err1)
	}
	output, err2 := parseMessage(string(content))

	if err2 != nil {
		log.Fatal(err2)
	}

	fixtureSize := 13
	length := len(output)
	if length != fixtureSize {
		t.Fatalf("Expected %d items, got %d", fixtureSize, length)
	}
}
