package main

import (
	"bytes"
	"fmt"
	"testing"
)

func TestCreateIdentity(t *testing.T) {
	resetDB()
	pub, priv := CreateIdentity()
	dbPubKey := FetchConfig("public_key")
	dbPrivKey := FetchConfig("private_key")

	if !bytes.Equal(pub, dbPubKey) {
		t.Fail()
	}

	if !bytes.Equal(priv, dbPrivKey) {
		t.Fail()
	}
}

func TestShowIdentity(t *testing.T) {
	resetDB()
	result1 := showPubKeyOrNone()
	if result1 != "NONE" {
		t.Fail()
	}
	result2 := createOrShowIdentity()
	sigil := result2[0:5]
	if sigil != "USER." {
		t.Fail()
	}

	if len(result2) != 57 {
		t.Fail()
	}
	result3 := createOrShowIdentity()
	if result2 != result3 {
		fmt.Printf("=== result2: %s\n", result2)
		fmt.Printf("=== result3: %s\n", result3)
		t.Fail() //Expect createOrShowIdentity() to be idempotent.
	}
}
