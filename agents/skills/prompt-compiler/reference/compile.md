# compile

Owns only three intent dimensions:

1. **Invariants** — unbreakable public contracts, behavior, latency budgets, system guarantees.
2. **Blast radius** — `allowed_domains` (domains/paths), never guessed files.
3. **Trade-off posture** — breaking changes forbidden / allowed / ask.

`$dev plan` owns discovery, phases, `depends_on`, and delivery (Cursor multi-agent or `orchestrator run`).

## Batch

Ask the open dimensions in one message: contracts that must stay true, allowed domains, breaking-change posture. Never ask for commands, filenames, ordering, test targets, or retry counts. Never infer mechanics from intent language.

## Output contract

Exactly one file `.agents/compile/<slug>.yaml`:

```yaml
intent_spec:
  version: "2.0"
  slug: "<slug>"
  invariants:
    - "<unbreakable-system-contract>"
  blast_radius:
    allowed_domains:
      - "<path-or-domain>"
  trade_offs:
    breaking_changes: forbidden # forbidden | allowed | ask
  circuit_breaker:
    approved: false
```

- Forbidden: task IDs/DAGs, dependencies, `target_files`, `read_context`, commands, gates, commit messages, statuses, attempts, retry limits, prose outside the three dimensions.
- Unknown dimension → the batch asks; do not emit a guess.
- `circuit_breaker.approved` is the batch answer. Unasked and ungranted → `false`.

## Halt and handoff

Report the path and hand it to `$dev plan` in the same turn. Do not wait. Never implement application code here.
