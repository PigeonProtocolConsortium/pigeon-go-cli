package main

import (
	"bufio"
	"crypto/sha256"
	"fmt"
	"io"
	"io/ioutil"
	"log"
	"os"
	"path"
)

const blobByteLimit = 360_000

func pathAndFilename(mhash string) (dirPath string, fileName string) {
	validateMhash(mhash)
	b32 := mhash[len(BlobSigil):]
	pathChunks := []string{
		b32[0:7],
		b32[7:14],
		b32[14:21],
		b32[21:28],
		b32[28:35],
		b32[35:42],
	}

	f := fmt.Sprintf("%s.%s", b32[42:49], b32[49:52])
	p := path.Join(pigeonBlobDir(), path.Join(pathChunks...))
	return p, f
}

// Create a set of nested set of directories to place a blob
// as outlined in bundle spec.
func createBlobDirectory(mhash string) string {
	dirPath, fileName := pathAndFilename(mhash)
	err := os.MkdirAll(dirPath, 0700)
	if err != nil {
		panicf("createBlobDirectory: %s", err)
	}

	return path.Join(dirPath, fileName)
}

// func fileExists(filename string) bool {
// 	info, err := os.Stat(filename)
// 	if os.IsNotExist(err) {
// 		return false
// 	}
// 	return !info.IsDir()
// }

// func blobExists(mhash string) bool {
// 	return fileExists(createBlobDirectory(mhash))
// }

func addBlob(mhash string, data []byte) string {
	size := len(data)
	if size > blobByteLimit {
		panicf("Expected blob smaller than %d. Got: %d", blobByteLimit, size)
	}
	blobPath := createBlobDirectory(mhash)
	write(blobPath, data)
	return mhash
}

func addBlobFromPipe() string {
	reader := bufio.NewReader(os.Stdin)
	var output []byte

	for {
		input, err := reader.ReadByte()
		if err != nil && err == io.EOF {
			break
		}
		output = append(output, input)
	}

	return addBlob(getMhashForBytes(output), output)
}

func write(path string, data []byte) {
	// Open a new file for writing only
	file, err := os.OpenFile(
		path,
		os.O_WRONLY|os.O_TRUNC|os.O_CREATE,
		0600,
	)
	if err != nil {
		log.Fatal(err)
	}
	defer file.Close()

	_, err2 := file.Write(data)
	if err2 != nil {
		log.Fatal(err)
	}
}

func getSha256(data []byte) []byte {
	h := sha256.New()
	h.Write(data)
	return h.Sum(nil)
}

func getMhashForBytes(data []byte) string {
	return encodeBlobMhash(getSha256(data))
}

/* getMhashForFile Returns the mHash and data for a path. */
func getMhashForFile(path string) (string, []byte) {
	data, err := ioutil.ReadFile(path)
	check(err, "Can't open %s", path)
	return getMhashForBytes(data), data
}
