#!/bin/bash
set -euo pipefail

# Routes commands to their respective handlers.

dispatch() {
    local command="$1"
    shift
    local handler="cmd_$command"

    if declare -F "$handler" > /dev/null; then
        _verbose_echo "Dispatching command '$command' to handler '$handler'."
        "$handler" "$@"
    else
        echo "Error: Unknown command '$command'" >&2
        show_help
        return 1
    fi
}

_verbose_echo() {
    if [ "$VERBOSE_FLAG" == "true" ]; then
        echo "$@"
    fi
}

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

exit_gracefully() {
    _verbose_echo "Exiting..."
    git_push_resiliently "$TODO_AUTO_PUSH" "$NOTE_DIR" "$DATE"
    exit 0
}
