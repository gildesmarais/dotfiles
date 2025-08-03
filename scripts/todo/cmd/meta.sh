#!/bin/bash
set -euo pipefail

# Handles front matter operations like list and set.
cmd_meta() {
    local sub_command="${1:-}"
    shift || true

    case "$sub_command" in
        list)
            list_front_matter "$NOTE_PATH"
            ;;
        set)
            set_front_matter "$NOTE_PATH" "$1" "$2" "$DATE"
            auto_commit_if_enabled "$TODO_AUTO_COMMIT" "$NOTE_DIR" "$NOTE_PATH" "$DATE"
            ;;
        *)
            echo "Error: Unknown meta command '$sub_command'. Use 'list' or 'set'." >&2
            show_help
            return 1
            ;;
    esac
}
