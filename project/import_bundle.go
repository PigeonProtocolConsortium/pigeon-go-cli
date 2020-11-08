package main

import (
	"fmt"
	"io/ioutil"
	"path"
	"path/filepath"
)

const insertMessageQuery = "INSERT INTO messages(author, depth, kind, lipmaa, prev, signature, mhash) VALUES(?1, ?2, ?3, ?4, ?5, ?6, $7)"
const insertBodyItemQuery = "INSERT INTO body_items(parent, key, value, rank) VALUES(?1, ?2, ?3, ?4)"

func ingestOneMessage(msg pigeonMessage, blobIndex map[string]bool) {
	if getPeerStatus(msg.author) == following {
		tx, err1 := getDB().Begin()
		check(err1, "ingestOneMessage: Can't open DB: %s", err1)
		mhash := encodeMessageMhash(msg.signature)
		results, err2 := tx.Exec(insertMessageQuery,
			msg.author,
			msg.depth,
			msg.kind,
			msg.lipmaa,
			msg.prev,
			msg.signature,
			mhash)
		rollbackCheck(tx, err2, "Failed to save message %s. %s", msg.signature, err2)
		parent, err3 := results.LastInsertId()
		rollbackCheck(tx, err3, "Failed to get last ID for message %s", msg.signature)

		for rank, pair := range msg.body {
			_, err4 := tx.Exec(insertBodyItemQuery, parent, pair.key, pair.value, rank)
			if err4 != nil {
				fmt.Printf("%s", err4)
			}
			rollbackCheck(tx, err4, "Failed to insert body item %d of %s", rank, msg.signature)
		}
		err5 := tx.Commit()
		check(err5, "Failed to commit message %s", msg.signature)
	}
}

/** ingestManyMessages takes an array of Pigeon messages
and adds them to the local database, assuming that they are
messages of interest and assuming that they do not already
exist in the database. */
func ingestManyMessages(outp parserOutput) {
	for _, message := range outp.messages {
		ingestOneMessage(message, outp.blobIndex)
	}
}

func ingestBlobs(p string, blobIndex map[string]bool) {
	dir, _ := path.Split(p)
	wildcard := path.Join(dir, "*.blb")
	blobPaths, err1 := filepath.Glob(wildcard)
	check(err1, "Blob wildcard failure %s", wildcard)
	for _, blobPath := range blobPaths {
		mhash, data := getMhashForFile(blobPath)

		if blobIndex[mhash] {
			addBlob(mhash, data)
			blobIndex[mhash] = false
		} else {
			fmt.Printf("Don't need %s\n", mhash)
		}
	}
}

func importBundle(path string) error {
	// Get messages.pgn file
	dat, err1 := ioutil.ReadFile(path)
	check(err1, "Problem opening bundle %s. Error: %s", path, err1)
	outp, err2 := parseMessage(string(dat))
	check(err2, "Failed to parse %s. Error: %s", path, err2)
	ingestManyMessages(outp)
	ingestBlobs(path, outp.blobIndex)
	return nil
}
