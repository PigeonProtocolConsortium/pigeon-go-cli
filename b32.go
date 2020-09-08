package main

import (
	"encoding/base32"
	"fmt"
)

var alphabet = "0123456789ABCDEFGHJKMNPQRSTVWXYZ"
var encoder = base32.NewEncoding(alphabet).WithPadding(base32.NoPadding)

// B32Encode does Crockford 32 encoding on a string.
func B32Encode(data []byte) string {
	return encoder.EncodeToString(data)
}

// B32Decode takes a Crockford Base32 string and converts it
// to a byte array.
func B32Decode(input string) []byte {
	output, error := encoder.DecodeString(input)
	if error != nil {
		msg := fmt.Sprintf("Error decoding Base32 string %s", input)
		panic(msg)
	}

	return output
}
