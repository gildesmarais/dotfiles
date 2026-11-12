# Setup

First day or `reconfigure` (re-ask, tick with `--owners`). `$ops` setup calls
this with answers already collected; skip the question then.

1. `ops-github setup-facts`, then one AskQuestion: owners (multi-select),
   exclusions (`owner/repo#n`), state dir (`OPS_GITHUB_STATE_DIR`, else host
   store or `$XDG_STATE_HOME/ops-github`).
2. Init with `ops-github --state-dir DIR --owners a,b`: `ledger exclude
   owner/repo#n` per exclusion, then `tick`.
3. `doctor` exits 0; confirm in ≤3 lines: owners, state-dir. Watching is
   `$ops` (`reference/watch.md`).

Un-exclude via `ledger exclude --clear` or `ledger include owner/repo#n`, not the day JSON. Parked PRs: prefer
a GitHub label (`OPS_GITHUB_PARKED_LABELS`) over an exclusion.
