package main

import (
	"testing"
)

func TestImportBundle(t *testing.T) {
	resetDB()
	files := []string{
		"FILE.622PRNJ7C0S05XR2AHDPKWMG051B1QW5SXMN2RQHF2AND6J8VGPG",
		"FILE.FV0FJ0YZADY7C5JTTFYPKDBHTZJ5JVVP5TCKP0605WWXYJG4VMRG",
		"FILE.YPF11E5N9JFVB6KB1N1WDVVT9DXMCHE0XJWBZHT2CQ29S5SEPCSG",
	}
	author := "USER.59X51RSZQZR15BX86VDWG37AAMVP43PTBWD1WS66FQFCDPHAQDZ0"
	addPeer(author, following)
	error := importBundle("../fixtures/has_blobs/messages.pgn")
	check(error, "Error while importing: %s", error)

	for _, mhash := range files {
		if !blobExists(mhash) {
			t.Fatalf("### Can't find blob: %s", mhash)
		}
	}

	messages := []string{
		"FILE.622PRNJ7C0S05XR2AHDPKWMG051B1QW5SXMN2RQHF2AND6J8VGPG",
		"FILE.FV0FJ0YZADY7C5JTTFYPKDBHTZJ5JVVP5TCKP0605WWXYJG4VMRG",
		"FILE.YPF11E5N9JFVB6KB1N1WDVVT9DXMCHE0XJWBZHT2CQ29S5SEPCSG",
	}
	for _, mhash := range messages {
		if !messageExists(mhash) {
			t.Fatalf("Can't find message: %s", mhash)
		}
	}
}
