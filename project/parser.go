package main

import (
	"bufio"
	"errors"
	"fmt"
	"strings"
)

type pigeonBodyItem struct {
	key   string
	value string
}

type pigeonMessage struct {
	author    string
	depth     int
	kind      string
	lipmaa    string
	prev      string
	body      [256]pigeonBodyItem
	signature string
}

type parserMode int

const (
	parsingHeader parserMode = iota
	parsingBody   parserMode = iota
	parsingFooter parserMode = iota
	parsingDone   parserMode = iota
)

type parserState struct {
	mode    parserMode
	scanner *bufio.Scanner
}

func newState(message string) parserState {
	return parserState{
		mode:    parsingHeader,
		scanner: bufio.NewScanner(strings.NewReader(message)),
	}
}

func parseMessage(message string) ([]pigeonMessage, error) {
	state := newState(message)

	for state.scanner.Scan() {
		switch state.mode {
		case parsingHeader:
			parseHeader(state)
		case parsingBody:
			parseBody(state)
		case parsingFooter:
			parseFooter(state)
		}
	}
	return []pigeonMessage{}, errors.New("whatever")
}

func parseHeader(state parserState) {
	t := state.scanner.Text()
	chunks := strings.Split(t, " ")
	switch len(chunks) {
	case 2:
		fmt.Printf("=== KEY: %s | VALUE: %s\n", chunks[0], chunks[1])
	default:
		fmt.Printf("WHATS THIS?? %s\n", chunks[0])
	}
}

func parseBody(state parserState) {
	panic("Not done yet")
}

func parseFooter(state parserState) {
	panic("Not done yet")
}
