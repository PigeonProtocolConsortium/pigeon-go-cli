#!/bin/sh

cd project
go build --o=../pigeon-cli
env GOOS=windows GOARCH=386 go build --o=../pigeon.exe
cd -
PIGEON_PATH="."
./pigeon-cli version
./pigeon-cli identity show
