package main

import (
	"crypto/ed25519"
	"database/sql"
	"fmt"
)

// Returns the current user's identity of the `NONE` value.
func showPubKeyOrNone() string {
	existingKey, err := GetConfig("public_key")
	if (err == sql.ErrNoRows) || (len(existingKey) == 0) {
		return "NONE"
	}
	return encodePeerMhash(existingKey)
}

func createOrShowIdentity() string {
	oldKey := showPubKeyOrNone()
	if oldKey == "NONE" {
		newPubKey, _ := CreateIdentity()
		return encodePeerMhash(newPubKey)
	}

	return oldKey
}

// CreateIdentity is used by the CLI to create an ED25519
// keypair and store it to disk. It returns the private key
// as a Base32 encoded string
func CreateIdentity() (ed25519.PublicKey, ed25519.PrivateKey) {
	pub, priv, err := ed25519.GenerateKey(nil)
	check(err, "Keypair creation error %s", err)
	SetConfig("public_key", pub)
	SetConfig("private_key", priv)
	return pub, priv
}

func panicf(tpl string, args ...interface{}) {
	panic(fmt.Sprintf(tpl, args...))
}

func rollbackCheck(tx *sql.Tx, e error, tpl string, args ...interface{}) {
	if e != nil {
		tx.Rollback()
		panicf(tpl, args...)
	}
}

func check(e error, tpl string, args ...interface{}) {
	if e != nil {
		fmt.Printf("=== NEW ERROR PLEASE REPORT: %s\n", e)
		panicf(tpl, args...)
	}
}
