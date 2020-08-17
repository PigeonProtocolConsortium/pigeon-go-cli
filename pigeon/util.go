package pigeon

import (
	"bytes"
	"crypto/ed25519"
	"encoding/binary"
	"fmt"
	"os"
	"strings"

	"github.com/richardlehane/crock32"
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

// GetNthBase32Char retrieves the Crockford base 32 character
// at a particular index
func GetNthBase32Char(n uint16, data []byte) rune {
	// TODO: Validate that `len(data)` is smaller than uint16
	//       max
	length := uint16(len(data))
	startingBit := n * 5
	startingByte := startingBit / 8
	lShift := startingBit % 8
	byte1 := data[startingByte]
	var byte2 byte
	if (n + 1) > length {
		byte2 = 0b00000000
	} else {
		byte2 = data[startingByte+1]
	}
	chunk := binary.BigEndian.Uint16([]byte{byte1, byte2})
	return decodeTable[(chunk<<lShift)>>11]
}

// ExtractNthPentad returns the base32 string for the nth handful
// of a *[]byte array. A handful represents 5 bits.
// 0.upto(255){|n| puts "Pentad ##{n} starts at byte #{n / 8}, lShift #{n.remainder(8)}"}
func ExtractNthPentad(n uint16, data []byte) rune {
	// start := n / 8
	// lShift := 8 * 5
	// byte1 := data[start]
	// length := uint16(len(data)) - 1
	// var byte2 byte
	// if (n + 1) > length {
	// 	byte2 = 0b00000000
	// } else {
	// 	byte2 = data[start+1]
	// }
	// twoBytes := binary.BigEndian.Uint16([]byte{byte1, byte2})
	// shiftedLeft := twoBytes << lShift
	// pentad := int(shiftedLeft >> (16 - 5))
	// fmt.Printf(`
	// start       %d
	// lShift      %d
	// byte1       %b
	// length      %d
	// byte2       %b
	// twoBytes    %b
	// shiftedLeft %b
	// pentad      %b
	// `, start, lShift, byte1, length, byte2, twoBytes, shiftedLeft, pentad)
	// return decodeTable[pentad]
	return '?'
}

// B32Encode converts a byte array into a Crockford Base 32
// string.
func B32Encode(data []byte) string {
	fmt.Println("==========")
	var b bytes.Buffer
	length := len(data)
	passes := length / 8

	for i := 0; i < passes; i++ {
		start := (i * 8)
		end := start + 8
		slice := data[start:end]
		int64 := binary.BigEndian.Uint64(slice)
		str := strings.ToUpper(crock32.Encode(int64))
		fmt.Printf("Chunk %d is %s\n", i, str)
		b.WriteString(str)
	}
	return b.String()
}

// B32Decode takes a Crockford Base32 string and converts it
// to a byte array.
func B32Decode(input string) []byte {
	return []byte("WIP")
}
