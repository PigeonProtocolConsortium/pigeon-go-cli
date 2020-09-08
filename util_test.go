package main

import (
	"bytes"
	"testing"
)

func TestCreateIdentity(t *testing.T) {
	resetDB()
	pub, priv := CreateIdentity()
	dbPubKey := GetConfig("public_key")
	dbPrivKey := GetConfig("private_key")

	if !bytes.Equal(pub, dbPubKey) {
		t.Fail()
	}

	if !bytes.Equal(priv, dbPrivKey) {
		t.Fail()
	}
}
