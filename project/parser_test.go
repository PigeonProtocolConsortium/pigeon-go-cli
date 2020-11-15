package main

import (
	"io/ioutil"
	"testing"
)

func TestParser(t *testing.T) {
	content, err1 := ioutil.ReadFile("../fixtures/fixture.pgn")

	check(err1, "TEST PARSER ERROR 1: %s", err1)
	output, err2 := parseMessage(string(content))

	check(err2, "TEST PARSER ERROR 2: %s", err2)

	fixtureSize := 13
	length := len(output.messages)
	if length != fixtureSize {
		t.Fatalf("Expected %d items, got %d", fixtureSize, length)
	}
}

func TestParser2(t *testing.T) {
	content, err1 := ioutil.ReadFile("../fixtures/has_blobs/messages.pgn")
	check(err1, "TestParser2 error (1) %s", err1)

	parserOutput, err2 := parseMessage(string(content))
	output := parserOutput.messages
	check(err2, "TestParser2 error (2) %s", err2)

	fixtureSize := 3
	length := len(output)
	if length != fixtureSize {
		t.Fatalf("Expected %d items, got %d", fixtureSize, length)
	}
	sig0 := "N33N7D8KFFVVPHTDE17JS7708YPAVF2F0F0AZS1FFW3D15ZH1K3HEFNQJK7KT7NMSAF8PDC1YDD5M57NPG2PTEEYPBKC1G3HFHN3J08"
	if output[0].signature != sig0 {
		t.Fatal("`sig0` is not correct")
	}
	sig1 := "53454CZKNSBK4D8NZCKWRWWE37DVANJWCS891XGRR2M8M4AJP2XNTC86MQAWAMYX3W517KWW6JD9MX3FMXNNBQ1TJS5HSK9CTW9G018"
	if output[1].signature != sig1 {
		t.Fatal("`sig1` is not correct")
	}
	sig2 := "JVN1YPVA637NF6GGPCX8GXT5FXTZPA1YM68ZWQQNXYD36CX0PSDBHXQMY7PMJYMCPFYW5BR56P2GVETM8AVYSKAFSYPVM3F7KVDW020"
	if output[2].signature != sig2 {
		t.Fatal("`sig2` is not correct")
	}
}
