package main

import (
	"testing"
)

// TEST CASE: Attempting to getPeerStatus() of peer that
//            does not exist.
func TestGetPeerStatus(t *testing.T) {
	resetDB()
	mHash := "USER.RJFSFK8YZ8XGTGKQDMSQCQPQXKH8GPRCDY86YZCFQ1QRKYEF48MG"

	status := getPeerStatus(mHash)
	if status != "unknown" {
		t.Fatalf("Expected `unknown`, got %s", status)
	}

	setPeerStatus(mHash, following)

	status2 := getPeerStatus(mHash)
	if status2 != "following" {
		t.Fatalf("Expected `following`, got %s", status)
	}

	peer := listPeers()[0]

	if peer.mhash != mHash {
		t.Fail()
	}

	if peer.status != following {
		t.Fail()
	}
}

func TestSetPeerStatus(t *testing.T) {
	defer func() {
		r := recover()
		if r == nil {
			err := "Should not be able to block and follow at the same time %s"
			t.Errorf(err, r)
		}
	}()
	resetDB()
	mHash := "USER.GM84FEYKRQ1QFCZY68YDCRPG8HKXQPQCQSMDQKGTGX8ZY8KFSFJR"
	setPeerStatus(mHash, following)
	setPeerStatus(mHash, blocked)
}

func TestRemovePeer(t *testing.T) {
	resetDB()
	mHash := "USER.GM84FEYKRQ1QFCZY68YDCRPG8HKXQPQCQSMDQKGTGX8ZY8KFSFJR"
	setPeerStatus(mHash, following)
	removePeer(mHash)
	if getPeerStatus(mHash) != unknown {
		t.Fail()
	}
}
