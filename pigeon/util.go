package pigeon

import (
	"crypto/ed25519"
	"encoding/base32"
	"fmt"
	"os"
)

// Version is the current version of Pigeon CLI
const Version = "0.0.0"

// CreateKeypair makes a new ED25519 key pair. Just a thin
// wrapper around crypto/ed25519.
func CreateKeypair() (ed25519.PublicKey, ed25519.PrivateKey) {
	pub, priv, err := ed25519.GenerateKey(nil)
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}

	return pub, priv
}

// Encoder is an Encoder
var Encoder = base32.NewEncoding("0123456789ABCDEFGHJKMNPQRSTVWXYZ").WithPadding(base32.NoPadding)

// B32Encode does Crockford 32 encoding on a string.
func B32Encode(data []byte) string {
	return Encoder.EncodeToString(data)
}

// B32Decode takes a Crockford Base32 string and converts it
// to a byte array.
func B32Decode(input string) []byte {
	output, error := Encoder.DecodeString(input)
	if error != nil {
		msg := fmt.Sprintf("Error decoding Base32 string %s", input)
		panic(msg)
	}

	return output
}
