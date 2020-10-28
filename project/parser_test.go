package main

import (
	"io/ioutil"
	"log"
	"testing"
)

func TestParser(t *testing.T) {
	content, err1 := ioutil.ReadFile("../fixtures/fixture.pgn")
	if err1 != nil {
		log.Fatal(err1)
	}
	output, err2 := parseMessage(string(content))

	if err2 != nil {
		log.Fatal(err2)
	}

	fixtureSize := 13
	length := len(output.messages)
	if length != fixtureSize {
		t.Fatalf("Expected %d items, got %d", fixtureSize, length)
	}
}

func TestParser2(t *testing.T) {
	content, err1 := ioutil.ReadFile("../fixtures/has_blobs/messages.pgn")
	if err1 != nil {
		log.Fatal(err1)
	}
	parserOutput, err2 := parseMessage(string(content))
	output := parserOutput.messages
	if err2 != nil {
		log.Fatal(err2)
	}

	fixtureSize := 3
	length := len(output)
	if length != fixtureSize {
		t.Fatalf("Expected %d items, got %d", fixtureSize, length)
	}
	sig0 := "ZYSCKNFP8TW9DME9P9DK4Z4RV09APVEE762HK628K18NMS4DX084XKED71TCRXJNZBWY3TWDYVK1W3K496QF7Y55SCKEWP1D0SP5R30"
	if output[0].signature != sig0 {
		t.Fatal("`sig0` is not correct")
	}
	sig1 := "GAZGWG8PWZSP4VSSNYD8J873CQ6KDM93SBMA9VGGC1YW66FER96HEGZQ4CJBH51YN22WMGYADNY2SCWS0JY6YPX4APFDQ60X751JJ1R"
	if output[1].signature != sig1 {
		t.Fatal("`sig1` is not correct")
	}
	sig2 := "W94BVC4ED00Z4TJC0T3BEVC63RJYJC1J4DDS13BJTTGGXK40JSX276B9MV3GPS5JJHZW92YKAZNZ1Q4DCG0K58SCD9ZD0TVZVX7100G"
	if output[2].signature != sig2 {
		t.Fatal("`sig2` is not correct")
	}
}
