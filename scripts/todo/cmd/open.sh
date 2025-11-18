#!/bin/bash
set -euo pipefail

# Opens the note containing a to-do item at the correct line.
cmd_open() {
    local target_id=""

    while [ $# -gt 0 ]; do
        case "$1" in
            --id)
                shift
                if [ $# -eq 0 ]; then
                    echo "Error: '--id' requires a value." >&2
                    return 1
                fi
                target_id="$1"
                shift
                ;;
            *)
                target_id="$1"
                shift
                ;;
        esac
    done

    if [ -z "$target_id" ]; then
        echo "Error: Provide a task identifier (path:line)." >&2
        return 1
    fi

    local path="${target_id%:*}"
    local line_number="${target_id##*:}"

    if [ -z "$path" ] || [ "$path" = "$line_number" ]; then
        echo "Error: Invalid task identifier '$target_id'." >&2
        return 1
    fi

    if [ ! -f "$path" ]; then
        echo "Error: File not found: $path" >&2
        return 1
    fi

    if ! [[ "$line_number" =~ ^[0-9]+$ ]]; then
        line_number=1
    fi

    local editor_cmd="${EDITOR:-${VISUAL:-}}"
    local prefer_gui="${TODO_PREFER_GUI_OPEN:-${TODO_RAYCAST_CONTEXT:-}}"

    if _should_use_editor_launcher "$prefer_gui" "$editor_cmd"; then
        if open_file_at_position "$editor_cmd" "$path" "$line_number"; then
            return 0
        fi
        echo "Warning: Failed to launch \$EDITOR ($editor_cmd). Falling back to GUI opener." >&2
    fi

    if _open_with_gui_launcher "$path" "$line_number"; then
        return 0
    fi

    echo "Error: Could not launch any editor for $path (configure EDITOR/VISUAL or TODO_PREFER_GUI_OPEN)." >&2
    return 1
}

_should_use_editor_launcher() {
    local prefer_gui="$1"
    local editor_cmd="$2"

    if [ -n "$prefer_gui" ]; then
        local normalized
        normalized=$(printf "%s" "$prefer_gui" | tr '[:upper:]' '[:lower:]')
        case "$normalized" in
            1|true|yes|on)
                return 1
                ;;
        esac
    fi

    [ -n "$editor_cmd" ]
}

_open_with_gui_launcher() {
    local file_path="$1"
    local line_number="${2:-1}"

    if command -v code >/dev/null 2>&1; then
        code --goto "${file_path}:${line_number}" >/dev/null 2>&1 &
        return 0
    fi

    if command -v cursor >/dev/null 2>&1; then
        cursor --goto "${file_path}:${line_number}" >/dev/null 2>&1 &
        return 0
    fi

    if command -v subl >/dev/null 2>&1; then
        subl "${file_path}:${line_number}" >/dev/null 2>&1 &
        return 0
    fi

    if command -v open >/dev/null 2>&1; then
        open "$file_path"
        return 0
    fi

    if command -v xdg-open >/dev/null 2>&1; then
        xdg-open "$file_path" >/dev/null 2>&1 &
        return 0
    fi

    return 1
}
