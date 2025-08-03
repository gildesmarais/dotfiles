#!/bin/bash
set -euo pipefail

# Opens the daily note, placing the cursor at the end of the file for quick notes.
cmd_note() {
    if [ ! -f "$NOTE_PATH" ]; then
        create_new_note "$NOTE_PATH" "$DATE"
    fi

    local last_line
    last_line=$(wc -l < "$NOTE_PATH" | tr -d ' ')
    if [ "$last_line" -eq 0 ]; then
        last_line=1
    fi

    open_file_at_position "$EDITOR" "$NOTE_PATH" "$last_line"
    auto_commit_if_enabled "$TODO_AUTO_COMMIT" "$NOTE_DIR" "$NOTE_PATH" "$DATE"
}
