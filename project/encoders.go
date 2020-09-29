package main

import (
	"encoding/base32"
)

var alphabet = "0123456789ABCDEFGHJKMNPQRSTVWXYZ"
var encoder = base32.NewEncoding(alphabet).WithPadding(base32.NoPadding)

// B32Encode does Crockford 32 encoding on a string.
func B32Encode(data []byte) string {
	return encoder.EncodeToString(data)
}

func encodePeerMhash(pubKey []byte) string {
	return PeerSigil + B32Encode(pubKey)
}

func encodeBlobMhash(sha256 [32]byte) string {
	return BlobSigil + B32Encode(sha256[:])
}
