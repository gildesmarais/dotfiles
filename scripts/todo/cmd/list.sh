#!/bin/bash
set -euo pipefail

# Displays to-do lists based on a scope.
cmd_list() {
    local scope="${1:-today}"

    case "$scope" in
        today)
            _verbose_echo "Displaying to-do list for today..."
            if [ -f "$NOTE_PATH" ]; then
                (
                    echo "## To-Do List for $DATE"
                    awk '/## To-Do/{p=1; next}/^##/{p=0} p' "$NOTE_PATH" | sed 's/^- \[ \] !/  - [!] /; s/^- \[ \] /  - [ ] /'
                ) | render_text "$TODO_USE_GLOW"
            else
                _verbose_echo "Daily note not found: $NOTE_PATH"
                echo "No to-do list found for today."
            fi
            ;;
        week)
            _verbose_echo "Generating weekly agenda..."
            for i in {0..6}; do
                local date
                date=$(date -v-"${i}"d +%Y-%m-%d)
                local note_path="$NOTE_DIR/$date.md"
                if [ -f "$note_path" ]; then
                    find_and_render_tasks "$note_path" "$date" "$TODO_USE_GLOW"
                fi
            done
            ;;
        all)
            _verbose_echo "Scanning for all open to-do items..."
            find "$NOTE_DIR" -type f -name "*.md" | sort -r | while read -r file; do
                local filename
                filename=$(basename "$file")
                local date_from_file="${filename%.md}"
                find_and_render_tasks "$file" "$date_from_file" "$TODO_USE_GLOW"
            done
            ;;
        *)
            echo "Error: Unknown list scope '$scope'. Use 'today', 'week', or 'all'." >&2
            show_help
            return 1
            ;;
    esac
}
