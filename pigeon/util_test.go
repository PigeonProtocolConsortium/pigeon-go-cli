package pigeon

import (
	"bytes"
	"fmt"
	"testing"
)

func TestCreateIdentity(t *testing.T) {
	resetDB()
	pub, priv := CreateIdentity()
	dbPubKey := GetConfig("public_key")
	dbPrivKey := GetConfig("private_key")

	fmt.Printf("pub: %s\n", B32Encode(pub))
	fmt.Printf("priv: %s\n", B32Encode(priv))
	fmt.Printf("pub: %s\n", B32Encode(dbPrivKey))
	fmt.Printf("priv: %s\n", B32Encode(dbPubKey))

	if !bytes.Equal(pub, dbPubKey) {
		t.Fail()
	}

	if !bytes.Equal(priv, dbPrivKey) {
		t.Fail()
	}
}
