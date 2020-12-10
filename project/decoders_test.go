package main

import (
	"fmt"
	"testing"
)

func TestB32Decode(t *testing.T) {
	for i, test := range b32TestCases {
		actual := B32Decode(test.encoded)
		expected := test.decoded
		if len(actual) != len(expected) {
			fmt.Printf("\nFAIL:  length mismatch at b32TestCases[%d]", i)
			t.Fail()
		}
		for j, x := range expected {
			if actual[j] != x {
				msg := "b32TestCases[%d].encoded[%d] did not decode B32 properly (%s)"
				fmt.Printf(msg, j, i, test.encoded)
			}
		}
	}

	defer func() { recover() }()
	B32Decode("U")
	t.Errorf("Expected Base32 decode panic. It Did not panic.")
}

func TestIsBlob(t *testing.T) {
	if isBlob("FLIE.NOPE!") {
		t.Fail()
	}
	if isBlob("NOPE") {
		t.Fail()
	}
	if !isBlob("FILE.7Z2CSZKMB1RE5G6SKXRZ63ZGCNP8VVEM3K0XFMYKETRDQSM5WBSG") {
		t.Fail()
	}
}
