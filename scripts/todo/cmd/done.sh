#!/bin/bash
set -euo pipefail

# Mark open tasks as done via fzf selection (header-agnostic, ignores code blocks).
cmd_done() {
	local ids=()

	while [ $# -gt 0 ]; do
		case "$1" in
			--ids)
				shift
				if [ $# -eq 0 ]; then
					echo "Error: '--ids' requires at least one identifier." >&2
					return 1
				fi
				while [ $# -gt 0 ]; do
					ids+=("$1")
					shift
				done
				;;
			*)
				echo "Error: Unknown option '$1' for 'todo done'." >&2
				return 1
				;;
		esac
	done

	if [ ${#ids[@]} -gt 0 ]; then
		_mark_done_by_ids "${ids[@]}"
		return 0
	fi

	if ! command -v fzf >/dev/null 2>&1; then
		echo "Error: 'fzf' is required for interactive 'todo done'." >&2
		return 1
	fi

	local candidates
	candidates=$(build_done_candidates "all") || true
	if [ -z "$candidates" ]; then
		echo "No open tasks found."
		return 0
	fi

	local selection
	selection=$(printf "%s\n" "$candidates" | fzf \
		--prompt="DONE > " \
		--height="80%" \
		--multi \
		--layout=reverse-list \
		--no-sort \
		--cycle \
		--bind 'tab:toggle,shift-tab:toggle+up' \
		--with-nth=2.. \
		--delimiter="\t") || true

	[ -z "$selection" ] && return 0

	local toggled_count=0
	while IFS= read -r line; do
		[ -z "$line" ] && continue
		local key
		key=$(printf "%s" "$line" | cut -f1)
		if _mark_task_done_by_key "$key"; then
			((toggled_count++))
		fi
	done <<< "$selection"

	_print_done_summary "$toggled_count"
}

build_done_candidates() {
	local scope="$1"
	case "$scope" in
		today)
			# shellcheck disable=SC2153  # NOTE_PATH and DATE are exported in state.sh
			candidates_from_file "$NOTE_PATH" "$DATE"
			;;
		week)
			local i date note_path
			for i in {0..6}; do
				date=$(offset_date "-$i")
				if note_path=$(note_path_for_date "$date"); then
					candidates_from_file "$note_path" "$date"
				fi
			done
			;;
		all)
			find "$NOTE_DIR" -type f -name "*.md" | sort | while read -r file; do
				local filename date_from_file
				filename=$(basename "$file")
				date_from_file="${filename%.md}"
				candidates_from_file "$file" "$date_from_file"
			done
			;;
		*)
			echo "Error: Unknown scope '$scope'. Use 'today', 'week', or 'all'." >&2
			return 1
			;;
	esac
}

candidates_from_file() {
	local file_path="$1"
	local date_label="$2"
	[ -f "$file_path" ] || return 0
	awk -v path="$file_path" -v date="$date_label" '
		/^```/ { inb = !inb; next }
		!inb && /^- \[ \] / { print path ":" NR "\t" date ": " $0 }
	' "$file_path"
}

_mark_done_by_ids() {
	# Using "$@" avoids nounset issues on empty arrays across bash versions
	if [ "$#" -eq 0 ]; then
		echo "Error: No task ids provided." >&2
		return 1
	fi

	local toggled_count=0

	local id
	for id in "$@"; do
		if _mark_task_done_by_key "$id"; then
			((toggled_count++))
		else
			echo "Warning: Could not mark task '$id' as done." >&2
		fi
	done

	_print_done_summary "$toggled_count"
}

_mark_task_done_by_key() {
	local key="$1"
	local path="${key%:*}"
	local line_no="${key##*:}"

	if [ -z "$path" ] || [ -z "$line_no" ]; then
		return 1
	fi

	if [ ! -f "$path" ]; then
		return 1
	fi

	if ! [[ "$line_no" =~ ^[0-9]+$ ]]; then
		return 1
	fi

	local line
	line=$(sed -n "${line_no}p" "$path") || return 1

	case "$line" in
		"- [ ] "*)
			if sed -i.bak "${line_no}s/^- \[ \]/- [x]/" "$path"; then
				rm -f "$path.bak"
				return 0
			fi
			rm -f "$path.bak"
			;;
	esac

	return 1
}

_print_done_summary() {
	local toggled_count="$1"
	[ "$toggled_count" -gt 0 ] || return 0

	if [ "${VERBOSE_FLAG:-false}" = "true" ]; then
		printf "Done: %d task(s)\n" "$toggled_count"
	else
		printf "Done: %d\n" "$toggled_count"
	fi
}
