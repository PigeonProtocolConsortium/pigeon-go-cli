package pigeon

import (
	"bytes"
	"testing"
)

func TestCreateIdentity(t *testing.T) {
	pub, priv := CreateIdentity()

	if !bytes.Equal(pub, GetConfig("public_key")) {
		t.Fail()
	}

	if !bytes.Equal(priv, GetConfig("private_key")) {
		t.Fail()
	}
}
