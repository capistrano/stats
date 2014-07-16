THIS_MAKEFILE_PATH:=$(word $(words $(MAKEFILE_LIST)),$(MAKEFILE_LIST))
THIS_DIR:=$(shell cd $(dir $(THIS_MAKEFILE_PATH)); pwd)

export GOPATH = $(THIS_DIR)

run:
	go run ${GOPATH}/server.go

