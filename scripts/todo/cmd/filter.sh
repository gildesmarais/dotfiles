#!/bin/bash
set -euo pipefail

# Interactively fuzzy search all open tasks.
cmd_filter() {
    _verbose_echo "Scanning for open to-do items..."

    local tasks
    tasks=$(find "$NOTE_DIR" -type f -name "*.md" -exec awk '/^- \[ \]/{print FILENAME ":" $0}' {} + | sort)

    if [ -z "$tasks" ]; then
        echo "No open tasks found."
        return 0
    fi

    local selected_task
    selected_task=$(echo "$tasks" | fzf --prompt="Fuzzy search tasks: " --delimiter=":" --with-nth=2..)

    if [ -n "$selected_task" ]; then
        local file_path
        file_path=$(echo "$selected_task" | cut -d: -f1)
        local task_content
        task_content=$(echo "$selected_task" | cut -d: -f2-)

        local line_number
        line_number=$(grep -nF -- "$task_content" "$file_path" | cut -d: -f1)

        if [ -n "$line_number" ]; then
            open_file_at_position "$EDITOR" "$file_path" "$line_number" 5
        else
            echo "Error: Could not find the selected task in the file." >&2
            return 1
        fi
    fi
}
