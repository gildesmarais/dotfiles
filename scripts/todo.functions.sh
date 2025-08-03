#!/bin/bash
set -euo pipefail

# ==========================================================
# Functions for the todo.sh script.
# Sourced by the main script and not meant to be run directly.
# ==========================================================

# --- Configuration ---
# All user-configurable settings are here.
# They can be overridden with environment variables.
_config() {
    # Set the directory where you want to store your daily notes.
    NOTE_DIR="${TODO_NOTE_DIR:-/$HOME/Documents/notes/daily}"

    # Set the current date for daily notes.
    DATE=$(date +%Y-%m-%d)
    NOTE_PATH="$NOTE_DIR/$DATE.md"

    # Set your preferred text editor.
    EDITOR="${EDITOR:-vim}"

    # Enable Git auto-commit? Set to "true" or "false".
    TODO_AUTO_COMMIT="${TODO_AUTO_COMMIT:-false}"

    # Automatically use glow for prettier markdown output if the command is found.
    if command -v glow &> /dev/null; then
        DEFAULT_GLOW_STATUS="true"
    else
        DEFAULT_GLOW_STATUS="false"
    fi
    TODO_USE_GLOW="${TODO_USE_GLOW:-$DEFAULT_GLOW_STATUS}"

    # Check for fzf, fall back to a simple menu if not found.
    if command -v fzf &> /dev/null; then
        FZF_INSTALLED=true
    else
        FZF_INSTALLED=false
    fi
}

# --- Utility Functions ---

# Function to display a message only if VERBOSE_FLAG is true.
_verbose_echo() {
    if [ "$VERBOSE_FLAG" == "true" ]; then
        echo "$@"
    fi
}

# Function to check for required command-line tools.
_check_dependencies() {
    local dependencies=("awk" "grep" "sed" "date" "yq")
    if [ "$FZF_INSTALLED" = true ]; then
        dependencies+=("fzf")
    fi
    if [ "$TODO_AUTO_COMMIT" = true ]; then
        dependencies+=("git")
    fi

    # Check for glow specifically, and handle fallback if not found.
    if [ "$TODO_USE_GLOW" = true ]; then
        if ! command -v glow &> /dev/null; then
            echo "Warning: 'glow' not found. Falling back to plain text output." >&2
            TODO_USE_GLOW="false" # Disable glow for this session
        else
            # If glow is found and TODO_USE_GLOW is true, add it to dependencies to be checked.
            dependencies+=("glow")
        fi
    fi

    for cmd in "${dependencies[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            echo "Error: Required command not found: '$cmd'" >&2
            exit 1
        fi
    done
}

# --- Core Functions ---

# Function to display the help message.
show_help() {
    cat <<EOF
Usage: todo [COMMAND] [OPTIONS] [TODO_ITEMS]

Commands:
  (default)           Launches an interactive menu.
  add [items]         Adds one or more tasks to the daily note.
  list [scope]        Displays tasks. Scope can be 'today' (default), 'week', or 'all'.
  motd                Displays today's to-do list, for shell startup.
  edit                Opens the daily note in your editor, cursor at first task.
  note                Opens the daily note, cursor at the end of the file.
  filter              Interactively fuzzy search all open tasks.
  meta list           Display front matter for today's note.
  meta set <k> <v>    Set a front matter key-value pair.
  help                Show this help message.

Options:
  -v, --verbose       Display verbose output during script execution.

Examples:
  todo
  todo add "Buy groceries #errands"
  todo list
  todo list week
  todo list all
  todo edit
  todo motd
  todo filter
  todo meta set mood focused
  todo meta set tags "deep-work,project-a"
EOF
}

# Function to exit the script gracefully.
exit_gracefully() {
    _verbose_echo "Exiting..."
    exit 0
}

# Function to add a to-do item to the note.
# This version is simpler and avoids complex awk.
add_todo_item() {
    local item="$1"
    local todo_line="- [ ] $item"
    if [ ! -f "$NOTE_PATH" ]; then
        create_new_note || { _verbose_echo "Error: Failed to create new note file." >&2; return 1; }
    fi

    _ensure_note_structure || { _verbose_echo "Error: Failed to ensure note structure." >&2; return 1; }

    # Use sed to insert the new to-do item after the "## To-Do" line.
    set +e # Temporarily disable exit on error for sed
    sed -i.bak "/## To-Do/a\\$todo_line" "$NOTE_PATH"
    local sed_status=$?
    set -e # Re-enable exit on error

    if [ "$sed_status" -ne 0 ]; then
        _verbose_echo "Error: sed failed to insert todo item (status: $sed_status). Attempting to append." >&2
        echo "$todo_line" >> "$NOTE_PATH" || { _verbose_echo "Error: Failed to append todo item as fallback." >&2; return 1; }
        _verbose_echo "Warning: sed failed, appended item to end of file as fallback."
    fi
    rm -f "$NOTE_PATH.bak" # Use -f to prevent error if .bak file doesn't exist

    _verbose_echo "Added new to-do item: \"$item\" to $NOTE_PATH"
    return 0
}

# Function to create a new daily note file.
create_new_note() {
    _verbose_echo "Creating new daily note: $NOTE_PATH"
    cat <<EOF > "$NOTE_PATH"
---
---
# Daily Note for $DATE

## To-Do


## Notes


EOF
}

# Function to open a file at a specific line and column.
open_file_at_position() {
    local file_path="$1"
    local line_number="$2"
    local column_number="${3:-1}" # Default to column 1 if not provided.

    case "$(basename "$EDITOR")" in
        vim|vi)
            "$EDITOR" "+call cursor($line_number, $column_number)" "$file_path"
            ;;
        code)
            "$EDITOR" --goto "$file_path:$line_number:$column_number"
            ;;
        nano)
            "$EDITOR" "+$line_number,$column_number" "$file_path"
            ;;
        *)
            # Fallback for any other editor (column positioning may not be supported).
            "$EDITOR" "+$line_number" "$file_path"
            ;;
    esac
}

# Function to open the daily note with the cursor at the last line.
cmd_note() {
    if [ ! -f "$NOTE_PATH" ]; then
        create_new_note
    fi

    # Get the total number of lines in the file.
    local LAST_LINE
    LAST_LINE=$(wc -l < "$NOTE_PATH" | tr -d ' ')
    # If the file is empty, wc -l returns 0, but we want to be on line 1.
    if [ "$LAST_LINE" -eq 0 ]; then
        LAST_LINE=1
    fi

    open_file_at_position "$NOTE_PATH" "$LAST_LINE"
    auto_commit_if_enabled
}

# Function to ensure the note has the basic structure (e.g., ## To-Do, ## Notes).
_ensure_note_structure() {
    if ! grep -q "## To-Do" "$NOTE_PATH"; then
        _verbose_echo "Adding missing '## To-Do' and '## Notes' sections to $NOTE_PATH"
        cat <<EOF >> "$NOTE_PATH"

## To-Do


## Notes


EOF
    fi
}

# Function to handle opening the editor.
cmd_edit() {
    if [ ! -f "$NOTE_PATH" ]; then
        create_new_note
    fi
    _ensure_note_structure

    # Find the line number of the first to-do item. Prioritize high-priority items.
    local CURSOR_LINE_NUMBER
    CURSOR_LINE_NUMBER=$(grep -n '^- \[ \] !' "$NOTE_PATH" | head -n 1 | cut -d: -f1)

    # If no high-priority items are found, look for the first regular to-do item.
    if [ -z "$CURSOR_LINE_NUMBER" ]; then
        CURSOR_LINE_NUMBER=$(grep -n '^- \[ \]' "$NOTE_PATH" | head -n 1 | cut -d: -f1)
    fi

    # If no to-do items are found, fall back to the `## To-Do` line + 1.
    if [ -z "$CURSOR_LINE_NUMBER" ]; then
        CURSOR_LINE_NUMBER=$(grep -n '## To-Do' "$NOTE_PATH" | cut -d: -f1)
        if [ -n "$CURSOR_LINE_NUMBER" ]; then
            CURSOR_LINE_NUMBER=$((CURSOR_LINE_NUMBER + 1))
        else
            # If nothing is found, default to the start of the file.
            CURSOR_LINE_NUMBER=1
        fi
    fi

    open_file_at_position "$NOTE_PATH" "$CURSOR_LINE_NUMBER"
    auto_commit_if_enabled
}

# Function to handle Git auto-commit.
auto_commit_if_enabled() {
    if [ "$TODO_AUTO_COMMIT" == "true" ]; then
        # Check if NOTE_DIR is part of a Git repository by finding the repo root.
        local git_root
        git_root=$(git -C "$NOTE_DIR" rev-parse --show-toplevel 2>/dev/null)

        if [ -n "$git_root" ]; then
            _verbose_echo "Auto-committing changes..."
            # Use the discovered git_root for all git operations.
            git -C "$git_root" add "$NOTE_PATH" || _verbose_echo "Warning: git add failed."
            # Check if there are changes to commit before committing
            if ! git -C "$git_root" diff --staged --quiet; then
                git -C "$git_root" commit -m "Updated daily note for $DATE" || _verbose_echo "Warning: git commit failed."
                _verbose_echo "Changes committed to Git."
            else
                _verbose_echo "No changes to commit."
            fi
        else
            _verbose_echo "Git auto-commit is enabled, but $NOTE_DIR is not in a Git repository."
        fi
    fi
}


# Function for the fzf-powered interactive dashboard.
interactive_mode() {
    while true; do
        # Ensure the note file exists before we start.
        if [ ! -f "$NOTE_PATH" ]; then
            create_new_note
        fi

        # Get all open tasks with their line numbers, format them for display.
        local tasks
        tasks=$(grep -n '^- \[ \]' "$NOTE_PATH" 2>/dev/null | sed 's/^\([0-9]*\):- \[ \] !/\1: - [!] /; s/^\([0-9]*\):- \[ \] /\1: - [ ] /' || true)

        # Use fzf for the interactive part.
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
            --expect=ctrl-d,ctrl-n,enter) || true # Add || true to prevent fzf's non-zero exit from terminating script

        # If fzf is exited (e.g., with Esc) and selection is empty, break the loop.
        # This check is now more robust due to || true on fzf command.
        if [ -z "$selection" ]; then
            _verbose_echo "fzf exited without selection."
            break
        fi

        # The first line is the key, the second is the query.
        local query=""
        local key=""
        local chosen_tasks=()
        local line_num=0

        # Read fzf output line by line
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
            # Add a new task if text was entered.
            if [ -n "$query" ]; then
                _verbose_echo "Attempting to add task: '$query'"
                if add_todo_item "$query"; then
                    echo "Added: $query"
                    auto_commit_if_enabled || _verbose_echo "Failed to auto-commit after adding task." >&2
                else
                    _verbose_echo "Failed to add task: '$query'" >&2
                fi
            else
                _verbose_echo "No query entered to add."
            fi
            continue # Always refresh the list after Ctrl-N, even if query was empty
        elif [ "$key" = "enter" ]; then
            if [ ${#chosen_tasks[@]} -gt 0 ]; then
                # If a task was selected, open it for editing.
                local line_number
                line_number=$(echo "${chosen_tasks[0]}" | cut -d: -f1)
                if [ -n "$line_number" ]; then
                    open_file_at_position "$NOTE_PATH" "$line_number" 5
                else
                    _verbose_echo "Could not determine line number for selected task."
                fi
            else
                _verbose_echo "No task selected to edit."
            fi
            continue # Always refresh the list after Enter, regardless of action taken
        elif [ "$key" = "ctrl-d" ]; then
            # Mark selected tasks as done.
            if [ ${#chosen_tasks[@]} -gt 0 ]; then
                for task in "${chosen_tasks[@]}"; do
                    local line_number
                    line_number=$(echo "$task" | cut -d: -f1)
                    if [ -n "$line_number" ]; then
                        set +e # Temporarily disable exit on error for sed
                        sed -i.bak "${line_number}s/^- \[ \]/- [x]/" "$NOTE_PATH"
                        local sed_status=$?
                        set -e # Re-enable exit on error

                        if [ "$sed_status" -ne 0 ]; then
                            _verbose_echo "Error: sed failed to mark task as done (status: $sed_status): $task" >&2
                        else
                            _verbose_echo "Marked line $line_number as done."
                        fi
                        rm -f "$NOTE_PATH.bak" # Use -f to prevent error if .bak file doesn't exist
                    else
                        _verbose_echo "Could not determine line number for task to mark as done: $task" >&2
                    fi
                done
                auto_commit_if_enabled || _verbose_echo "Failed to auto-commit after marking tasks done." >&2
            else
                 _verbose_echo "No tasks selected to mark as done."
            fi
            continue # Always refresh the list after Ctrl-D, even if no tasks were selected
        fi
        # If we get here, it means no action was taken that should loop, so break.
        break
    done
}


# --- Command Functions ---

# Helper function to find and print open tasks from a file.
_find_open_tasks_in_file() {
    local file_path="$1"
    local date_header="$2"

    # Check if the file contains any open tasks before printing the header.
    if grep -q '^- \[ \]' "$file_path"; then
        echo "## $date_header"
        # Grep for open tasks, then format them for display.
        grep '^- \[ \]' "$file_path" | sed 's/^- \[ \] !/  - [!] /; s/^- \[ \] /  - [ ] /'
        echo # Add a blank line for spacing
    fi
}

# The `list` command displays to-do lists based on a scope.
cmd_list() {
    local scope="${1:-today}" # Default to 'today' if no scope is provided.

    if [ "$scope" = "today" ]; then
        _verbose_echo "Displaying to-do list for today..."
        if [ -f "$NOTE_PATH" ]; then
            echo "## To-Do List for $DATE"
            # Use awk to extract just the To-Do section.
            awk '/## To-Do/{p=1; next}/^##/{p=0} p' "$NOTE_PATH" | sed 's/^- \[ \] !/  - [!] /; s/^- \[ \] /  - [ ] /' | if [ "$TODO_USE_GLOW" == "true" ]; then glow; else cat; fi
        else
            _verbose_echo "Daily note not found: $NOTE_PATH"
            echo "No to-do list found for today."
        fi
    elif [ "$scope" = "week" ]; then
        _verbose_echo "Generating weekly agenda..."
        for i in {0..6}; do
            local date
            date=$(date -v-"${i}"d +%Y-%m-%d)
            local note_path="$NOTE_DIR/$date.md"
            if [ -f "$note_path" ]; then
                _find_open_tasks_in_file "$note_path" "$date" | if [ "$TODO_USE_GLOW" == "true" ]; then glow; else cat; fi
            fi
        done
    elif [ "$scope" = "all" ]; then
        _verbose_echo "Scanning for all open to-do items..."
        find "$NOTE_DIR" -type f -name "*.md" | sort -r | while read -r file; do
            local filename
            filename=$(basename "$file")
            local date_from_file="${filename%.md}"
            _find_open_tasks_in_file "$file" "$date_from_file" | if [ "$TODO_USE_GLOW" == "true" ]; then glow; else cat; fi
        done
    else
        echo "Error: Unknown list scope '$scope'. Use 'today', 'week', or 'all'." >&2
        show_help
        exit 1
    fi
}

# The `motd` command displays today's to-do list without color codes.
cmd_motd() {
    # Temporarily disable glow for motd command to avoid color escape sequences.
    local old_glow_status=$TODO_USE_GLOW
    TODO_USE_GLOW="false"
    cmd_list "today" | grep '^- \[ \]'
    TODO_USE_GLOW=$old_glow_status
}

# The `add` command adds a new task.
cmd_add() {
    # Add items if they were provided.
    if [ ${#TODO_ITEMS[@]} -gt 0 ]; then
        for item in "${TODO_ITEMS[@]}"; do
            add_todo_item "$item"
            echo "Added: $item"
        done
    fi
    auto_commit_if_enabled
}

# --- Front Matter Functions ---

# The `meta` command handles front matter operations.
cmd_meta() {
    local sub_command="$1"
    shift

    case "$sub_command" in
        list)
            cmd_meta_list
            ;;
        set)
            cmd_meta_set "$@"
            ;;
        *)
            echo "Error: Unknown meta command '$sub_command'" >&2
            show_help
            exit 1
            ;;
    esac
}

# The `meta list` command displays the front matter.
cmd_meta_list() {
    if [ ! -f "$NOTE_PATH" ]; then
        echo "No note for today. Nothing to list."
        exit 0
    fi

    _verbose_echo "Extracting front matter from $NOTE_PATH"
    yq eval 'select(document_index == 0)' "$NOTE_PATH"
}

# The `meta set` command adds or updates a key-value pair in the front matter.
cmd_meta_set() {
    local key="$1"
    local value="$2"

    if [ -z "$key" ] || [ -z "$value" ]; then
        echo "Error: 'meta set' requires a key and a value." >&2
        show_help
        exit 1
    fi

    if [ ! -f "$NOTE_PATH" ]; then
        create_new_note
    fi

    _verbose_echo "Setting front matter key '$key' to '$value' in $NOTE_PATH"

    # If the key is 'tags', split the comma-separated string into a YAML sequence.
    if [ "$key" == "tags" ]; then
        yq eval -i "select(document_index == 0).$key = (\"$value\" | split(\",\"))" "$NOTE_PATH"
    else
        yq eval -i "select(document_index == 0).$key = \"$value\"" "$NOTE_PATH"
    fi

    _verbose_echo "Front matter updated."
    auto_commit_if_enabled
}

# The `filter` command provides an interactive fuzzy search over all open tasks.
cmd_filter() {
    _verbose_echo "Scanning for open to-do items..."

    # Aggregate all open to-do items and prepend the file path.
    local tasks
    tasks=$(find "$NOTE_DIR" -type f -name "*.md" -exec awk '/^- \[ \]/{print FILENAME ":" $0}' {} + | sort)

    if [ -z "$tasks" ]; then
        echo "No open tasks found."
        exit 0
    fi

    # Use fzf to interactively select a task.
    local selected_task
    selected_task=$(echo "$tasks" | fzf --prompt="Fuzzy search tasks: " --delimiter=":" --with-nth=2..)

    if [ -n "$selected_task" ]; then
        # Extract the file path and the task content.
        local file_path
        file_path=$(echo "$selected_task" | cut -d: -f1)
        local task_content
        task_content=$(echo "$selected_task" | cut -d: -f2-)

        # Find the line number of the task in the file.
        local line_number
        line_number=$(grep -nF -- "$task_content" "$file_path" | cut -d: -f1)

        if [ -n "$line_number" ]; then
            open_file_at_position "$file_path" "$line_number" 5
        else
            echo "Error: Could not find the selected task in the file." >&2
            exit 1
        fi
    fi
}
