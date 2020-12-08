package main

import (
	"bytes"
	"fmt"
	"path"
	"testing"
)

func TestPathForBlob(t *testing.T) {
	mhash := "FILE.FV0FJ0YZADY7C5JTTFYPKDBHTZJ5JVVP5TCKP0605WWXYJG4VMRG"
	expected := path.Join(pigeonBlobDir(),
		"FV0FJ0Y",
		"ZADY7C5",
		"JTTFYPK",
		"DBHTZJ5",
		"JVVP5TC",
		"KP0605W",
		"WXYJG4V.MRG")
	p, f := pathAndFilename(mhash)
	actual := path.Join(p, f)

	if actual != expected {
		fmt.Printf("Expected %s\n", expected)
		fmt.Printf("Got %s\n", actual)
		t.Fail()
	}
}

func TestAddBlobFromPipe(t *testing.T) {
	reader := bytes.NewBufferString("lol\n")
	actual := addBlobFromPipe(reader)
	expected := "FILE.MGJ4N91XVNQ3XYF69EW0YKQ9ABV84CNA026KVAE7HRXP4ZJPEQ40"
	if actual != expected {
		fmt.Printf("Expected %s\n", expected)
		fmt.Printf("Got %s\n", actual)
		t.Fail()
	}
}
