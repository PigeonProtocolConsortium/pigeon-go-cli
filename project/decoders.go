package main

import (
	"fmt"
	"strings"
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
		panic(fmt.Sprintf("Error decoding Base32 string %s", input))
	}

	return output
}

func validateMhash(input string) string {
	arry := strings.Split(input, ".")
	if len(arry) != 2 {
		panicf("Expected '%s' to be an mHash", input)
	}
	switch arry[0] + "." {
	case BlobSigil, MessageSigil, PeerSigil:
		return input
	}
	msg := "Expected left side of Mhash dot to be one of %s, %s, %s. Got: %s"
	panicf(msg, BlobSigil, MessageSigil, PeerSigil, arry[0])
	return input
}
