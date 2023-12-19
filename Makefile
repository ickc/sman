SHELL = /usr/bin/env bash

VERSION = $(shell awk -F= '/version =/ {print $$2}' lib/root.go | tr -d "\" ")

test:
	go test -v ./...

all:
	go build -v

build:
	mkdir -p dist
	env GOOS=${GOOS} GOARCH=${GOARCH} CGO_ENABLED=0 go build -o dist/sman-${GOOS}-${GOARCH}-v${VERSION}
	cd dist; tar -czf sman-${GOOS}-${GOARCH}-v${VERSION}.tgz sman-${GOOS}-${GOARCH}-v${VERSION}
	rm dist/sman-${GOOS}-${GOARCH}-v${VERSION}

.PHONY: all build test

print-%:
	$(info $* = $($*))
