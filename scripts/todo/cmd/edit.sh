#!/bin/bash
set -euo pipefail

# Opens the daily note in the editor, placing the cursor at the first to-do item.
cmd_edit() {
    if [ ! -f "$NOTE_PATH" ]; then
        create_new_note "$NOTE_PATH" "$DATE"
    fi
    ensure_note_structure "$NOTE_PATH"

    local cursor_line
    cursor_line=$(grep -n '^- \[ \]' "$NOTE_PATH" | head -n 1 | cut -d: -f1 || true)

    if [ -z "$cursor_line" ]; then
        cursor_line=$(grep -n '## To-Do' "$NOTE_PATH" | cut -d: -f1 || true)
        if [ -n "$cursor_line" ]; then
            cursor_line=$((cursor_line + 1))
        else
            cursor_line=1
        fi
    fi

    open_file_at_position "$EDITOR" "$NOTE_PATH" "$cursor_line"
    auto_commit_if_enabled "$TODO_AUTO_COMMIT" "$NOTE_DIR" "$NOTE_PATH" "$DATE"
}
