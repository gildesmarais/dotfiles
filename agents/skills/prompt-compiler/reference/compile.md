# Compile branch

Grill gaps, satisfy the `$dev` plan-pipeline ready checklist, persist the IR file, stop. **No application code mutations.**

## Grill rubric

Trigger `/grill-me` (or inline fallback) when the prompt implies structural change without:

1. **Invariants** — non-negotiable behavioral / contractual constraints (APIs, schemas, suites that must stay green unmodified).
2. **Mutation bounds** — explicit whitelist of mutable paths (`target_files`) vs frozen surfaces.
3. **Trade-offs** — clear stance on breaking changes (allowed / forbidden / ask).

Keep questions targeted, concise, one at a time. Soft cap 5; user saying “keep grilling” extends the cap. After the cap with gaps still open: **halt** — do not emit until answers land or the user explicitly allows emit-with-unknowns (list each gap under `invariants` as `Unknown: … — verify before acting; do not invent.`).

**Pack vs fallback:** load `grilling` when installed; otherwise ask one open question (facts) or 2–3 options with `(Recommended)` first (decisions). Do not invent APIs, paths, gates, or stakes.

## Plan-pipeline hook

Before emitting, load [`../../dev/reference/plan-pipeline.md`](../../dev/reference/plan-pipeline.md) and satisfy its **Plan ready checklist**. Map checklist items into IR fields / task metadata:

| Checklist item                     | Where it lands in the IR                                         |
| ---------------------------------- | ---------------------------------------------------------------- |
| Product stance                     | Shared prep PO gate result, or `Unstated` noted in emit notes    |
| Classification + runtime route     | Per-task notes or emit preamble (workers re-classify via `$dev`) |
| Architecture findings if triggered | Invariants and/or task `name` / description                      |
| Phases: validate → commit          | Each task's `verification_gate` + `run` commit loop              |
| Residual risks                     | Emit notes; do not invent mitigations                            |
| No code until user approves        | This branch stops after persist                                  |

The IR is an **equivalent syntax** of the `$dev` `plan` carrier — not a second plan format. README rule 4 stays intact.

## IR file location

Write to the **target repo** (workspace root of the work being compiled):

```text
.agents/compile/<slug>.yaml
```

- `<slug>`: short kebab from the goal (e.g. `extract-auth-service`).
- State the absolute or repo-relative path in the emit summary.
- Create `.agents/compile/` if missing. Do not commit the IR unless the user asks.

## IR schema

```yaml
prompt_compiler:
  version: "1.0"
  invariants:
    - "Public HTTP contracts and schemas remain frozen"
    - "Existing integration test suite passes unmodified"
  circuit_breaker:
    policy: "On repeated gate failure, reset working tree to last green task commit and halt"
    user_approved: false # set true only after explicit user approval before run
  tasks:
    - id: "task_01"
      name: "Extract service layer"
      target_files:
        - "src/services/auth.py"
        - "src/api/v1/auth.py"
      read_context:
        - "src/models/user.py"
      verification_gate: "ruff check . && mypy src/services/auth.py && pytest tests/unit/test_auth.py"
      max_retries: 2
      depends_on: [] # optional task ids; dispatch stays sequential in topological order
      status: pending # pending | green | failed
```

### Field rules

| Field                           | Rule                                                                                            |
| ------------------------------- | ----------------------------------------------------------------------------------------------- |
| `invariants`                    | Grounded strings; no fluff. Prefer contracts and suites over vibes.                             |
| `target_files`                  | Strict mutation whitelist. Atomic: one domain / module / interface migration per task.          |
| `read_context`                  | Read-only paths the worker may open; not writable.                                              |
| `verification_gate`             | Repo-native command string. Do not invent — discover from Makefile / CI / AGENTS.md or grill.   |
| `max_retries`                   | Default `2` if omitted.                                                                         |
| `depends_on`                    | Optional. Honest DAG data; `run` still dispatches sequentially (topo order). Parallel deferred. |
| `status`                        | `compile` emits all `pending`. Only `run` may flip to `green` / `failed`.                       |
| `circuit_breaker.user_approved` | Must be `true` before `run` starts (user consent for reset-to-last-green).                      |

### Compilation contract

Every task must be:

- **Atomic** — single domain, module, or interface migration.
- **Bounded** — `target_files` whitelist only.
- **Verifiable** — explicit `verification_gate`.
- **Isolated** — executable in a fresh worker context without conversation drift.

### No invention

Do not invent `target_files`, `verification_gate`, or invariants. If unknown: grill, or mark `Unknown: …` under invariants and halt emit unless the user allows emit-with-unknowns.

## Emit

1. Persist the YAML file.
2. Summarize: path, invariant count, task count (ids + names), residual unknowns.
3. Ask for approval to **`run`**, explicitly calling out the circuit-breaker policy.
4. When the user explicitly approves (e.g. "proceed", "run it", "approved"), set `circuit_breaker.user_approved: true` in the IR file — the only post-emit edit this branch makes. `run` precondition 2 reads this flag, not conversation memory.
5. Stop — do not dispatch without explicit approval. On approval, proceed to branch **`run`**.
