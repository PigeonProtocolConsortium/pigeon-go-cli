package main

import (
	"crypto/sha256"
	"fmt"
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

func addBlob(data []byte) string {
	size := len(data)
	if size > blobByteLimit {
		panicf("Expected blob smaller than %d. Got: %d", blobByteLimit, size)
	}
	mhash := encodeBlobMhash(sha256.Sum256(data))
	blobPath := createBlobDirectory(mhash)
	write(blobPath, data)
	return blobPath
}

func addBlobFromPath(path string) string {
	dat, err := ioutil.ReadFile(path)
	if err != nil {
		panicf("Unable to read %s: %s", path, err)
	}
	return addBlob(dat)
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
// path1 = File.join(createBlobDirectory(mhash)
// path2 = File.join(DEFAULT_BLOB_DIR, path1)
// File.read(path2) if File.file?(path2)
// end
