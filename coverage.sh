#!/bin/sh
cd project
go test -coverprofile coverage.out
go tool cover -html=coverage.out
cd -
