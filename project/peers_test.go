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

	addPeer(mHash, following)

	status2 := getPeerStatus(mHash)
	if status2 != "following" {
		t.Fatalf("Expected `following`, got %s", status)
	}
}
