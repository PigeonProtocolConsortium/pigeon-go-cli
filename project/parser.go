package main

import (
	"bufio"
	"errors"
	"strconv"
	"strings"
)

type pigeonBodyItem struct {
	key   string
	value string
}

type pigeonMessage struct {
	author    string
	depth     int64
	kind      string
	lipmaa    string
	prev      string
	body      []pigeonBodyItem
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
	buffer  pigeonMessage
	results []pigeonMessage
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
			parseHeader(&state)
		case parsingBody:
			parseBody(&state)
		case parsingFooter:
			parseFooter(&state)
		}
	}
	return []pigeonMessage{}, errors.New("whatever")
}

func parseHeader(state *parserState) {
	t := state.scanner.Text()
	chunks := strings.Split(t, " ")

	switch chunks[0] {
	case "":
		state.mode = parsingBody
		return
	case "author":
		state.buffer.author = chunks[1]
		return
	case "kind":
		state.buffer.kind = chunks[1]
		return
	case "lipmaa":
		state.buffer.lipmaa = chunks[1]
		return
	case "prev":
		state.buffer.prev = chunks[1]
		return
	case "depth":
		depth, err := strconv.ParseInt(chunks[1], 10, 32)
		if err != nil {
			tpl := "Parsing bad depth in message %d: %q"
			panicf(tpl, len(state.results), chunks[1])
		}
		state.buffer.depth = depth
		return
	default:
		panicf("BAD HEADER: %q", t)
	}
}

func parseBody(state *parserState) {
	t := state.scanner.Text()
	chunks := strings.Split(t, ":")
	if chunks[0] == "" {
		state.mode = parsingFooter
		return
	}
	pair := pigeonBodyItem{key: chunks[0], value: chunks[1]}
	state.buffer.body = append(state.buffer.body, pair)
	return
}

func parseFooter(state *parserState) {
	panic("=== STOPPED HERE")
}
