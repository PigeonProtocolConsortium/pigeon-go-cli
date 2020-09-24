package main

import (
	"os"
	"path"

	"github.com/mitchellh/go-homedir"
)

func maybeSetupPigeonDir() string {
	var pigeonDataDir string
	customPath, hasCustomPath := os.LookupEnv("PIGEON_PATH")
	if hasCustomPath {
		pigeonDataDir = customPath
	} else {
		home, err := homedir.Dir()
		if err != nil {
			panicf("Home directory resolution error %s", err)
		}
		pigeonDataDir = path.Join(home, ".pigeon")
	}
	os.MkdirAll(pigeonDataDir, 0700)
	return pigeonDataDir
}
