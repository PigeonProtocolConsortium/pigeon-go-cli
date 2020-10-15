package main

import (
	"crypto/ed25519"
	"errors"
	"fmt"
	"regexp"
	"strings"
)

func reconstructMessage(message pigeonMessage) (string, string) {
	return "top_half", "bottom_half"
}

// Every body entry is a key value pair. Keys and values are separated by a : character (no spaces).
// A key must be 1-90 characters in length.
// A key cannot contain whitespace or control characters
// A key may contain any of the following characters:
// 		alphanumeric characters (a-z, A-Z, 0-9, -, _)
// A value may be a:
// 		A string (128 characters or less)
// 		A multihash referencing an identity (USER.), a message (TEXT.) or a blob (FILE.).

const keyRegex = `^[A-Z|a-z|\-|\_|\.|0-9]{1,90}$`
const valueRegex = `^(NONE)|(\"[\x20-\x7E]{1,126}\")|(FILE\.[A-Z|0-9]{52})|(USER\.[A-Z|0-9]{52})|(TEXT\.[A-Z|0-9]{52})$`
const kindRegex = `^[\x20-\x7E]{1,90}$`

func validateKind(kind *string) error {
	matched, err := regexp.MatchString(kindRegex, *kind)

	if err != nil {
		return err
	}

	if !matched {
		errMessage := fmt.Sprintf("%s does not match %s", *kind, kindRegex)
		return errors.New(errMessage)
	}

	return nil
}

func validateBodyKey(key *string) error {
	matched, err := regexp.MatchString(keyRegex, *key)

	if err != nil {
		return err
	}

	if !matched {
		errMessage := fmt.Sprintf("%s does not match %s", *key, keyRegex)
		return errors.New(errMessage)
	}

	return nil
}

func validateBodyValue(value *string) error {
	matched, err := regexp.MatchString(valueRegex, *value)

	if err != nil {
		return err
	}

	if !matched {
		errMessage := fmt.Sprintf("%s does not match %s", *value, valueRegex)
		return errors.New(errMessage)
	}

	return nil
}

func validateSignature(message *pigeonMessage, topHalf string) error {
	asciiSignature := message.signature
	signature := []byte(B32Decode(asciiSignature))
	publicKey := decodeMhash(message.author)
	ok := ed25519.Verify(publicKey, []byte(topHalf), signature)

	if ok {
		return nil
	}

	error := fmt.Sprintf("Can't verify message %s", message.signature)
	return errors.New(error)
}

func verifyBodyItem(bodyItem *pigeonBodyItem) error {
	keyError := validateBodyKey(&bodyItem.key)
	if keyError != nil {
		return keyError
	}

	valueError := validateBodyValue(&bodyItem.value)
	if valueError != nil {
		return valueError
	}
	return nil
}

// Verify format and signature of a message, but do NOT cross-check its header
// fields.
func verifyShallow(message *pigeonMessage) error {
	var buffer strings.Builder
	buffer.Write([]byte(fmt.Sprintf("author %s\n", message.author)))
	buffer.Write([]byte(fmt.Sprintf("depth %d\n", message.depth)))
	err := validateKind(&message.kind)
	if err != nil {
		return err
	}
	buffer.Write([]byte(fmt.Sprintf("kind %s\n", message.kind)))
	buffer.Write([]byte(fmt.Sprintf("lipmaa %s\n", message.lipmaa)))
	buffer.Write([]byte(fmt.Sprintf("prev %s\n", message.prev)))
	buffer.Write([]byte("\n"))
	for count, bodyItem := range message.body {
		if count > 128 {
			return errors.New("A message may not exceed 128 key/value pairs %s")
		}
		err := verifyBodyItem(&bodyItem)
		if err != nil {
			return err
		}
		line := fmt.Sprintf("%s:%s\n", bodyItem.key, bodyItem.value)
		buffer.Write([]byte(line))
	}

	buffer.Write([]byte("\n"))
	validateSignature(message, buffer.String())
	return nil
}
