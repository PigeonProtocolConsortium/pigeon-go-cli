package main

import (
	"database/sql"
	"fmt"
)

// PeerStatus represents a known state of a peer, such as
// blocked, following, etc..
type PeerStatus string

const (
	following PeerStatus = "following"
	blocked              = "blocked"
	unknown              = "unknown"
)

type peer struct {
	mhash  string
	status PeerStatus
}

const sqlCreatePeer = "INSERT INTO peers(mhash, status) VALUES(?1, ?2);"
const sqlFindPeerByStatus = "SELECT status FROM peers WHERE mhash=$1;"
const sqlGetAllPeers = "SELECT mhash, status FROM peers ORDER BY status DESC, mhash ASC;"
const sqlRemovePeer = "DELETE FROM peers WHERE mhash=$1;"

func getPeerStatus(mHash string) PeerStatus {
	var status PeerStatus
	row := getDB().QueryRow(sqlFindPeerByStatus, mHash)
	switch err := row.Scan(&status); err {
	case sql.ErrNoRows:
		return "unknown"
	case nil:
		return status
	default:
		panicf("getPeerStatus failure: %s", err)
		panic(err)
	}
}

func addPeer(mHash string, status PeerStatus) {
	tx, err := getDB().Begin()
	if err != nil {
		panicf("Failed to begin addPeer trx (0): %s", err)
	}
	_, err2 := tx.Exec(sqlCreatePeer, mHash, status)
	if err2 != nil {
		// This .Commit() call never gets hit:
		err1 := tx.Rollback()
		if err1 != nil {
			panicf("Failed to rollback peer (1): %s", err)
		}
		panic(fmt.Sprintf("Failure. Possible duplicate peer?: %s", err2))
	}
	err1 := tx.Commit()
	if err1 != nil {
		panicf("Failed to commit peer (2): %s", err)
	}
}

func removePeer(mHash string) {
	tx, err := getDB().Begin()
	if err != nil {
		panicf("Failed to begin removePeer trx (0): %s", err)
	}
	_, err2 := tx.Exec(sqlRemovePeer, mHash)
	if err2 != nil {
		err1 := tx.Rollback()
		if err1 != nil {
			panicf("Failed to rollback removePeer (1): %s", err)
		}
		panic(fmt.Sprintf("Failure. Possible duplicate peer?: %s", err2))
	}
	err1 := tx.Commit()
	if err1 != nil {
		panicf("Failed to commit peer removal (2): %s", err)
	}
}

func listPeers() []peer {
	var (
		status PeerStatus
		mhash  string
	)
	rows, err := getDB().Query(sqlGetAllPeers)
	if err != nil {
		panicf("showPeers query failure: %s", err)
	}
	defer rows.Close()
	output := []peer{}
	for rows.Next() {
		err := rows.Scan(&mhash, &status)
		if err != nil {
			panicf("Show peers row scan failure: %s", err)
		}
		output = append(output, peer{mhash: mhash, status: status})
	}
	err = rows.Err()
	if err != nil {
		panicf("showPeers row error: %s", err)
	}
	return output
}

// func showBlockedPeers() {}
// func blockPeer()        {}
// func unblockPeer()      {}
// func unfollowPeer()     {}
