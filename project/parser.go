package main

import (
	"bufio"
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
	parsingError  parserMode = iota
)

type parserState struct {
	mode    parserMode
	scanner *bufio.Scanner
	buffer  pigeonMessage
	results []pigeonMessage
	error   error
}

type parserOutput struct {
	/** `messages` is an array of messages. The messages are SHALLOW
	verified. That means the message has a valid signature and syntax,
	but `depth` and `prev` have not been scrutinized for validity. */
	messages []pigeonMessage
	/** `blobIndex` is a hash where keys represent each unique blob
	foud in a bundle. This is required to avoid ingesting unwanted
	blobs to disk. */
	blobIndex map[string]bool
}

func newState(message string) parserState {
	return parserState{
		mode:    parsingHeader,
		scanner: bufio.NewScanner(strings.NewReader(message)),
	}
}

func maybeIndexBlob(index map[string]bool, input string) {
	if isBlob(input) {
		index[input] = true
	}
}

func parseMessage(message string) (parserOutput, error) {
	empty := parserOutput{
		messages:  []pigeonMessage{},
		blobIndex: map[string]bool{},
	}
	state := newState(message)
	for state.scanner.Scan() {
		// Exit early if any step produces an error.
		if state.error != nil {
			return empty, state.error
		}

		switch state.mode {
		case parsingDone:
			maybeContinue(&state)
		case parsingHeader:
			parseHeader(&state)
		case parsingBody:
			parseBody(&state)
		case parsingFooter:
			parseFooter(&state)
		case parsingError:
			break
		}
	}
	if state.mode == parsingError {
		return empty, state.error
	}
	blobIndex := map[string]bool{}
	for _, msg := range state.results {
		if getPeerStatus(msg.author) == following {
			for _, pair := range msg.body {
				maybeIndexBlob(blobIndex, pair.key)
				maybeIndexBlob(blobIndex, pair.value)
			}
		}
	}
	output := parserOutput{messages: state.results, blobIndex: blobIndex}
	return output, nil
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
	case "prev":
		state.buffer.prev = chunks[1]
		return
	case "depth":
		depth, err := strconv.ParseInt(chunks[1], 10, 32)
		check(err, "Parsing bad depth in message %d: %q", len(state.results), chunks[1])
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
	t := state.scanner.Text()
	chunks := strings.Split(t, " ")
	state.buffer.signature = chunks[1]
	state.mode = parsingDone
	err := verifyShallow(&state.buffer)
	check(err, "Message verification failed for %s. %s", state.buffer.signature, err)
	state.results = append(state.results, state.buffer)
	state.buffer.body = []pigeonBodyItem{}
	state.buffer = pigeonMessage{}
}

func maybeContinue(state *parserState) {
	t1 := state.scanner.Text()
	if t1 == "" {
		state.mode = parsingHeader
	}
}
