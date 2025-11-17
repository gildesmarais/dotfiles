#!/bin/bash
set -euo pipefail

# Portable helper to get an ISO date string offset by N days.
_motd_date_offset() {
    local offset="${1:-0}"

    if date -v-1d +%F >/dev/null 2>&1; then
        if [ "$offset" -eq 0 ]; then
            date +%F
        elif [ "$offset" -gt 0 ]; then
            date -v+"${offset}"d +%F
        else
            date -v"${offset}"d +%F
        fi
    elif date -d '1 day ago' +%F >/dev/null 2>&1; then
        if [ "$offset" -eq 0 ]; then
            date +%F
        elif [ "$offset" -gt 0 ]; then
            date -d "${offset} days" +%F
        else
            date -d "${offset#-} days ago" +%F
        fi
    else
        python3 - <<PY
from datetime import date, timedelta
print((date.today() + timedelta(days=int("${offset}"))).isoformat())
PY
    fi
}

# Displays the last four weeks of open to-do items for shell startup.
cmd_motd() {
    local lookback_days="${TODO_MOTD_LOOKBACK_DAYS:-28}"
    if ! [[ "$lookback_days" =~ ^[0-9]+$ ]] || [ "$lookback_days" -le 0 ]; then
        lookback_days=28
    fi

    local printed_any=false

    for ((offset = lookback_days - 1; offset >= 0; offset--)); do
        local delta=$(( -offset ))
        local iso_date
        iso_date=$(_motd_date_offset "$delta") || continue

        local compact_date="${iso_date//-/}"
        local note_candidates=("$NOTE_DIR/$iso_date.md")
        if [ "$compact_date" != "$iso_date" ]; then
            note_candidates+=("$NOTE_DIR/$compact_date.md")
        fi

        for note_path in "${note_candidates[@]}"; do
            if [ ! -f "$note_path" ]; then
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

            break
        done
    done

    if [ "$printed_any" = true ]; then
        return 0
    fi
}
