# terraform-example-helpers

Terraform modules to improve management of example content.

# Quickstart

To create a new module/example/test combo, run the following command from the root of your repository.

```bash
docker run --rm \
  -v "$(pwd):/workspace" \
  -w /workspace \
  --user "$(id -u):$(id -g)" \
  -e MODULE_NAME=my-module \
  -e EXAMPLE_NAME=my-example \
  -e TEST_NAME=my-test \
  -e HOME=/tmp \
  -e GOCACHE=/tmp/go-build \
  -e GOMODCACHE=/tmp/go-mod \
  ghcr.io/je-sidestuff/terraform-example-helpers:latest \
  /app/templates/scaffold-and-test.sh
```

Note that you must already have the `go.mod` and `go.sum` file present in the repo.

(Note for future implementation - the params to run as a user and to redirect the go cache can be re-evaluated for inclusion in the container.)
