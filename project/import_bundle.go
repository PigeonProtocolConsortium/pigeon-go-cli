package main

import (
	"errors"
	"fmt"
	"io/ioutil"
)

/** ingestRelevantMessages takes an array of Pigeon messages
and adds them to the local database, assuming that they are
messages of interest. */
func ingestRelevantMessages(msgs []pigeonMessage) {
	for _, message := range msgs {
		fmt.Printf("Peer %s has %s status\n", message.author[0:13], getPeerStatus(message.author))
	}
	panic("This is where I stopped")
}

func importBundle(path string) error {
	// Get messages.pgn file
	dat, err1 := ioutil.ReadFile(path)
	check(err1, "Problem opening %s. Error: %s", path, err1)
	msgs, err2 := parseMessage(string(dat))
	check(err2, "Failed to parse %s. Error: %s", path, err2)
	ingestRelevantMessages(msgs)
	// Parse messages
	// Map over messages
	return errors.New("Not done yet")
}
