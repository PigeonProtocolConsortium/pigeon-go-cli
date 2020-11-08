package main

import (
	"encoding/base32"
	"fmt"
	"strings"
)

var alphabet = "0123456789ABCDEFGHJKMNPQRSTVWXYZ"
var encoder = base32.NewEncoding(alphabet).WithPadding(base32.NoPadding)

// B32Encode does Crockford 32 encoding on a string.
func B32Encode(data []byte) string {
	return encoder.EncodeToString(data)
}

func encodePeerMhash(pubKey []byte) string {
	return PeerSigil + B32Encode(pubKey)
}

func encodeBlobMhash(sha256 []byte) string {
	return BlobSigil + B32Encode(sha256[:])
}

type rawMessage struct {
	mhash   string
	content string
}

func formatMessage(message pigeonMessage) rawMessage {
	var str strings.Builder
	str.WriteString(fmt.Sprintf("author %s\n", message.author))
	str.WriteString(fmt.Sprintf("depth %d\n", message.depth))
	str.WriteString(fmt.Sprintf("kind %s\n", message.kind))
	str.WriteString(fmt.Sprintf("lipmaa %s\n", message.lipmaa))
	str.WriteString(fmt.Sprintf("prev %s\n\n", message.prev))
	for _, item := range message.body {
		str.WriteString(fmt.Sprintf("%s:%s\n", item.key, item.value))
	}
	str.WriteString(fmt.Sprintf("\nsignature %s", message.signature))
	content := str.String()
	raw := []byte(content)
	b32 := B32Encode(getSha256(raw))
	return rawMessage{
		content: content,
		mhash:   fmt.Sprintf("%s%s", MessageSigil, b32),
	}
}
