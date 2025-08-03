#!/bin/bash
set -euo pipefail

# The fzf-powered interactive dashboard for managing tasks.

interactive_mode() {
    local note_path="$1"
    local date_str="$2"
    local editor_cmd="$3"
    local auto_commit_enabled="$4"
    local note_dir="$5"

    while true; do
        if [ ! -f "$note_path" ]; then
            create_new_note "$note_path" "$date_str"
        fi

        local tasks
        tasks=$(grep -n '^- \[ \]' "$note_path" 2>/dev/null | sed 's/^\([0-9]*\):- \[ \] !/\1: - [!] /; s/^\([0-9]*\):- \[ \] /\1: - [ ] /' || true)

        local selection
        selection=$(echo -e "$tasks" | fzf \
            --prompt="TODO > " \
            --height="80%" \
            --header="[ Ctrl-N: Add | Enter: Edit | Ctrl-D: Done | Esc: Exit ]" \
            --delimiter=":" \
            --with-nth=2.. \
            --multi \
            --print-query \
            --bind "ctrl-d:accept,ctrl-n:accept" \
            --expect=ctrl-d,ctrl-n,enter) || true

        if [ -z "$selection" ]; then
            break
        fi

        local query=""
        local key=""
        local chosen_tasks=()
        local line_num=0

        while IFS= read -r line; do
            line_num=$((line_num + 1))
            if [ "$line_num" -eq 1 ]; then
                query="$line"
            elif [ "$line_num" -eq 2 ]; then
                key="$line"
            else
                chosen_tasks+=("$line")
            fi
        done <<< "$selection"

        if [ "$key" = "ctrl-n" ]; then
            if [ -n "$query" ]; then
                add_todo_item "$note_path" "$query" "$date_str"
                auto_commit_if_enabled "$auto_commit_enabled" "$note_dir" "$note_path" "$date_str"
            fi
            continue
        elif [ "$key" = "enter" ]; then
            if [ ${#chosen_tasks[@]} -gt 0 ]; then
                local line_number
                line_number=$(echo "${chosen_tasks[0]}" | cut -d: -f1)
                open_file_at_position "$editor_cmd" "$note_path" "$line_number" 5
            fi
            continue
        elif [ "$key" = "ctrl-d" ]; then
            if [ ${#chosen_tasks[@]} -gt 0 ]; then
                for task in "${chosen_tasks[@]}"; do
                    local line_number
                    line_number=$(echo "$task" | cut -d: -f1)
                    sed -i.bak "${line_number}s/^- \[ \]/- [x]/" "$note_path"
                    rm -f "$note_path.bak"
                done
                auto_commit_if_enabled "$auto_commit_enabled" "$note_dir" "$note_path" "$date_str"
            fi
            continue
        fi
        break
    done
}
