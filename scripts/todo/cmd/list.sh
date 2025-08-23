#!/bin/bash
set -euo pipefail

# Displays to-do lists based on a scope.
cmd_list() {
    # Git pull before listing to ensure we have the latest changes
    _git_pull "$NOTE_DIR"

    local scope="today"
    local max_per_day="${TODO_LIST_MAX_PER_DAY:-5}"
    local show_open=true
    local show_done=true
    local flags_given=false

    # Parse flags first
    while [ $# -gt 0 ]; do
        case "$1" in
            -a|--all)
                show_open=true
                show_done=true
                flags_given=true
                shift
                ;;
            -o|--open-only)
                show_open=true
                show_done=false
                flags_given=true
                shift
                ;;
            -d|--done-only)
                show_open=false
                show_done=true
                flags_given=true
                shift
                ;;
            week|all|today)
                scope="$1"
                shift
                ;;
            *)
                echo "Error: Unknown option '$1'" >&2
                show_help
                return 1
                ;;
        esac
    done

    # Smart defaults based on scope (only when no explicit flags given)
    if [ "$scope" != "today" ] && [ "$flags_given" = false ]; then
        # Multi-day with both states: default to compact (open only)
        show_open=true
        show_done=false
    fi

    case "$scope" in
        today)
            _verbose_echo "Displaying tasks for today (header-agnostic)..."
            # shellcheck disable=SC2153  # NOTE_PATH and DATE are exported in state.sh
            if [ -f "$NOTE_PATH" ]; then
                (
                    echo "## Tasks for $DATE"
                    awk -v show_open="$show_open" -v show_done="$show_done" '
                        /^```/ { inb = !inb; next }
                        !inb && /^- \[ \] / && show_open == "true" { print }
                        !inb && /^- \[x\] / && show_done == "true" { print }
                    ' "$NOTE_PATH" | sed 's/^- \[ \] !/  - [!] /; s/^- \[ \] /  - [ ] /; s/^- \[x\] /  - [x] /'
                ) | render_text "$TODO_USE_GLOW"
            else
                _verbose_echo "Daily note not found: $NOTE_PATH"
                echo "No tasks found for today."
            fi
            ;;
        week)
            _verbose_echo "Generating weekly agenda (compact)..."
            date_offset() {
                local d=${1:-0}
                if date -v-1d +%F >/dev/null 2>&1; then
                    if [ "$d" -eq 0 ]; then
                        date +%F
                    elif [ "$d" -gt 0 ]; then
                        date -v+"${d}"d +%F
                    else
                        date -v"${d}"d +%F
                    fi
                elif date -d '1 day ago' +%F >/dev/null 2>&1; then
                    if [ "$d" -eq 0 ]; then
                        date +%F
                    elif [ "$d" -gt 0 ]; then
                        date -d "${d} days" +%F
                    else
                        date -d "${d#-} days ago" +%F
                    fi
                else
                    python3 - <<PY
from datetime import date, timedelta
print((date.today() + timedelta(days=int("${d}"))).isoformat())
PY
                fi
            }

            for i in {6..0}; do
                local date
                date=$(date_offset "-$i")
                local note_path="$NOTE_DIR/$date.md"
                if [ -f "$note_path" ]; then
                    if [ "$show_open" = true ] && [ "$show_done" = true ]; then
                        render_tasks_header_agnostic "$note_path" "$date" "$TODO_USE_GLOW"
                    else
                        render_tasks_compact "$note_path" "$date" "$TODO_USE_GLOW" "$max_per_day" "$show_open" "$show_done"
                    fi
                fi
            done
            ;;
        all)
            _verbose_echo "Scanning for all to-do items (compact)..."
            find "$NOTE_DIR" -type f -name "*.md" | sort | while read -r file; do
                local filename
                filename=$(basename "$file")
                local date_from_file="${filename%.md}"
                if [ "$show_open" = true ] && [ "$show_done" = true ]; then
                    render_tasks_header_agnostic "$file" "$date_from_file" "$TODO_USE_GLOW"
                else
                    render_tasks_compact "$file" "$date_from_file" "$TODO_USE_GLOW" "$max_per_day" "$show_open" "$show_done"
                fi
            done
            ;;
        *)
            echo "Error: Unknown list scope '$scope'. Use 'today', 'week', or 'all'." >&2
            show_help
            return 1
            ;;
    esac
}
