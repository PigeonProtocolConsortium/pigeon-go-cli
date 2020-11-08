package main

import (
	"fmt"
	"testing"
)

func TestImportBundle(t *testing.T) {
	resetDB()
	files := []string{
		"FILE.622PRNJ7C0S05XR2AHDPKWMG051B1QW5SXMN2RQHF2AND6J8VGPG",
		"FILE.FV0FJ0YZADY7C5JTTFYPKDBHTZJ5JVVP5TCKP0605WWXYJG4VMRG",
		"FILE.YPF11E5N9JFVB6KB1N1WDVVT9DXMCHE0XJWBZHT2CQ29S5SEPCSG",
	}
	author := "USER.09XBQDDGZPEKFBFBY67XNR5QA0TRWAKYKYNEDNQTZJV0F1JB0DGG"
	addPeer(author, following)
	error := importBundle("../fixtures/has_blobs/messages.pgn")
	check(error, "Error while importing: %s", error)

	fmt.Println("NEXT STEP: Assert that we have the following assets:")

	for _, mhash := range files {
		if !blobExists(mhash) {
			t.Fatalf("### Can't find blob: %s", mhash)
		}
	}

	messages := []string{
		"TEXT.RGKRHC0APNN9FCJTVBN1NR1ZYQ9ZY34PYYASSMJ6016S30ZTWHR0",
		"TEXT.V52B1GH1XS8K1QKJG3AK127XYA23E82J0A2ZQTJ08TF8NZN2A1Y0",
		"TEXT.Z3QS1HPX756E22XWKXAXH7NTSTJGY0AHEM9KQNATTC6HHCACZGN0",
	}
	for _, mhash := range messages {
		if !messageExists(mhash) {
			t.Fatalf("Can't find message: %s", mhash)
		}
	}
}
