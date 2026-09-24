# compile

Owns only three intent dimensions:

1. **Invariants** — unbreakable public contracts, behavior, latency budgets, system guarantees.
2. **Blast radius** — `allowed_domains` (domains/paths), never guessed files.
3. **Trade-off posture** — breaking changes forbidden / allowed / ask.

`$dev plan` owns discovery, phases, `target_files`, read context, verification commands, commit messages. `orchestrator run` owns dispatch, retries, status, bounds, commits, rollback, DAG-level Assure.

## Grill gate

One targeted question at a time, only on: contracts/behaviors/latency budgets that must stay true; domains/paths of permitted blast radius; breaking-change posture. Never ask for commands, filenames, ordering, test targets, retry counts, or status; never infer mechanics from intent language.

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
- Grill until valid, or halt without emitting.
- `circuit_breaker.approved` is `false` at emission; approval is explicit user consent to the destructive rollback policy.

## Halt and handoff

Halt after emission; report the path and hand to `$dev plan`. Never dispatch workers, invoke `$dev implement`, start a loop, or mutate application code.
