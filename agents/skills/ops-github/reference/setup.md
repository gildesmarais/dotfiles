# Setup

First day (or `reconfigure`).

1. `ops-github setup-facts`. Prefill AskQuestion: owners (multi-select; never
   hardcode), PRs to exclude (`owner/repo#n`), state dir (host store or
   `$XDG_STATE_HOME/ops-github`). Prefer `OPS_GITHUB_STATE_DIR` when set.
2. Init: `ops-github --state-dir DIR --owners a,b ledger exclude owner/repo#n`
   per exclusion, then `ops-github --state-dir DIR --owners a,b tick`.
3. Confirm `ops-github --state-dir DIR doctor` exits 0.
4. Arm watch per [`tick.md`](tick.md) step 6. Confirm ≤3 lines: owners,
   state-dir, watch.

5. Optional statusline: `tick` writes `<state-dir>/status.txt`. Tell the user they
   can set Claude Code `statusLine` to the command
   `cat "${OPS_GITHUB_STATE_DIR:-$HOME/.local/state/ops-github}/status.txt" 2>/dev/null`.
   Never edit their settings.

`reconfigure` re-asks, then ticks with `--owners`. Never encode org names.
