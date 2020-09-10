package main

import (
	"fmt"
)

type testCase struct {
	decoded []byte
	encoded string
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
