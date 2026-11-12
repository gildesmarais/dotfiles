# Watch

One background process per profile. `start` arms it after the first brief.

## Arm

Skip when `ops-github doctor` shows `watcher_alive`. `ops-github watch` runs:

```sh
ops-github --state-dir <dir> watch --brief-every <sec> 2>&1 | grep -E --line-buffered 'OPS_GITHUB_WAKE|rror|FAIL'
```

- Cursor: session background shell, `notify_on_output` debounce ≥60s.
- Claude Code: `Monitor` with `timeout_ms` 1800000; re-arm on expiry.
- Never `nohup … &`. `<sec>` = `brief_every` from config.

## Wake

`OPS_GITHUB_WAKE` JSON carries `urgency`; urgent/batch come from the envelope,
never the wake.

- `"changes"`: GitHub only. Tier 1 Hand runs `ops-github tick`; run `auto`
  within `budgets`; emit the ticket-clustered delta brief if not quiet. Skip
  Slack and Jira MCP to save tokens.
- `"brief"`: full sweep, in parallel: `ops-github tick`, `$ticket` `intake`,
  `$ops-slack` `digest`. Unchanged → one-line heartbeat; else the delta brief.
- `"env"`: `ops-github doctor | tail -n 5`; print one health warning; no tick.

Output rules: `brief.md` Periodic wakes.

## Wrap

`/ops wrap` (moved here from the removed `reference/wrap.md` of `$ops-github`):

1. Kill `watcher_pid` from `ops-github doctor` if alive; confirm in one line.
2. Paste `ops-github ledger summary` plus the Brain Ledger tranche table
   (≤40 lines together).
3. Leave both ledgers and `jira-ledger.json` on disk for tomorrow's carry-over.
4. No further sweeps unless the operator re-opens.
