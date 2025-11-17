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

EOF
}

ensure_note_structure() {
    # Header-agnostic: no-op for backward compatibility
    true
}

_to_iso_date() {
    local input_date="$1"
    if [[ "$input_date" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
        printf "%s\n" "$input_date"
    elif [[ "$input_date" =~ ^[0-9]{8}$ ]]; then
        printf "%s-%s-%s\n" "${input_date:0:4}" "${input_date:4:2}" "${input_date:6:2}"
    else
        printf "%s\n" "$input_date"
    fi
}

note_path_for_date() {
    local raw_date="$1"
    local iso_date
    iso_date=$(_to_iso_date "$raw_date")
    local compact_date="${iso_date//-/}"
    local candidates=(
        "$NOTE_DIR/$iso_date.md"
    )
    if [ "$compact_date" != "$iso_date" ]; then
        candidates+=("$NOTE_DIR/$compact_date.md")
    fi

    local candidate
    for candidate in "${candidates[@]}"; do
        if [ -f "$candidate" ]; then
            printf "%s\n" "$candidate"
            return 0
        fi
    done
    return 1
}

offset_date() {
    local offset_raw="${1:-0}"
    local format="${2:-%F}"
    local offset=$((offset_raw))

    if date -v-1d +"$format" >/dev/null 2>&1; then
        if [ "$offset" -ge 0 ]; then
            date -v+"${offset}"d +"$format"
        else
            date -v"${offset}"d +"$format"
        fi
        return 0
    fi

    if date -d '1 day ago' +"$format" >/dev/null 2>&1; then
        date -d "${offset} days" +"$format"
        return 0
    fi

python3 - <<PY
from datetime import date, timedelta
print((date.today() + timedelta(days=int("${offset}"))).strftime("${format}"))
PY
}

add_todo_item() {
    local note_path="$1"
    local item="$2"
    local date_str="$3"
    local todo_line="- [ ] $item"

    if [ ! -f "$note_path" ]; then
        create_new_note "$note_path" "$date_str" || { _verbose_echo "Error: Failed to create new note file." >&2; return 1; }
    fi

    # Header-agnostic: append at EOF
    printf "%s\n" "$todo_line" >> "$note_path" || { _verbose_echo "Error: Failed to append todo item." >&2; return 1; }

    _verbose_echo "Added new to-do item: \"$item\" to $note_path"

    # Auto-sync with git if enabled
    _auto_git_sync "$note_path" "$item"

    return 0
}

_find_git_root() {
    local target_path="$1"
    local current_dir

    if [ -z "${target_path:-}" ]; then
        return 1
    fi

    if [ -d "$target_path" ]; then
        current_dir="$target_path"
    else
        current_dir="$(dirname "$target_path")"
    fi

    while [ -n "$current_dir" ]; do
        if [ -d "$current_dir/.git" ]; then
            echo "$current_dir"
            return 0
        fi
        if [ "$current_dir" = "/" ]; then
            break
        fi
        current_dir="$(dirname "$current_dir")"
    done
    return 1
}

_git_pull() {
    local note_dir="$1"

    # Check if auto-sync is enabled
    [ "${TODO_AUTO_GIT_SYNC:-false}" = "true" ] || return 0

    # Find git root and pull
    local git_root
    git_root="$(_find_git_root "$note_dir")" || return 0

    # Always pull first (merge strategy, never conflicts)
    _verbose_echo "Pulling latest changes..."

    (cd "$git_root" && git pull --quiet)
}

_auto_git_sync() {
    local note_path="$1"
    local item="$2"

    # Check if auto-sync is enabled
    [ "${TODO_AUTO_GIT_SYNC:-false}" = "true" ] || return 0

    # Find git root from the note file's location
    local git_root
    git_root="$(_find_git_root "$note_path")" || {
        _verbose_echo "No git repository found for $note_path"
        return 0
    }

    # Show basic status (always visible)
    echo "Syncing with git..."

        # Calculate relative path manually (macOS compatible)
        local relative_path="${note_path#"$git_root"/}"

        # Check for unstaged changes and stash them if needed
        local has_stash=false
        if ! git -C "$git_root" diff --quiet || ! git -C "$git_root" diff --cached --quiet; then
            _verbose_echo "Stashing unstaged changes for clean pull..."
            if ! git -C "$git_root" stash push --quiet --include-untracked --message "Auto-stash before todo sync"; then
                _verbose_echo "Warning: Failed to stash changes, continuing without stashing"
            else
                has_stash=true
            fi
        fi

        # Always pull first (merge strategy, never conflicts)
        _verbose_echo "Pulling latest changes..."
        _git_pull "$git_root"

        # Restore stashed changes if we had any
        if [ "$has_stash" = true ]; then
            _verbose_echo "Restoring stashed changes..."
            git -C "$git_root" stash pop --quiet || {
                echo "Warning: Could not restore stashed changes"
            }
        fi

        # Now add our new todo item and commit
        if ! git -C "$git_root" add "$relative_path"; then
            _verbose_echo "Warning: Failed to add file to git"
            return 1
        fi

        if ! git -C "$git_root" commit -m "Add todo: $item" --quiet; then
            _verbose_echo "Warning: Failed to commit changes"
            return 1
        fi

        if ! git -C "$git_root" push --quiet; then
            _verbose_echo "Warning: Failed to push changes"
            return 1
        fi

        echo "Git sync completed"
}

open_file_at_position() {
    local editor_cmdline="$1"
    local file_path="$2"
    local line_number="${3:-1}"

    if [ -z "${editor_cmdline:-}" ]; then
        echo "Error: EDITOR is not set." >&2
        return 1
    fi

    if [ -z "${file_path:-}" ]; then
        echo "Error: No file path provided to open_file_at_position." >&2
        return 1
    fi

    if [ -z "${line_number:-}" ] || ! [[ "$line_number" =~ ^[0-9]+$ ]]; then
        line_number=1
    fi

    # Split potential multi-word EDITOR into command + args
    read -r -a editor_parts <<< "$editor_cmdline"
    local editor_bin="${editor_parts[0]}"
    local editor_args=("${editor_parts[@]:1}")

    case "$(basename "$editor_bin")" in
        code|code-insiders|subl)
            editor_args+=("-g" "$file_path:$line_number")
            ;;
        *)
            editor_args+=("+${line_number}" "$file_path")
            ;;
    esac

    "$editor_bin" "${editor_args[@]}"
}

auto_commit_if_enabled() {
    local auto_commit_flag="$1"
    local note_dir="$2"
    local note_path="$3"
    local date_str="$4"

    [ "${auto_commit_flag:-false}" = "true" ] || return 0

    local git_root
    git_root="$(_find_git_root "$note_dir")" || {
        _verbose_echo "Auto-commit requested but no git repository detected."
        return 0
    }

    local relative_path="${note_path#"$git_root"/}"

    if ! git -C "$git_root" add "$relative_path"; then
        _verbose_echo "Auto-commit: failed to add $relative_path"
        return 1
    fi

    if ! git -C "$git_root" commit -m "Update note: $date_str" --quiet; then
        _verbose_echo "Auto-commit: commit skipped (no changes?)."
        return 0
    fi

    _verbose_echo "Auto-commit: saved note changes."
}
