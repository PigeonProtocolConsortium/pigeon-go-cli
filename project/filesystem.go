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
	if err != nil {
		panicf("Home directory resolution error %s", err)
	}
	return path.Join(home, ".pigeon")
}

func pigeonBlobDir() string {
	return path.Join(pigeonHomeDir(), "blobs")
}

func maybeSetupPigeonDir() string {
	err := os.MkdirAll(pigeonHomeDir(), 0700)
	if err != nil {
		panicf("maybeSetupPigeonDir: %s", err)
	}
	return pigeonHomeDir()
}
