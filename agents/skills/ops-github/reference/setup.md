# Setup

First day (or `reconfigure`).

1. Run `ops-github setup-facts`. Prefill AskQuestion from its JSON: owners
   (multi-select; never hardcode), PRs to exclude (`owner/repo#n`), state
   directory (host persistent store, else `$XDG_STATE_HOME/ops-github`).
2. Init: `ops-github --state-dir DIR --owners a,b ledger exclude` only for
   chosen exclusions (or first `tick` with `--owners` to create the day file).
   Prefer `OPS_GITHUB_STATE_DIR` when set.
3. Run the first `tick`.
4. Arm watch if PID gone: `ops-github --state-dir DIR watch` in a background
   shell. Confirm in ≤3 lines: owners, state-dir, watch status.

`reconfigure` re-asks the same form, then ticks. Never encode org names in the
skill or commits.
