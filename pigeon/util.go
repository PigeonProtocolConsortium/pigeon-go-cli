package pigeon

import (
	"crypto/ed25519"
	"log"
)

// CreateIdentity is used by the CLI to create an ED25519
// keypair and store it to disk. It returns the private key
// as a Base32 encoded string
func CreateIdentity() (ed25519.PublicKey, ed25519.PrivateKey) {
	pub, priv, err := ed25519.GenerateKey(nil)
	if err != nil {
		log.Fatalf("Keypair creation error %s", err)
	}
	SetConfig("pubic_key", pub)
	SetConfig("private_key", priv)
	return pub, priv
}

// EncodeUserMhash Takes a []byte and converts it to a B32
// string in the format "USER.DATA.ED25519"
// func EncodeUserMhash(pubKey []byte) string {
// 	b32 := B32Encode(pubKey)
// 	b32Length := len(b32)

// 	if b32Length != 52 {
// 		m := "Expected %s to be 52 bytes long. Got %d"
// 		log.Fatal(m, b32, b32Length)
// 	}

// 	return fmt.Sprintf("%s%s", UserSigil, b32)
// }
