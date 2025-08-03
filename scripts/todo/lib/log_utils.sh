#!/bin/bash
set -euo pipefail

# Provides logging utility functions.
_verbose_echo() {
    local message="$1"

    if [ "${VERBOSE_FLAG:-false}" = "true" ]; then
        echo "VERBOSE: $message" >&2
    fi
}
