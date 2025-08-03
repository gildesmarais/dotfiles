# This file contains all the core functions for the todo.sh script.
# It should be sourced by the main script and not run directly.

# Function to display the help message.
show_help() {
    cat <<EOF
Usage: todo [COMMAND] [OPTIONS] [TODO_ITEMS]

Commands:
  (default)           Launches an interactive menu.
  add [items]         Adds one or more tasks and opens the daily note.
  list                Displays today's to-do list.
  motd                Displays today's to-do list, for shell startup.
  edit                Opens the daily note in your editor.
  open                Displays all open to-do items across all notes.
  help                Show this help message.

Options:
  -v, --verbose       Display verbose output during script execution.

Examples:
  todo
  todo add "Buy groceries #errands"
  todo open
  todo edit
  todo motd
EOF
}

# Function to exit the script gracefully.
exit_gracefully() {
    if [ "$VERBOSE_FLAG" == "true" ]; then
        echo "Exiting..."
    fi
    exit 0
}

# Function to add a to-do item to the note using `awk`.
add_todo_item() {
    local item="$1"
    local todo_line="- [ ] $item"
    if [ ! -f "$NOTE_PATH" ]; then
        create_new_note
    fi
    awk -v todo_line="$todo_line" '1; /## To-Do/{print todo_line}' "$NOTE_PATH" > "$NOTE_PATH.tmp" && mv "$NOTE_PATH.tmp" "$NOTE_PATH"
    if [ "$VERBOSE_FLAG" == "true" ]; then
        echo "Added new to-do item: \"$item\""
    fi
}

# Function to create a new daily note file.
create_new_note() {
    if [ "$VERBOSE_FLAG" == "true" ]; then
        echo "Creating new daily note: $NOTE_PATH"
    fi
    cat <<EOF > "$NOTE_PATH"
# Daily Note for $DATE

## To-Do

## Notes

EOF
}

# Function to handle opening the editor.
open_editor() {
    if [ ! -f "$NOTE_PATH" ]; then
        create_new_note
    fi

    # Find the line number of the first to-do item. Prioritize high-priority items.
    local CURSOR_LINE_NUMBER=$(grep -n '^- \[ \] !' "$NOTE_PATH" | head -n 1 | cut -d: -f1)

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

    case "$(basename "$EDITOR")" in
        vim|vi)
            exec "$EDITOR" "+$CURSOR_LINE_NUMBER" "$NOTE_PATH"
            ;;
        code)
            exec "$EDITOR" --goto "$NOTE_PATH:$CURSOR_LINE_NUMBER:1"
            ;;
        nano)
            exec "$EDITOR" +$CURSOR_LINE_NUMBER "$NOTE_PATH"
            ;;
        *)
            # Fallback for any other editor.
            exec "$EDITOR" "$NOTE_PATH"
            ;;
    esac
}

# Function to handle Git auto-commit.
auto_commit_if_enabled() {
    if [ "$TODO_AUTO_COMMIT" == "true" ]; then
        if [ -d "$NOTE_DIR/.git" ]; then
            if [ "$VERBOSE_FLAG" == "true" ]; then
                echo "Auto-committing changes..."
            fi
            git -C "$NOTE_DIR" add "$NOTE_PATH"
            git -C "$NOTE_DIR" commit -m "Updated daily note for $DATE"
            if [ "$VERBOSE_FLAG" == "true" ]; then
                echo "Changes committed to Git."
            fi
        else
            if [ "$VERBOSE_FLAG" == "true" ]; then
                echo "Git auto-commit is enabled, but $NOTE_DIR is not a Git repository."
            fi
        fi
    fi
}


# Function for the `fzf`-powered interactive menu.
interactive_fzf_menu() {
    # Define main menu options
    local fzf_menu_options=("Add a new task" "Mark a task as done" "Open note in editor" "Exit")

    # Run fzf on the menu options.
    local choice=$(printf "%s\n" "${fzf_menu_options[@]}" | fzf --prompt="What would you like to do? ")

    # Handle the choice
    case "$choice" in
        "Add a new task")
            read -p "Enter new task: " new_task
            if [ -n "$new_task" ]; then
                add_todo_item "$new_task"
                echo "Added task: \"$new_task\""
                auto_commit_if_enabled
            else
                echo "Task cannot be empty."
            fi
            ;;
        "Mark a task as done")
            # Check if there are tasks to mark as done
            if [ -f "$NOTE_PATH" ] && grep '^- \[ \]' "$NOTE_PATH" > /dev/null; then
                # Get a list of the actual tasks to mark as done
                local tasks_to_do=$(grep '^- \[ \]' "$NOTE_PATH" | sed 's/^- \[ \] !/- [!] /' | fzf --prompt="Select tasks to mark as done: " --multi)

                if [ -n "$tasks_to_do" ]; then
                    while IFS= read -r line; do
                        # Find the line number of the selected task.
                        local line_number=$(grep -nF -- "$line" "$NOTE_PATH" | cut -d: -f1)
                        if [ -n "$line_number" ]; then
                            if [[ "$(uname)" == "Darwin" ]]; then
                                sed -i '' "${line_number}s/^- \[ \]/ - [x]/" "$NOTE_PATH"
                            else
                                sed -i "${line_number}s/^- \[ \]/ - [x]/" "$NOTE_PATH"
                            fi
                            if [ "$VERBOSE_FLAG" == "true" ]; then
                                echo "Marked \"$line\" as done."
                            fi
                        else
                            if [ "$VERBOSE_FLAG" == "true" ]; then
                                echo "Could not find task line. Something went wrong."
                            fi
                        fi
                    done <<< "$tasks_to_do"
                    auto_commit_if_enabled
                fi
            else
                echo "No open tasks to mark as done."
            fi
            ;;
        "Open note in editor")
            open_editor
            exit_gracefully
            ;;
        "Exit")
            exit_gracefully
            ;;
        *)
            # Handle invalid choice (e.g., user pressed escape)
            exit_gracefully
            ;;
    esac
}

# Function for the old `select`-based interactive menu.
interactive_select_menu() {
    if [ ! -f "$NOTE_PATH" ]; then
        create_new_note
    fi

    local tasks=()
    while IFS= read -r line; do
        tasks+=("$line")
    done < <(grep '^- \[ \]' "$NOTE_PATH" | sed 's/^- \[ \] !/- [!] /')

    PS3="Choose an action: "
    select option in "View today's tasks" "Add a new task" "Mark a task as done" "Open note in editor" "Exit"; do
        case "$option" in
            "View today's tasks")
                list_command
                ;;
            "Add a new task")
                read -p "Enter new task: " new_task
                if [ -n "$new_task" ]; then
                    add_todo_item "$new_task"
                    echo "Added task: \"$new_task\""
                    auto_commit_if_enabled
                else
                    echo "Task cannot be empty."
                fi
                ;;
            "Mark a task as done")
                if [ ${#tasks[@]} -eq 0 ]; then
                    echo "No open tasks to mark as done."
                else
                    echo "Pending tasks for today:"
                    select task_to_do in "${tasks[@]}"; do
                        if [ -n "$task_to_do" ]; then
                            local line_number=$(grep -nF "$task_to_do" "$NOTE_PATH" | cut -d: -f1)
                            if [ -n "$line_number" ]; then
                                if [[ "$(uname)" == "Darwin" ]]; then
                                    sed -i '' "${line_number}s/^- \[ \]/ - [x]/" "$NOTE_PATH"
                                else
                                    sed -i "${line_number}s/^- \[ \]/ - [x]/" "$NOTE_PATH"
                                fi
                                if [ "$VERBOSE_FLAG" == "true" ]; then
                                    echo "Marked \"$task_to_do\" as done."
                                fi
                                auto_commit_if_enabled
                            else
                                if [ "$VERBOSE_FLAG" == "true" ]; then
                                    echo "Could not find task line. Something went wrong."
                                fi
                            fi
                        else
                            echo "Invalid option. Please try again."
                        fi
                        break
                    done
                fi
                ;;
            "Open note in editor")
                open_editor
                ;;
            "Exit")
                exit_gracefully
                ;;
            *)
                echo "Invalid option. Please try again."
                ;;
        esac
    done
}


# --- Command-Specific Functions ---
# These wrap the core logic for the main script's case statement.

# The `list` command displays today's to-do list.
list_command() {
    if [ -f "$NOTE_PATH" ]; then
        if [ "$VERBOSE_FLAG" == "true" ]; then
            echo "Displaying to-do list for today..."
        fi
        awk -v date="$DATE" '
            BEGIN {
                print "## To-Do List for " date;
            }
            /## To-Do/{p=1; next}/^##/{p=0} p {
                if ($0 ~ /^- \[ \] !/) {
                    sub(/^- \[ \] !/, "- [!] ")
                }
                print
            }
        ' "$NOTE_PATH" | if [ "$TODO_USE_GLOW" == "true" ]; then glow; else cat; fi
    else
        if [ "$VERBOSE_FLAG" == "true" ]; then
            echo "Daily note not found: $NOTE_PATH"
        fi
        echo "No to-do list found for today."
    fi
}

# The `motd` command displays today's to-do list without color codes.
motd_command() {
    # Temporarily disable glow for motd command to avoid color escape sequences.
    local old_glow_status=$TODO_USE_GLOW
    TODO_USE_GLOW="false"
    list_command
    TODO_USE_GLOW=$old_glow_status
}

# The `open` command displays all open tasks across all notes.
open_command() {
    if [ "$VERBOSE_FLAG" == "true" ]; then
        echo "Scanning for open to-do items..."
    fi
    find "$NOTE_DIR" -type f -name "*.md" | sort | while read -r file; do
        local filename=$(basename "$file")
        local date_from_file="${filename%.md}"
        awk -v date="$date_from_file" '
            BEGIN {
                print "## " date;
            }
            /^- \[ \]/{
                if ($0 ~ /^- \[ \] !/) {
                    sub(/^- \[ \] !/, "- [!] ")
                } else {
                    sub(/^- \[ \] /, "- [ ] ")
                }
                print $0
            }
        ' "$file"
    done | if [ "$TODO_USE_GLOW" == "true" ]; then glow; else cat; fi
}

# The `add` command adds a new task and opens the editor.
add_command() {
    # Add items if they were provided.
    if [ ${#TODO_ITEMS[@]} -gt 0 ]; then
        for item in "${TODO_ITEMS[@]}"; do
            add_todo_item "$item"
        done
    fi
    auto_commit_if_enabled
    open_editor
}
