GOPATH := $(shell pwd)

run:
	go run src/main.go

dist:
	GOARCH=amd64 GOOS=linux go build

install:
	gpm install
