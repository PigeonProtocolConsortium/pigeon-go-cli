#!/bin/sh
cd project
rm -rf testdata
mkdir testdata
PIGEON_PATH="./testdata" go test -v
cd -
