.PHONY: test build

# Run Go tests
test:
	go test -v -timeout 30m ./test/...

# Build Go modules (download dependencies)
build:
	go mod download
	go build ./...
