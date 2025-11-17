#!/bin/bash
set -euo pipefail

# Basic smoke test for the todo CLI.
# Creates a temporary notes dir with mixed filename formats and verifies key commands.

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TODO_BIN="$PROJECT_ROOT/todo"

iso_date() {
    local offset="${1:-0}"
    python3 - <<PY
from datetime import date, timedelta
print((date.today() + timedelta(days=int("${offset}"))).isoformat())
PY
}

SMOKE_DIR="$(mktemp -d)"
cleanup() {
    rm -rf "$SMOKE_DIR"
}
trap cleanup EXIT

# Ensure predictable environment (no git sync, no glow paging, no auto-commit).
export TODO_NOTE_DIR="$SMOKE_DIR"
export TODO_USE_GLOW=false
export TODO_AUTO_GIT_SYNC=false
export TODO_AUTO_COMMIT=false
export VERBOSE_FLAG="true"
unset VISUAL
export EDITOR=true

today_iso="$(iso_date 0)"
yesterday_iso="$(iso_date -1)"
two_days_iso="$(iso_date -2)"
today_compact="${today_iso//-/}"

create_note_file() {
    local path="$1"
    local body="$2"
    cat <<EOF > "$path"
---
---
# Daily Note

$body
EOF
}

# Mix compact and ISO filenames to exercise compatibility helpers.
create_note_file "$SMOKE_DIR/${today_compact}.md" $'- [ ] Legacy compact task\n- [x] Completed compact task'
create_note_file "$SMOKE_DIR/${yesterday_iso}.md" $'- [ ] ISO task for yesterday'
create_note_file "$SMOKE_DIR/${two_days_iso}.md" $'- [ ] ISO task two days ago\n- [ ] Another task'

echo "Running todo add..."
"$TODO_BIN" add "Smoke inserted task"

echo "Running todo list week -o..."
week_output="$("$TODO_BIN" list week -o)"
if ! printf "%s" "$week_output" | grep -q "Smoke inserted task"; then
    echo "ERROR: Weekly list missing newly added task" >&2
    exit 1
fi

echo "Running todo motd..."
motd_output="$("$TODO_BIN" motd)"
if ! printf "%s" "$motd_output" | grep -q "$yesterday_iso"; then
    echo "ERROR: MOTD output missing expected ISO date header" >&2
    exit 1
fi
if ! printf "%s" "$motd_output" | grep -q "Legacy compact task"; then
    echo "ERROR: MOTD output missing compact-format tasks" >&2
    exit 1
fi

echo "Running todo motd --json..."
motd_json="$("$TODO_BIN" motd --json)"
printf "%s" "$motd_json" | python3 -c '
import json
import sys

data = json.load(sys.stdin)
if not data:
    sys.exit("ERROR: Expected JSON MOTD to contain tasks")

if not any(item.get("text") == "Smoke inserted task" for item in data):
    sys.exit("ERROR: JSON MOTD missing newly added task")
'

first_id=$(printf "%s" "$motd_json" | python3 -c '
import json
import sys

data = json.load(sys.stdin)
print(data[0]["id"] if data else "")
')

if [ -z "${first_id:-}" ]; then
    echo "ERROR: Failed to obtain first task id from JSON MOTD" >&2
    exit 1
fi

echo "Running todo open ..."
"$TODO_BIN" open "$first_id"

echo "Running todo done --ids ..."
"$TODO_BIN" done --ids "$first_id"

motd_json_after="$("$TODO_BIN" motd --json)"
printf "%s" "$motd_json_after" | python3 -c '
import json
import sys

data = json.load(sys.stdin)
target = sys.argv[1]
if any(item.get("id") == target for item in data):
    sys.exit("ERROR: Task id still present after todo done --ids")
' "$first_id"

echo "Smoke test succeeded."
