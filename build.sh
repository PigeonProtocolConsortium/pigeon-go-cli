#!/bin/sh

cd project
go build --o=../pigeon-cli
cd -
PIGEON_PATH="."
./pigeon-cli version
./pigeon-cli identity show
