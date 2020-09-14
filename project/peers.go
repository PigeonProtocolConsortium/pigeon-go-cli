package main

import (
	"database/sql"
	"log"
)

type peerStatus string

const (
	following peerStatus = "following"
	blocked              = "blocked"
	unknown              = "unknown"
)

func getPeerStatus(mHash string) peerStatus {
	sqlStatement := `SELECT status FROM users WHERE mhash=$1;`
	var status peerStatus
	row := Database.QueryRow(sqlStatement, mHash)
	switch err := row.Scan(&status); err {
	case sql.ErrNoRows:
		return "unknown"
	case nil:
		return status
	default:
		log.Fatalf("getPeerStatus failure: %s", err)
		panic(err)
	}
}

// func followPeer()       {}
// func showPeers()        {}
// func showBlockedPeers() {}
// func blockPeer()        {}
// func unblockPeer()      {}
// func unfollowPeer()     {}
