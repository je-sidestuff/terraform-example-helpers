#!/bin/bash

# Exit if any of the intermediate steps fail
set -e

if [ -n "${TF_EXTERNAL_DEBUG_LOG_PATH}" ]; then
    export LOG_PATH="${TF_EXTERNAL_DEBUG_LOG_PATH}"
else
    export LOG_PATH="/dev/null"
fi

TIMESTAMP=$(date)
if [ "${TF_EXTERNAL_DEBUG_LOG_APPEND}" == "true" ]; then
    echo -e "\n\n\n\nNew run at ${TIMESTAMP}" >> "$LOG_PATH"
else
    echo "New run at ${TIMESTAMP}" > "$LOG_PATH"
fi

eval "$(jq -r '@sh "EXAMPLE_SEED=\(.example_seed)"')"

if [ -z "${EXAMPLE_SEED}" ]; then
    RANDOM_VALUE=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 6; echo)
    export RANDOM_VALUE
    echo "New random value to potentially use: ${RANDOM_VALUE}" >> "$LOG_PATH"
else 
    export RANDOM_VALUE="${EXAMPLE_SEED}"
    echo "New seed value to potentially use: ${RANDOM_VALUE}" >> "$LOG_PATH"
fi

if [ -f terraform.tfstate ]; then
    echo "Attempting to resolve existing value from state file." >> "$LOG_PATH"
    MAYBE_RANDOM_VALUE="$(terraform state pull | jq -r '.resources[] | select(.module == "module.example_helpers") | select(.name == "latched_random_data") | .instances[0].attributes.result.random_value')"
    export MAYBE_RANDOM_VALUE
    echo "Resolved value (will be blank if example is not applied): ${MAYBE_RANDOM_VALUE}" >> "$LOG_PATH"
    if [ -n "${MAYBE_RANDOM_VALUE}" ]; then
        echo "Using existing ranom value." >> "$LOG_PATH"
        export RANDOM_VALUE="${MAYBE_RANDOM_VALUE}"
    else
        echo "State is empty. Using new random value." >> "$LOG_PATH"
    fi
else
    echo "State does not exist." >> "$LOG_PATH"
fi

jq -n --arg random_value "$RANDOM_VALUE" '{"random_value":$random_value}'
