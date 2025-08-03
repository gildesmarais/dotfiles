#!/bin/bash
set -euo pipefail

# Displays today's to-do list, for shell startup.
cmd_motd() {
    local old_glow_status=$TODO_USE_GLOW
    export TODO_USE_GLOW="false"
    cmd_list "today" | grep -- ' *- \[ \]'
    export TODO_USE_GLOW=$old_glow_status
}
