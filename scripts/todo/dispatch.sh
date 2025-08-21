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
    elif [ "$command" = "help" ]; then
        show_help
    else
        echo "Error: Unknown command '$command'" >&2
        show_help
        return 1
    fi
}

_verbose_echo() {
    if [ "${VERBOSE_FLAG:-false}" = "true" ]; then
        echo "$@"
    fi
}

show_help() {
    cat <<EOF
Usage: todo [COMMAND] [OPTIONS] [TODO_ITEMS]

Commands:
  add [items]         Adds one or more tasks to the daily note.
  list [scope]        Displays tasks. Scope can be 'today' (default), 'week', or 'all'.
                      Use -o (open only), -a (all states), -d (done only) to filter.
  motd                Displays today's to-do list, for shell startup.
  done                Fuzzy-pick open tasks (from all notes) and mark them done.
  help                Show this help message.

Options:
  -v, --verbose       Display verbose output during script execution.

Examples:
  todo
  todo add "Buy groceries #errands"
  todo list
  todo list week
  todo list all
  todo list -o        # today: show *o*pen tasks
  todo list -a week   #  week: show *a*ll tasks (open and done)
  todo list -d        # today: show *d*one tasks
  todo motd
  todo done
EOF
}

exit_gracefully() {
    _verbose_echo "Exiting..."
    exit 0
}
