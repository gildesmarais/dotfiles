# Run Reference

## §1 Preconditions (halt unless all hold)

1. Roadmap discovered (Shared prep §2); ≥1 undone admitted tranche.
2. Clean worktree — dirty → halt, ask user.
3. Default-branch ask completed (Shared prep §6).
4. Circuit-breaker consent obtained (Shared prep §5).
5. Record `baseline_commit` = HEAD.

## §2 Discovery loop

Parse roadmap → ordered tranches. Skip done. Skip unadmitted (report). For next undone admitted: discover plan doc → halt if missing.

## §3 Worker prompt template

```text
Load and follow `$dev`, branch `implement`.
Implement all phases from: <plan_doc_path>
Read `AGENTS.md` for repo law. Commit per phase per `$dev` phase-commit.
Do not skip forward-doc.
Skip per-task Assure — orchestrator owns the final gate.
Tooling/env hints: <known tool runners/shims, e.g. mise exec, sandbox bypass requirements, git signing flags>
Validation hint: <verification_gate>

On completion, report back ONLY a concise, high-signal summary (prevent context bloat):
1. Phase commits: list of `<sha> <conventional commit message>`
2. Verification result: exact gate command run and exit status
3. Key insights & deviations: unexpected design decisions or architectural adjustments made
4. Pitfalls & friction resolved: any local environment, test, or tooling hurdles overcome
Do NOT dump full terminal logs or step-by-step tool output.
```

## §4 Hard gate (zero worker trust)

Re-run verification gate. Observe exit status. Never trust verbal "green".

## §5 Pass → advance

1. Update roadmap: admitted → done.
2. Commit: `docs(roadmap): mark tranche <NNN> done`.
3. `last_green_commit` = HEAD.
4. Next tranche — no user prompt between tranches.

## §6 Fail → retry → circuit break

Track `attempts` (cap = `max_retries`, default 2, override from `AGENTS.md`).

- `< max_retries`: new worker with gate error attached.
- `≥ max_retries`: `git reset --hard <last_green_commit>` (or `baseline_commit`). Halt. Report tranche, error, reset target.

## §7 Full completion

All admitted green → `review.gil` **`findings`** (+ warranted lenses). Report after review. Land → `pull-request` **`open`**.

## §8 Anti-patterns

- Mutating app files in orchestrator turn
- Trusting worker verbal green
- Committing app code from orchestrator
- Inventing plan content
- Running `product-owner` mid-loop
- Pushing without user ask
- Hard reset without circuit-breaker consent
- Omitting known tooling/environment prefixes when spawning workers (forcing worker to rediscover local shims/sandbox requirements)
- Ingesting verbose worker command transcripts into orchestrator context (context bloat)
