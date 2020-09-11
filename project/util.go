package main

import (
	"crypto/ed25519"
	"log"
)

func showIdentity() string {
	existingKey := GetConfig("private_key")
	if len(existingKey) == 0 {
		return "NONE"
	}
	return encodeUserMhash(existingKey)
}

func createOrShowIdentity() string {
	var pubKey []byte
	oldKey := GetConfig("private_key")
	if len(oldKey) == 0 {
		newKey, _ := CreateIdentity()
		pubKey = newKey
	} else {
		pubKey = oldKey
	}
	return encodeUserMhash(pubKey)
}

// CreateIdentity is used by the CLI to create an ED25519
// keypair and store it to disk. It returns the private key
// as a Base32 encoded string
func CreateIdentity() (ed25519.PublicKey, ed25519.PrivateKey) {
	pub, priv, err := ed25519.GenerateKey(nil)
	if err != nil {
		log.Fatalf("Keypair creation error %s", err)
	}
	SetConfig("public_key", pub)
	SetConfig("private_key", priv)
	return pub, priv
}