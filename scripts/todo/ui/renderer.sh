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

print_checkboxes_ignoring_codeblocks() {
    local file_path="$1"
    awk '
        /^```/ { inb = !inb; next }
        !inb && /^- \[( |x)\] / { print }
    ' "$file_path"
}

squeeze_blank_lines() {
    awk '
        NF { print; empty=0; next }
        !empty { print ""; empty=1 }
    '
}

render_tasks_header_agnostic() {
    local file_path="$1"
    local header="$2"
    local use_glow="$3"

    if grep -qE '^- \[ \]|^- \[x\]' "$file_path"; then
        (
            echo "## $header"
            print_checkboxes_ignoring_codeblocks "$file_path" | sed 's/^- \[ \] !/  - [!] /; s/^- \[ \] /  - [ ] /; s/^- \[x\] /  - [x] /'
        ) | render_text "$use_glow"
    fi
}

print_open_tasks_ignoring_codeblocks() {
    local file_path="$1"
    awk '
        /^```/ { inb = !inb; next }
        !inb && /^- \[ \] / { print }
    ' "$file_path"
}

render_tasks_compact() {
    local file_path="$1"
    local header="$2"
    local use_glow="$3"
    local max_per_day="$4"
    local show_open="${5:-true}"
    local show_done="${6:-false}"

    # Get tasks based on show_open and show_done flags
    local tasks
    tasks=$(awk -v show_open="$show_open" -v show_done="$show_done" '
        /^```/ { inb = !inb; next }
        !inb && /^- \[ \] / && show_open == "true" { print }
        !inb && /^- \[x\] / && show_done == "true" { print }
    ' "$file_path")

    if [ -z "$tasks" ]; then
        return 0  # Skip days with no matching tasks
    fi

    local task_count
    task_count=$(printf "%s" "$tasks" | wc -l)

    if [ "$task_count" -le "$max_per_day" ]; then
        # Show all tasks
        (
            echo "## $header"
            echo "$tasks" | sed 's/^- \[ \] !/  - [!] /; s/^- \[ \] /  - [ ] /; s/^- \[x\] /  - [x] /'
        ) | render_text "$use_glow"
    else
        # Show first N tasks + count
        (
            echo "## $header"
            echo "$tasks" | head -n "$max_per_day" | sed 's/^- \[ \] !/  - [!] /; s/^- \[ \] /  - [ ] /; s/^- \[x\] /  - [x] /'
            printf "  (+%d more)" $((task_count - max_per_day))
        ) | render_text "$use_glow"
    fi
}
