#!/bin/bash
set -euo pipefail

# Core helper functions for creating and manipulating note files and their content.

create_new_note() {
    local note_path="$1"
    local date_str="$2"

    _verbose_echo "Creating new daily note: $note_path"
    cat <<EOF > "$note_path"
---
---
# Daily Note for $date_str

## To-Do


## Notes


EOF
}

ensure_note_structure() {
    local note_path="$1"
    if ! grep -q "## To-Do" "$note_path"; then
        _verbose_echo "Adding missing '## To-Do' and '## Notes' sections to $note_path"
        cat <<EOF >> "$note_path"

## To-Do


## Notes


EOF
    fi
}

add_todo_item() {
    local note_path="$1"
    local item="$2"
    local date_str="$3"
    local todo_line="- [ ] $item"

    if [ ! -f "$note_path" ]; then
        create_new_note "$note_path" "$date_str" || { _verbose_echo "Error: Failed to create new note file." >&2; return 1; }
    fi

    ensure_note_structure "$note_path" || { _verbose_echo "Error: Failed to ensure note structure." >&2; return 1; }

    set +e
    sed -i.bak "/## To-Do/a\\
$todo_line
" "$note_path"
    local sed_status=$?
    set -e

    if [ "$sed_status" -ne 0 ]; then
        _verbose_echo "Error: sed failed to insert todo item (status: $sed_status). Appending as fallback." >&2
        echo "$todo_line" >> "$note_path" || { _verbose_echo "Error: Failed to append todo item." >&2; return 1; }
    fi
    rm -f "$note_path.bak"

    _verbose_echo "Added new to-do item: \"$item\" to $note_path"
    return 0
}
