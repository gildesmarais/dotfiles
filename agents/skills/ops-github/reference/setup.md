# Setup

First day (or `reconfigure`).

1. `ops-github setup-facts`. Prefill AskQuestion: owners (multi-select; never
   hardcode), PRs to exclude (`owner/repo#n`), state dir (host store or
   `$XDG_STATE_HOME/ops-github`). Prefer `OPS_GITHUB_STATE_DIR` when set.
2. Init: `ops-github --state-dir DIR --owners a,b tick`, then
   `ledger exclude owner/repo#n` per exclusion.
3. Confirm `ops-github --state-dir DIR doctor` exits 0.
4. Arm watch if PID gone: `ops-github --state-dir DIR watch` as a session-owned
   background Shell (`block_until_ms: 0`, full permissions, `notify_on_output` on
   `OPS_GITHUB_WAKE`, debounce ≥60s) — never `nohup … &`. Confirm ≤3 lines:
   owners, state-dir, watch.

`reconfigure` re-asks, then ticks with `--owners`. Never encode org names.
