package main

import (
	"crypto/ed25519"
	"fmt"
	"testing"
)

var b32TestCases = []testCase{
	testCase{
		decoded: []byte{59, 73, 66, 126, 252, 150, 123, 166, 113, 107, 198, 52, 255, 236, 72, 112, 9, 146, 232, 12, 69, 165, 210, 202, 156, 63, 51, 62, 106, 207, 182, 107},
		encoded: "7D4M4ZQWJSXTCWBBRRTFZV28E04S5T0C8PJX5JMW7WSKWTPFPSNG",
	},
	testCase{
		decoded: []byte{143, 151, 30, 105, 79, 74, 193, 242, 224, 97, 106, 227, 223, 99, 236, 225, 145, 236, 152, 143, 230, 159, 247, 50, 72, 147, 217, 248, 255, 67, 126, 116},
		encoded: "HYBHWTAF9B0Z5R31DBHXYRZCW68YS64FWTFZECJ8JFCZHZT3FST0",
	},
	testCase{
		decoded: []byte{100, 138, 58, 29, 215, 203, 249, 249, 62, 224, 216, 70, 191, 13, 224, 150, 174, 81, 39, 125, 64, 93, 9, 192, 175, 93, 64, 75, 181, 93, 81, 22},
		encoded: "CJ53M7EQSFWZJFQ0V13BY3F0JTQ529VX81EGKG5FBN04QDAXA4B0",
	},
	testCase{
		decoded: []byte{145, 30, 158, 33, 248, 234, 78, 70, 108, 212, 167, 42, 151, 249, 37, 177, 36, 250, 110, 73, 89, 241, 190, 70, 7, 142, 119, 158, 15, 232, 228, 115},
		encoded: "J4F9W8FRX974CV6MMWN9FY95P4JFMVJ9B7RVWHG7HSVSW3Z8WHSG",
	},
	testCase{
		decoded: []byte{37, 190, 191, 20, 201, 161, 145, 108, 193, 112, 198, 34, 70, 92, 202, 167, 162, 124, 60, 25, 10, 67, 41, 140, 96, 103, 124, 71, 72, 191, 144, 0},
		encoded: "4PZBY569M68PSGBGRRH4CQ6AMYH7RF0S191JK330CXY4EJ5ZJ000",
	},
	testCase{
		decoded: []byte{233, 132, 69, 72, 63, 230, 64, 151, 188, 152, 73, 210, 186, 131, 153, 16, 14, 45, 110, 197, 208, 121, 102, 71, 232, 141, 240, 85, 238, 138, 91, 47},
		encoded: "X624AJ1ZWS09FF4R979BN0WS2072TVP5T1WPCHZ8HQR5BVMABCQG",
	},
	testCase{
		decoded: []byte{70, 145, 156, 235, 127, 126, 254, 123, 13, 86, 173, 10, 182, 10, 39, 151, 200, 255, 56, 48, 38, 61, 155, 72, 1, 117, 232, 111, 145, 93, 184, 104},
		encoded: "8T8SSTVZFVZ7P3APNM5BC2H7JZ4FYE1G4RYSPJ01EQM6Z4AXQ1M0",
	},
	testCase{
		decoded: []byte{40, 63, 195, 179, 116, 218, 206, 16, 126, 171, 14, 202, 210, 155, 187, 6, 117, 172, 181, 137, 46, 251, 109, 24, 107, 252, 33, 95, 206, 56, 31, 26},
		encoded: "50ZW7CVMVB710ZNB1V5D56XV0STTSDC95VXPT63BZGGNZKHR3WD0",
	},
	testCase{
		decoded: []byte{16, 249, 237, 62, 116, 10, 80, 20, 123, 50, 75, 103, 228, 127, 214, 26, 199, 49, 83, 34, 66, 24, 242, 155, 240, 60, 18, 25, 205, 187, 156, 76},
		encoded: "23WYTFKM19818YSJ9DKY8ZYP3B3K2MS288CF56ZG7G91KKDVKH60",
	},
	testCase{
		decoded: []byte{233, 110, 203, 25, 190, 221, 178, 24, 29, 138, 26, 65, 46, 246, 187, 122, 92, 164, 70, 199, 71, 11, 113, 163, 218, 251, 157, 151, 127, 152, 213, 192},
		encoded: "X5QCP6DYVPS1G7CA390JXXNVF9EA8HP78W5Q38YTZEESEZWRTQ00",
	},
}

func TestB32Encode(t *testing.T) {
	for _, test := range b32TestCases {
		actual := B32Encode(test.decoded)
		expected := test.encoded
		if actual != expected {
			fmt.Printf("FAIL:\n  Exp: %s\n  Act: %s\n", expected, actual)
			t.Fail()
		}
	}
}

func TestEncodePeerMhash(t *testing.T) {
	pub := ed25519.PublicKey{
		0x1c,
		0xff,
		0xcf,
		0x5d,
		0xd4,
		0xa2,
		0x1d,
		0x26,
		0xef,
		0xab,
		0x55,
		0xdd,
		0x86,
		0x46,
		0xcd,
		0x1d,
		0x93,
		0x46,
		0x27,
		0x18,
		0xfd,
		0x85,
		0xb4,
		0xe8,
		0xb7,
		0x21,
		0x71,
		0x5c,
		0xfe,
		0x36,
		0xdb,
		0xa8,
	}
	results := encodePeerMhash(pub)
	expected := "USER.3KZWYQEMM8EJDVXBAQERCHPD3P9MC9RRZP2V9T5Q45RNSZHPVEM0"
	if results != expected {
		t.Fail()
	}
}
