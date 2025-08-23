#!/bin/bash
set -euo pipefail

# Adds one or more to-do items to the daily note.
cmd_add() {
    if [ ${#TODO_ITEMS[@]} -eq 0 ]; then
        _verbose_echo "No items provided to 'add' command."
        return 0
    fi

    for item in "${TODO_ITEMS[@]}"; do
        add_todo_item "$NOTE_PATH" "$item" "$DATE"
        echo "Added: $item"
    done

}
