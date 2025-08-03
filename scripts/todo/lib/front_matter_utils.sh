#!/bin/bash
set -euo pipefail

# Helper functions for reading and writing YAML front matter using yq.

list_front_matter() {
    local note_path="$1"

    if [ ! -f "$note_path" ]; then
        echo "No note for today. Nothing to list."
        return 0
    fi

    yq eval --front-matter=extract '.' "$note_path"
}

set_front_matter() {
    local note_path="$1"
    local key="$2"
    local value="$3"
    local date_str="$4"

    if [ -z "$key" ] || [ -z "$value" ]; then
        echo "Error: 'meta set' requires a key and a value." >&2
        return 1
    fi

    if [ ! -f "$note_path" ]; then
        create_new_note "$note_path" "$date_str"
    fi

    if ! head -n 1 "$note_path" | grep -q -- "---"; then
        _verbose_echo "No front matter found. Creating it."
        local temp_file
        temp_file=$(mktemp)
        echo -e "---\n---" | cat - "$note_path" > "$temp_file" && mv "$temp_file" "$note_path"
    fi

    _verbose_echo "Setting front matter key '$key' to '$value' in $note_path"

    local expression
    if [ "$key" == "tags" ]; then
        expression=".$key = (\"$value\" | split(\",\"))"
    else
        expression=".$key = \"$value\""
    fi

    yq eval -i --front-matter=process "$expression" "$note_path"

    _verbose_echo "Front matter updated."
}
