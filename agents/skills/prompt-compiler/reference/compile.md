# compile

Compile raw developer intent into a clean Intent DTO. This branch specifies constraints only. It does not inspect implementation mechanics, mutate application code, or dispatch workers.

## Ownership

`prompt-compiler compile` owns only:

1. **Invariants** — unbreakable public contracts, behavior, latency budgets, and system guarantees.
2. **Blast radius** — domains or paths implementation may affect, expressed as `allowed_domains` rather than guessed files.
3. **Trade-off posture** — whether breaking changes are forbidden, allowed, or require a decision.

`$dev plan` owns repository discovery, phase decomposition, exact `target_files`, read context, verification commands, and commit messages. `orchestrator run` owns worker dispatch, retries, status, bounds enforcement, commits, rollback, and DAG-level Assure.

## Grill gate

Grill only unresolved intent constraints:

- Which public contracts, behaviors, or latency budgets must remain true?
- Which domains or paths define the permitted blast radius?
- Are breaking changes forbidden, allowed, or undecided?

Ask one targeted question at a time. Do not ask for commands, filenames, task ordering, test targets, retry counts, or execution status. Do not infer technical mechanics from intent language.

## Output contract

Emit exactly one file at `.agents/compile/<slug>.yaml`:

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

Requirements:

- Keep the DTO declarative and implementation-free.
- Do not emit task IDs, task DAGs, dependencies, `target_files`, `read_context`, commands, gates, commit messages, statuses, attempts, or retry limits.
- Do not encode unresolved prose outside the three owned intent dimensions. Grill until the DTO is valid or halt without emitting it.
- Leave `circuit_breaker.approved` false at emission. Approval is explicit user consent for the destructive rollback policy, never inferred by the compiler.

## Halt and handoff

Halt immediately after emission. Report the Intent DTO path and hand it to `$dev plan`. Do not dispatch workers, invoke `$dev implement`, start an execution loop, or mutate application code.
