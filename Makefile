SHELL = /usr/bin/env bash

VERSION = $(shell awk -F= '/version =/ {print $$2}' lib/root.go | tr -d "\" ")

test:
	go test -v ./...

all:
	go build -v

build:
	mkdir -p bin
	env GOOS=${GOOS} GOARCH=${GOARCH} go build -o bin/sman-${GOOS}-${GOARCH}-v${VERSION}
	cd bin; tar -czf sman-${GOOS}-${GOARCH}-v${VERSION}.tgz sman-${GOOS}-${GOARCH}-v${VERSION}
	rm bin/sman-${GOOS}-${GOARCH}-v${VERSION}

.PHONY: all build test

print-%:
	$(info $* = $($*))
