.PHONY: test build docker-build

# Run Go tests
test:
	go test -v -timeout 30m ./test/...

# Build Go modules (download dependencies)
build:
	go mod download
	go build ./...

# Build Docker image
docker-build:
	docker build -t terraform-example-helpers .
