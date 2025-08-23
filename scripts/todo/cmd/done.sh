#!/bin/bash
set -euo pipefail

# Mark open tasks as done via fzf selection (header-agnostic, ignores code blocks).
cmd_done() {
	# Always operate across all notes; ignore arguments for simplicity
	:

	if ! command -v fzf >/dev/null 2>&1; then
		echo "Error: 'fzf' is required for 'todo done'." >&2
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
		local key path line_no
		key=$(printf "%s" "$line" | cut -f1)
		path=$(printf "%s" "$key" | cut -d: -f1)
		line_no=$(printf "%s" "$key" | cut -d: -f2)
		# Mark as done: - [ ] -> - [x]
		sed -i.bak "${line_no}s/^- \[ \]/- [x]/" "$path" || true
		rm -f "$path.bak"
		((toggled_count++))
	done <<< "$selection"

	if [ ${toggled_count} -gt 0 ]; then
		if [ "${VERBOSE_FLAG:-false}" = "true" ]; then
			printf "Done: %d task(s)\n" "$toggled_count"
		else
			printf "Done: %d\n" "$toggled_count"
		fi
	fi
}

build_done_candidates() {
	local scope="$1"
	case "$scope" in
		today)
			# shellcheck disable=SC2153  # NOTE_PATH and DATE are exported in state.sh
			candidates_from_file "$NOTE_PATH" "$DATE"
			;;
		week)
			date_offset() {
				local d=${1:-0}
				if date -v-1d +%F >/dev/null 2>&1; then
					date -v-"${d}"d +%F
				elif date -d '1 day ago' +%F >/dev/null 2>&1; then
					date -d "${d} day ago" +%F
				else
					python3 - <<PY
from datetime import date, timedelta
print((date.today() - timedelta(days=int("${d}"))).isoformat())
PY
				fi
			}
			local i date note_path
			for i in {0..6}; do
				date=$(date_offset "$i")
				note_path="$NOTE_DIR/$date.md"
				[ -f "$note_path" ] && candidates_from_file "$note_path" "$date"
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
