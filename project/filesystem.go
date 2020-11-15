package main

import (
	"os"
	"path"

	"github.com/mitchellh/go-homedir"
)

func pigeonHomeDir() string {
	customPath, hasCustomPath := os.LookupEnv("PIGEON_PATH")
	if hasCustomPath {
		return customPath
	}
	home, err := homedir.Dir()
	check(err, "Home directory resolution error %s", err)
	return path.Join(home, ".pigeon")
}

func pigeonBlobDir() string {
	return path.Join(pigeonHomeDir(), "blobs")
}

func maybeSetupPigeonDir() string {
	err := os.MkdirAll(pigeonHomeDir(), 0700)
	check(err, "maybeSetupPigeonDir: %s", err)
	return pigeonHomeDir()
}
