#!/bin/bash
set -euo pipefail

# Displays the last four weeks of open to-do items for shell startup.
cmd_motd() {
    local lookback_days="${TODO_MOTD_LOOKBACK_DAYS:-28}"
    if ! [[ "$lookback_days" =~ ^[0-9]+$ ]] || [ "$lookback_days" -le 0 ]; then
        lookback_days=28
    fi

    local json_output=false

    while [ $# -gt 0 ]; do
        case "$1" in
            --json)
                json_output=true
                shift
                ;;
            *)
                echo "Error: Unknown option '$1' for 'todo motd'." >&2
                return 1
                ;;
        esac
    done

    if [ "$json_output" = true ]; then
        _motd_print_json "$lookback_days"
        return 0
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
}

_motd_print_json() {
    local lookback_days="$1"
    local manifest=""

    for ((offset = lookback_days - 1; offset >= 0; offset--)); do
        local delta=$(( -offset ))
        local iso_date
        iso_date=$(offset_date "$delta") || continue

        local note_path
        if ! note_path=$(note_path_for_date "$iso_date"); then
            continue
        fi

        manifest+="$iso_date"$'\t'"$note_path"$'\n'
    done

    if [ -z "$manifest" ]; then
        printf "[]"
        return 0
    fi

    printf "%s" "$manifest" | python3 -c '
import json
import sys

entries = []

for line in sys.stdin:
    line = line.rstrip("\n")
    if not line:
        continue
    date, path = line.split("\t", 1)
    try:
        with open(path, "r", encoding="utf-8") as handle:
            in_block = False
            for idx, raw_line in enumerate(handle, start=1):
                raw_line = raw_line.rstrip("\n")
                if raw_line.startswith("```"):
                    in_block = not in_block
                    continue
                if in_block:
                    continue
                if raw_line.startswith("- [ ] "):
                    entries.append({
                        "id": f"{path}:{idx}",
                        "date": date,
                        "text": raw_line[6:],
                        "raw": raw_line,
                    })
    except FileNotFoundError:
        continue

json.dump(entries, sys.stdout, ensure_ascii=False)
'
}
