#!/bin/bash
set -euo pipefail

# Helper functions for Git operations, specifically for the auto-commit feature.

auto_commit_if_enabled() {
    local auto_commit_enabled="$1"
    local note_dir="$2"
    local note_path="$3"
    local date_str="$4"

    if [ "$auto_commit_enabled" != "true" ]; then
        return 0
    fi

    local git_root
    git_root=$(git -C "$note_dir" rev-parse --show-toplevel 2>/dev/null)

    if [ -z "$git_root" ]; then
        _verbose_echo "Git auto-commit is enabled, but $note_dir is not in a Git repository."
        return 0
    fi

    _verbose_echo "Auto-committing changes..."
    git -C "$git_root" add "$note_path" || _verbose_echo "Warning: git add failed."

    if ! git -C "$git_root" diff --staged --quiet; then
        git -C "$git_root" commit -m "Updated daily note for $date_str" || _verbose_echo "Warning: git commit failed."
        _verbose_echo "Changes committed to Git."
        TODO_CHANGES_MADE="true"
    else
        _verbose_echo "No changes to commit."
    fi
}

git_push_resiliently() {
    local auto_push_enabled="$1"
    local note_dir="$2"
    local date_str="$3"

    if [ "$auto_push_enabled" != "true" ] || [ "$TODO_CHANGES_MADE" != "true" ]; then
        _verbose_echo "Skipping auto-push: auto-push not enabled or no changes were made by the script."
        return 0
    fi

    local git_root
    git_root=$(git -C "$note_dir" rev-parse --show-toplevel 2>/dev/null)

    if [ -z "$git_root" ]; then
        _verbose_echo "Git auto-push is enabled, but $note_dir is not in a Git repository."
        return 0
    fi

    local local_branch
    local_branch=$(git -C "$git_root" rev-parse --abbrev-ref HEAD)
    local upstream_branch
    upstream_branch=$(git -C "$git_root" rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null || echo "")

    if [ -z "$upstream_branch" ]; then
        _verbose_echo "No upstream branch configured for '$local_branch'. Skipping auto-push."
        return 0
    fi

    if ! git -C "$git_root" diff --quiet "$upstream_branch" "$local_branch" || \
       ! git -C "$git_root" diff --quiet "$local_branch" "$upstream_branch"; then
        _verbose_echo "Local branch '$local_branch' has unpushed commits or is behind '$upstream_branch'. Proceeding with pull/push."
        _verbose_echo "Attempting to pull and rebase before pushing..."
        if git -C "$git_root" pull --autostash --rebase; then
            _verbose_echo "Successfully pulled and rebased. Now pushing..."
            if git -C "$git_root" push; then
                _verbose_echo "Changes pushed to remote."
            else
                _verbose_echo "Warning: git push failed."
            fi
        else
            _verbose_echo "Warning: git pull --rebase failed. Skipping push."
        fi
    else
        _verbose_echo "No new commits to push or pull. Skipping auto-push."
    fi
}
