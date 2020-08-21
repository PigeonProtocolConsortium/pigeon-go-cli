package pigeon

import (
	"crypto/ed25519"
	"fmt"
	"log"
	"os"
)

// Version is the current version of Pigeon CLI
const Version = "0.0.0"

// CreateKeypair makes a new ED25519 key pair. Just a thin
// wrapper around crypto/ed25519.
func createKeypair() (ed25519.PublicKey, ed25519.PrivateKey) {
	pub, priv, err := ed25519.GenerateKey(nil)
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}

	return pub, priv
}

// CreateIdentity is used by the CLI to create an ED25519
// keypair and store it to disk. It returns the private key
// as a Base32 encoded string
func CreateIdentity() (ed25519.PublicKey, ed25519.PrivateKey) {
	pub, priv := createKeypair()
	PutConfig(ConfigSecret, priv)
	return pub, priv
}

// GetIdentity retrieves the user's signing key
func GetIdentity() []byte {
	return GetConfig(ConfigSecret)
}

// EncodeUserMhash Takes a []byte and converts it to a B32
// string in the format "USER.DATA.ED25519"
func EncodeUserMhash(pubKey []byte) string {
	b32 := B32Encode(pubKey)
	b32Length := len(b32)

	if b32Length != 52 {
		m := "Expected %s to be 52 bytes long. Got %d"
		log.Fatal(m, b32, b32Length)
	}

	return fmt.Sprintf("%s%s", UserSigil, b32)
}
