#!/usr/bin/env bash
set -euo pipefail

# Default values
EXAMPLE_NAME="${EXAMPLE_NAME:-my-example}"
MODULE_NAME="${MODULE_NAME:-my-module}"
TEST_NAME="${TEST_NAME:-my-test}"
DESCRIPTION="${DESCRIPTION:-A Terraform module}"
MODULE_REF="${MODULE_REF:-v0.0.1}"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
  --example-name)
    EXAMPLE_NAME="$2"
    shift 2
    ;;
  --module-name)
    MODULE_NAME="$2"
    shift 2
    ;;
  --test-name)
    TEST_NAME="$2"
    shift 2
    ;;
  --description)
    DESCRIPTION="$2"
    shift 2
    ;;
  -h | --help)
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Scaffold a new Terraform module, example, and test, then run the test."
    echo ""
    echo "Options:"
    echo "  --example-name NAME   Name for the example (default: my-example)"
    echo "  --module-name NAME    Name for the module (default: my-module)"
    echo "  --test-name NAME      Name for the test (default: my-test)"
    echo "  --description DESC    Description for the components (default: A Terraform module)"
    echo "  -h, --help            Show this help message"
    echo ""
    echo "Environment variables:"
    echo "  EXAMPLE_NAME, MODULE_NAME, TEST_NAME, DESCRIPTION can also be set via environment"
    echo "  GO_MODULE_INIT     If set and no go.mod exists, initializes a Go module with this name"
    echo "                     and adds terratest as a dependency before scaffolding."
    echo "  TERRATEST_VERSION  Version of terratest to use (default: v0.55.0)"
    exit 0
    ;;
  *)
    echo "Unknown option: $1"
    exit 1
    ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ "$MODULE_REF" == "local" ]; then
  MODULE_PATH="${SCRIPT_DIR}//combo"
else
  MODULE_PATH="github.com/je-sidestuff/terraform-example-helpers//templates/combo?ref=${MODULE_REF}"
fi
RANDOM_SUFFIX="$(date +%s)-$$"
TEMP_DIR="/tmp/temp-scaffold-${RANDOM_SUFFIX}"

# Check for go.mod and GO_MODULE_INIT environment variable
GO_MOD_EXISTS=false
if [ -f "go.mod" ]; then
  GO_MOD_EXISTS=true
fi

if [ "$GO_MOD_EXISTS" = false ] && [ -z "${GO_MODULE_INIT:-}" ]; then
  echo "ERROR: No go.mod file found in the current directory."
  echo "       Either initialize your Go module first with 'go mod init <module-name>'"
  echo "       or set the GO_MODULE_INIT environment variable to the desired module name."
  echo ""
  echo "       Example: GO_MODULE_INIT=github.com/myorg/myrepo $0"
  exit 1
fi

if [ "$GO_MOD_EXISTS" = true ] && [ -n "${GO_MODULE_INIT:-}" ]; then
  echo "WARNING: go.mod already exists but GO_MODULE_INIT is set to '${GO_MODULE_INIT}'."
  echo "         Using existing go.mod and ignoring GO_MODULE_INIT."
  echo ""
fi

if [ "$GO_MOD_EXISTS" = false ] && [ -n "${GO_MODULE_INIT:-}" ]; then
  echo "==> No go.mod found. Initializing Go module with: ${GO_MODULE_INIT}"
  go mod init "${GO_MODULE_INIT}"
  echo "==> Adding terratest dependency..."
  # Disable sumdb verification to avoid issues in containerized environments
  # where the sumdb cache directory may not be accessible
  # Note: Get the main terratest module, not the subpackage path, to avoid
  # Go resolving the subpackage as a separate pseudo-versioned module
  # Pin to v0.55.0 which supports Go 1.25 (v0.56.0+ requires Go >= 1.26)
  TERRATEST_VERSION="${TERRATEST_VERSION:-v0.55.0}"
  GOSUMDB=off go get "github.com/gruntwork-io/terratest@${TERRATEST_VERSION}"
  GOSUMDB=off go mod tidy
  echo ""
fi

echo "==> Scaffolding with the following configuration:"
echo "    Example: ${EXAMPLE_NAME}"
echo "    Module:  ${MODULE_NAME}"
echo "    Test:    ${TEST_NAME}"
echo ""

mkdir -p "${TEMP_DIR}"

echo "Scaffolding into: ${TEMP_DIR}"
cd "${TEMP_DIR}"

# Run terragrunt scaffold
echo "==> Running terragrunt scaffold..."
terragrunt scaffold "${MODULE_PATH}" \
  --no-include-root \
  --no-dependency-prompt \
  --var "example_name=${EXAMPLE_NAME}" \
  --var "module_name=${MODULE_NAME}" \
  --var "test_name=${TEST_NAME}" \
  --var "description=${DESCRIPTION}" \
  --var "outputs_filename=outputs.tf"

cd -

echo ""
echo "==> Scaffold complete. Created:"
echo "    - examples/${EXAMPLE_NAME}/"
echo "    - modules/${MODULE_NAME}/"
echo "    - test/${TEST_NAME}/"
echo ""

# Run the terratest
echo "==> Running terratest..."
cp go.* "${TEMP_DIR}"
cd "${TEMP_DIR}"
# Ensure terratest is properly pinned before running go mod tidy
# This prevents Go from treating subpaths like github.com/gruntwork-io/terratest/modules/terraform
# as separate modules (which causes "ambiguous import" errors)
TERRATEST_VERSION="${TERRATEST_VERSION:-v0.55.0}"
GOSUMDB=off go get "github.com/gruntwork-io/terratest@${TERRATEST_VERSION}"
# Use go mod tidy to add any missing dependencies from the scaffolded test files
GOSUMDB=off go mod tidy
cd -
cd "${TEMP_DIR}/test/${TEST_NAME}"
go test -v -timeout 30m

cd -

mkdir -p "modules/${MODULE_NAME}"
mkdir -p "examples/${EXAMPLE_NAME}"
mkdir -p "test"
cp -r "${TEMP_DIR}/test/${TEST_NAME}" "test/"
cp -r "${TEMP_DIR}/modules/${MODULE_NAME}" "modules/${MODULE_NAME}"
cp -r "${TEMP_DIR}/examples/${EXAMPLE_NAME}" "examples/${EXAMPLE_NAME}"

rm -rf "${TEMP_DIR}"

echo ""
echo "==> All done!"
