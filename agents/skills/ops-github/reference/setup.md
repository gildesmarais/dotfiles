# Setup

First day or `reconfigure` (re-ask, tick with `--owners`).

1. `ops-github setup-facts`, then one AskQuestion: owners (multi-select),
   exclusions (`owner/repo#n`), state dir (`OPS_GITHUB_STATE_DIR`, else host
   store or `$XDG_STATE_HOME/ops-github`).
2. Init with `ops-github --state-dir DIR --owners a,b`: `ledger exclude
   owner/repo#n` per exclusion, then `tick`.
3. `doctor` exits 0; arm watch per [`tick.md`](tick.md) step 6; confirm in ≤3
   lines: owners, state-dir, watch.
4. Optional: offer Claude Code `statusLine` =
   `cat "${OPS_GITHUB_STATE_DIR:-$HOME/.local/state/ops-github}/status.txt" 2>/dev/null`;
   never edit settings.

Un-exclude via `ledger exclude --clear` or `ledger include PR`, not the day JSON. Parked PRs: prefer
a GitHub label (`OPS_GITHUB_PARKED_LABELS`) over an exclusion.
