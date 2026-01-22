#!/usr/bin/env bash
set -euo pipefail

# Default values
EXAMPLE_NAME="${EXAMPLE_NAME:-my-example}"
MODULE_NAME="${MODULE_NAME:-my-module}"
TEST_NAME="${TEST_NAME:-my-test}"
DESCRIPTION="${DESCRIPTION:-A Terraform module}"

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
    exit 0
    ;;
  *)
    echo "Unknown option: $1"
    exit 1
    ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULE_PATH="${SCRIPT_DIR}//combo"
RANDOM_SUFFIX="$(date +%s)-$$"
TEMP_DIR="/tmp/temp-scaffold-${RANDOM_SUFFIX}"

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
