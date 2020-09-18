package main

import (
	"database/sql"
	"log"
)

// PeerStatus represents a known state of a peer, such as
// blocked, following, etc..
type PeerStatus string

const (
	following PeerStatus = "following"
	blocked              = "blocked"
	unknown              = "unknown"
)

const createPeer = "INSERT INTO peers(mhash, status) VALUES(?1, ?2)"
const findPeerByStatus = "SELECT status FROM peers WHERE mhash=$1;"

func getPeerStatus(mHash string) PeerStatus {
	var status PeerStatus
	row := Database.QueryRow(findPeerByStatus, mHash)
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

func addPeer(mHash string, status PeerStatus) {
	tx, err := Database.Begin()
	if err != nil {
		log.Fatalf("Failed to begin addPeer trx (0): %s", err)
	}
	_, err2 := tx.Exec(createPeer, mHash, status)
	if err2 != nil {
		log.Fatalf("Failure. Possible duplicate peer?: %s", err2)
	}
	err1 := tx.Commit()
	if err1 != nil {
		log.Fatalf("Failed to commit peer (2): %s", err)
	}
}

// func showPeers()        {}
// func showBlockedPeers() {}
// func blockPeer()        {}
// func unblockPeer()      {}
// func unfollowPeer()     {}
