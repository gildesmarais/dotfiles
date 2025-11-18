#!/bin/bash
set -euo pipefail

# Displays the last four weeks of open to-do items for shell startup.
cmd_motd() {
    local lookback_days="${TODO_MOTD_LOOKBACK_DAYS:-28}"
    if ! [[ "$lookback_days" =~ ^[0-9]+$ ]] || [ "$lookback_days" -le 0 ]; then
        lookback_days=28
    fi

    if [ $# -gt 0 ]; then
        echo "Error: 'todo motd' does not accept arguments." >&2
        return 1
    fi

    local printed_any=false

    for ((offset = lookback_days - 1; offset >= 0; offset--)); do
        local delta=$(( -offset ))
        local iso_date
        iso_date=$(offset_date "$delta") || continue

        local note_path
        if ! note_path=$(note_path_for_date "$iso_date"); then
            continue
        fi

        local tasks
        tasks=$(awk '
            /^```/ { inb = !inb; next }
            !inb && /^- \[ \] / { print }
        ' "$note_path")

        if [ -n "$tasks" ]; then
            printed_any=true
            printf "%s\n" "$iso_date"
            printf "%s\n" "$tasks" | sed 's/^- \[ \] !/  - [!] /; s/^- \[ \] /  - [ ] /'
            printf "\n"
        fi
    done

    if [ "$printed_any" = true ]; then
        return 0
    fi

    # Having nothing to show is not an error for shell startup usage.
    return 0
}
