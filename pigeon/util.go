package pigeon

import (
	"bytes"
	"crypto/ed25519"
	"encoding/binary"
	"fmt"
	"os"
)

// Version is the current version of Pigeon CLI
const Version = "0.0.0"

// CreateKeypair makes a new ED25519 key pair. Just a thin
// wrapper around crypto/ed25519.
func CreateKeypair() (ed25519.PublicKey, ed25519.PrivateKey) {
	pub, priv, err := ed25519.GenerateKey(nil)
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}

	return pub, priv
}

var decodeTable = map[uint16]rune{
	0b00000: '0',
	0b00001: '1',
	0b00010: '2',
	0b00011: '3',
	0b00100: '4',
	0b00101: '5',
	0b00110: '6',
	0b00111: '7',
	0b01000: '8',
	0b01001: '9',
	0b01010: 'A',
	0b01011: 'B',
	0b01100: 'C',
	0b01101: 'D',
	0b01110: 'E',
	0b01111: 'F',
	0b10000: 'G',
	0b10001: 'H',
	0b10010: 'J',
	0b10011: 'K',
	0b10100: 'M',
	0b10101: 'N',
	0b10110: 'P',
	0b10111: 'Q',
	0b11000: 'R',
	0b11001: 'S',
	0b11010: 'T',
	0b11011: 'V',
	0b11100: 'W',
	0b11101: 'X',
	0b11110: 'Y',
	0b11111: 'Z',
}

// getBase32Size returns the number of characters needed to
// encode a given byte array to base32.
func getBase32Size(data []byte) int {
	bits := len(data) * 8
	return (bits / 5) + (bits % 5)
}

// getNthBase32Char retrieves the Crockford base 32 character
// at a particular index
func getNthBase32Char(n int, data []byte) rune {
	startingBit := n * 5
	startingByte := startingBit / 8
	lShift := startingBit % 8
	byte1 := data[startingByte]
	var byte2 byte
	if (n + 1) > len(data) {
		byte2 = 0b00000000
	} else {
		byte2 = data[startingByte+1]
	}
	chunk := binary.BigEndian.Uint16([]byte{byte1, byte2})
	pentad := (chunk << lShift) >> 11
	return decodeTable[pentad]
}

// B32Encode converts a byte array into a Crockford Base 32
// string.
func B32Encode(data []byte) string {
	var b bytes.Buffer

	for i := 0; i < getBase32Size(data); i++ {
		b.WriteRune(getNthBase32Char(i, data))
	}

	return b.String()
}

// B32Decode takes a Crockford Base32 string and converts it
// to a byte array.
func B32Decode(input string) []byte {
	return []byte("WIP")
}
