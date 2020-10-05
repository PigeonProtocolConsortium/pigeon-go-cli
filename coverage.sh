#!/bin/sh
cd project
rm -rf testdata
mkdir testdata
PIGEON_PATH="./testdata" go test -coverprofile coverage.out
PIGEON_PATH="./testdata" go tool cover -html=coverage.out
cd -
