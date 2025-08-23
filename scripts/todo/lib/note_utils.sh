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
    local note_path="$1"
    local current_dir
    current_dir="$(dirname "$note_path")"

    # Walk up the directory tree to find .git, stop at $HOME
    while [ "$current_dir" != "/" ] && [ -n "$current_dir" ] && [ "$current_dir" != "$HOME" ]; do
        if [ -d "$current_dir/.git" ]; then
            echo "$current_dir"
            return 0
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
