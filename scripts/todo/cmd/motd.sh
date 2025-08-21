#!/bin/bash
set -euo pipefail

# Displays today's to-do list, for shell startup.
cmd_motd() {
    # plain text, header-agnostic, ignores code blocks
    if [ -f "$NOTE_PATH" ]; then
        awk '
            /^```/ { inb = !inb; next }
            !inb && /^- \[ \] / { print }
        ' "$NOTE_PATH" | sed 's/^- \[ \] !/  - [!] /; s/^- \[ \] /  - [ ] /'
    fi
}
