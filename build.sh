#!/bin/sh

cd project
go build --o=../pigeon-cli
env GOOS=windows GOARCH=386 go build --o=../pigeon.exe
cd -
./pigeon-cli version
./pigeon-cli identity show
