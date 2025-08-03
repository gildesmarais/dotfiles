#!/bin/bash
set -euo pipefail

# Handles opening files in the user's configured text editor.

open_file_at_position() {
    local editor_cmd="$1"
    local file_path="$2"
    local line_number="$3"
    local column_number="${4:-1}"

    case "$(basename "$editor_cmd")" in
        vim|vi)
            "$editor_cmd" "+call cursor($line_number, $column_number)" "$file_path"
            ;;
        code)
            "$editor_cmd" --wait --goto "$file_path:$line_number:$column_number"
            ;;
        nano)
            "$editor_cmd" "+$line_number,$column_number" "$file_path"
            ;;
        *)
            "$editor_cmd" "+$line_number" "$file_path"
            ;;
    esac
}
