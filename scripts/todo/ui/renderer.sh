#!/bin/bash
set -euo pipefail

# Handles rendering content to the terminal, including markdown with 'glow'.

render_text() {
    local use_glow="$1"
    if [ "$use_glow" == "true" ]; then
        glow
    else
        cat
    fi
}

find_and_render_tasks() {
    local file_path="$1"
    local header="$2"
    local use_glow="$3"

    if grep -q '^- \[ \]' "$file_path"; then
        (
            echo "## $header"
            grep '^- \[ \]' "$file_path" | sed 's/^- \[ \] !/  - [!] /; s/^- \[ \] /  - [ ] /'
            echo
        ) | render_text "$use_glow"
    fi
}
