THIS_MAKEFILE_PATH:=$(word $(words $(MAKEFILE_LIST)),$(MAKEFILE_LIST))
THIS_DIR:=$(shell cd $(dir $(THIS_MAKEFILE_PATH)); pwd)

ref:=$(shell git rev-parse --short HEAD)
wip:=$(shell [[ `git diff --shortstat 2> /dev/null | tail -n1` != "" ]] && echo "-WIP")

export GOPATH = $(THIS_DIR)

run:
	go run ${GOPATH}/server.go

dist:
	goxc -pv=${ref}${wip}
	aws s3 cp pkg/${ref}${wip}/linux_amd64/server s3://metrics-binaries/${ref}${wip}/server

.PHONY: run dist
