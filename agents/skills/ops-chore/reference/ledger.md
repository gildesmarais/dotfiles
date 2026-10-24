# Ops Ledger

```markdown
# Ops Ledger — <preset> — <start> → <end> UTC

## Meta
- Preset: quick | full | post-deploy (source: smart-default | user)
- Lookback resolution: …
- Mutation: reads + optional dashboard apply
- Dashboard apply: done (id, hash) | skipped (reason) | blocked (generator change admitted)

## Findings
### Strong
### Worth
### Speculative

## Actions completed this run
- Checks executed
- Live board apply (if any)

## Admitted → `$dev` plan (service + observability)
For each item:
- Title (conventional-commit style)
- Evidence (Strong) + bottleneck class
- Target files
- Rejected alternative
- Suggested gate (rspec paths / make target)

## Non-goals this run

## Next-run seeds
(host drain, disk path, SMTP confirm, …)
```

Prioritize Admitted items (P0 queue red / data loss, P1 user-facing latency, P2 obs hygiene); list every Strong finding. Empty Admitted on a `full` run with Strong APM/reliability findings is prohibited.
