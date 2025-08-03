#!/bin/bash
set -euo pipefail

# State Management
_config() {
    NOTE_DIR="${TODO_NOTE_DIR:-$HOME/Documents/notes/daily}"
    EDITOR="${EDITOR:-vim}"
    TODO_AUTO_COMMIT="${TODO_AUTO_COMMIT:-false}"

    if [ "${TODO_AUTO_COMMIT}" = "true" ] && [ "${TODO_AUTO_PUSH:-}" != "false" ]; then
        TODO_AUTO_PUSH="true"
    else
        TODO_AUTO_PUSH="${TODO_AUTO_PUSH:-false}"
    fi

    export TODO_CHANGES_MADE="false"

    if command -v glow &> /dev/null; then
        DEFAULT_GLOW_STATUS="true"
    else
        DEFAULT_GLOW_STATUS="false"
    fi
    TODO_USE_GLOW="${TODO_USE_GLOW:-$DEFAULT_GLOW_STATUS}"

    if command -v fzf &> /dev/null; then
        FZF_INSTALLED=true
    else
        FZF_INSTALLED=false
    fi
}

_init_state() {
    DATE=$(date +%Y-%m-%d)
    export NOTE_PATH="$NOTE_DIR/$DATE.md"

    if [ ! -d "$NOTE_DIR" ]; then
        _verbose_echo "Creating notes directory: $NOTE_DIR"
        mkdir -p "$NOTE_DIR"
    fi
}

_check_dependencies() {
    local dependencies=("awk" "grep" "sed" "date" "yq")
    if [ "$FZF_INSTALLED" = true ]; then
        dependencies+=("fzf")
    fi
    if [ "$TODO_AUTO_COMMIT" = true ]; then
        dependencies+=("git")
    fi

    if [ "$TODO_USE_GLOW" = true ]; then
        if ! command -v glow &> /dev/null; then
            echo "Warning: 'glow' not found. Falling back to plain text output." >&2
            TODO_USE_GLOW="false"
        else
            dependencies+=("glow")
        fi
    fi

    for cmd in "${dependencies[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            echo "Error: Required command not found: '$cmd'" >&2
            exit 1
        fi
    done
}
