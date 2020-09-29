package main

import (
	"crypto/sha256"
	"fmt"
	"log"
	"os"
	"path"
)

const blobByteLimit = 360_000

// Turn a blob mhash into a filepath per bundle spec.
func pathFor(mhash string) string {
	validateMhash(mhash)
	b32 := mhash[len(BlobSigil):]
	chunks := []string{
		b32[0:7],
		b32[7:14],
		b32[14:21],
		b32[21:28],
		b32[28:35],
		b32[35:42],
		fmt.Sprintf("%s.%s", b32[42:49], b32[49:52]),
	}
	return path.Join(chunks...)
}

func addBlob(data []byte) {
	size := len(data)
	if size > blobByteLimit {
		panicf("Expected blob smaller than %d. Got: %d", blobByteLimit, size)
	}
	mhash := encodeBlobMhash(sha256.Sum256(data))
	path := path.Join(pigeonHomeDir(), pathFor(mhash))
	write(path, data)
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

// def get_blob(mhash)
// path1 = File.join(pathFor(mhash)
// path2 = File.join(DEFAULT_BLOB_DIR, path1)
// File.read(path2) if File.file?(path2)
// end
