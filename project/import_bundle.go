package main

import (
	"errors"
	"fmt"
	"io/ioutil"
)

func ingestOneMessage(msg pigeonMessage, blobIndex map[string]bool) {
	if getPeerStatus(msg.author) == following {
		fmt.Println("TODO: Ingest this message")
	}
}

/** ingestManyMessages takes an array of Pigeon messages
and adds them to the local database, assuming that they are
messages of interest. */
func ingestManyMessages(outp parserOutput) {
	for _, message := range outp.messages {
		ingestOneMessage(message, outp.blobIndex)
	}
}

func importBundle(path string) error {
	// Get messages.pgn file
	dat, err1 := ioutil.ReadFile(path)
	check(err1, "Problem opening bundle %s. Error: %s", path, err1)
	outp, err2 := parseMessage(string(dat))
	check(err2, "Failed to parse %s. Error: %s", path, err2)
	ingestManyMessages(outp)
	// Parse messages
	// Map over messages
	return errors.New("Not done yet")
}
