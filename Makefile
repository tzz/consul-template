TEST?=./...
NAME = $(shell awk -F\" '/^const Name/ { print $$2 }' main.go)
VERSION = $(shell awk -F\" '/^const Version/ { print $$2 }' main.go)
DEPS = $(shell go list -f '{{range .TestImports}}{{.}} {{end}}' ./...)

all: deps build

deps:
	go get -d -v ./...
	echo $(DEPS) | xargs -n1 go get -d

updatedeps:
	go get -u -v ./...
	echo $(DEPS) | xargs -n1 go get -d

build: deps
	@mkdir -p bin/
	go build -o bin/$(NAME)

test:
	go test $(TEST) $(TESTARGS) -timeout=30s -parallel=4
	go test $(TEST) -race
	go vet $(TEST)

xcompile:
	@rm -rf pkg/
	@mkdir -p pkg
	gox \
		-os="darwin" \
		-os="freebsd" \
		-os="linux" \
		-os="netbsd" \
		-os="openbsd" \
		-os="solaris" \
		-os="windows" \
		-output="pkg/{{.Dir}}_$(VERSION)_{{.OS}}_{{.Arch}}/$(NAME)"

package: xcompile
	./scripts/package.sh

.PHONY: all deps updatedeps build test xcompile package
