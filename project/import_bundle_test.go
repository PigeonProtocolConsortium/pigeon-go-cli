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
	for _, mhash := range files {
		if blobExists(mhash) {
			t.Fatalf("### Unclean blob dir: %s", mhash)
		}
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
		"TEXT.5BBGSKGBHKYE6R0SJSZAGNEQA8PGJ5CMTQD1XGKKP2CHYPZR8G90",
		"TEXT.7H37B05AY85M7NAC7WWENF8AN60J6E7WN106ED3XSPYPZRKSKT1G",
		"TEXT.S5G187G11N2T76E2TSPS40K5QEY6S9ZC68TKEVH7JBPN27VDTKY0",
	}

	for _, mhash := range messages {
		if !messageExists(mhash) {
			t.Fatalf("Can't find message: %s", mhash)
		}
	}
}
