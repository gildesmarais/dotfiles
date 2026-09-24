# run

The plan `.agents/plan/<slug>.md` is the immutable phase definition; git history is progress. Trust no worker claim.

## Input contract (halt unless all hold)

1. Every `<!-- phase:start -->` block has exact `target_files`, `read_context`, one `verification_gate`, one Conventional Commit `commit_message`.
2. Target paths are repo-relative files — no globs, directories, or prose bounds.
3. Circuit-breaker consent approved explicitly in the plan or by the user in this thread.
4. Worktree clean before the first phase; never reset over unrelated work.
5. Default-branch commit consent satisfies `$dev` law.

Completed phases = matching commits on the current execution range; never add status fields to the plan. Before any dispatch: `dag_baseline = HEAD`, `last_green_commit = HEAD`.

### Phase parsing

- Split only on literal `<!-- phase:start -->` / `<!-- phase:end -->`; each start has exactly one later end; text outside is not phase data.
- `target_files:` / `read_context:` — YAML inline list (`target_files: ["path/a", "path/b"]`) or a Markdown list of one path scalar per item (backticks optional) until the next field or phase end. Regex fallback: `^target_files:\s*(.*)$`; accept a non-empty bracketed list, else skip blank lines and collect consecutive `^\s*-\s+` lines; strip one pair of backticks/quotes per scalar.
- `verification_gate:` / `commit_message:` — single-line scalars; strip one matching pair of backticks/quotes; preserve contents exactly (never split shell commands).
- Reject duplicate fields, empty required values, malformed inline collections, ambiguous prose. Accepted formatting variants are not grounds to halt. Then enforce exact-path, one-command, Conventional Commit checks.

## Sequential phase loop

For each incomplete phase:

1. `task_baseline = HEAD` (don't reinitialize `last_green_commit`).
2. Spawn a fresh `$dev implement` worker with `orchestrated: true` and only: phase outcome, intent invariants, `target_files`, `read_context`.
3. Bounds: `git diff --name-only <task_baseline>` plus `git ls-files --others --exclude-standard`; every changed path must be exactly in `target_files` (`read_context` grants no mutation).
4. Run the exact `verification_gate` yourself; only observed exit 0 counts.
5. Success: stage only `target_files`, commit with the exact `commit_message`, `last_green_commit = HEAD`, advance.
6. Failure: restore to `task_baseline`, give the concrete bounds/gate error to a fresh worker, retry.
7. After a phase commit, scan subject/body for `Resolves: DEBT-<NUMBER>` or `Fixes [DEBT-<NUMBER>]`; for each unique match set **Status** `resolved` + phase commit hash in `.agents/debt-ledger.md` (orchestrator-owned, exempt from `target_files`), commit separately as `chore(debt): resolve DEBT-<NUMBER>`. Missing/ambiguous entry → halt.

`max_retries` defaults to 2 (retries after the initial attempt); circuit-break when exceeded (three failed attempts by default).

## Worker contract

```text
Load and follow `$dev`, branch `implement`.
orchestrated: true
Execute exactly this implementation-plan phase. Do not expand scope.
Preserve the supplied intent invariants.
Mutate only target_files. read_context is read-only.
Do not commit. Leave changes for the orchestrator.
Skip per-phase review.gil; the orchestrator runs one DAG-level findings pass.
```

`$dev` owns classification, architecture routing, adapters, implementation; orchestrator owns dispatch, verification, bounds, commits, retries, rollback.

## Circuit breaker

1. `git reset --hard <last_green_commit>` under recorded consent (never a worker-supplied revision).
2. Remove failed-attempt untracked files only after proving they were absent at the clean baseline.
3. Halt the DAG; never continue, advance, or turn the plan into a status tracker.

## Full DAG completion

1. Cumulative diff `dag_baseline..HEAD`.
2. Exactly one fresh `review.gil findings` audit over it, with warranted lenses (security, tests, perf, legacy).
3. Report delivery after the audit. Findings needing implementation → halt for an explicit follow-up plan; never smuggle repairs into the completed DAG.

## Completion

- Phase green: exact bounds, independent gate exit 0, planned commit authored.
- Circuit break: reset to `last_green_commit`, untracked failed-attempt files safely removed, halted.
- DAG green: all phase commits present; one cumulative `review.gil findings` pass complete.
