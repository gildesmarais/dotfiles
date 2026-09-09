# run

Execute one unified implementation plan from `.agents/plan/<slug>.md`. The plan is the immutable phase definition; git history is execution progress. Trust no worker claim.

## Input contract

Halt unless all conditions hold:

1. The plan exists and every `<!-- phase:start -->` block has exact `target_files`, `read_context`, one `verification_gate`, and one Conventional Commit `commit_message`.
2. Target paths are repository-relative files with no globs, directories, or prose bounds.
3. Circuit-breaker consent is approved explicitly in the plan or by the user in the current thread.
4. The worktree is clean before the first phase. Never reset over unrelated work.
5. Default-branch commit consent satisfies `$dev` law.

Read phases in document order. Determine completed phases from matching commits on the current plan execution range; do not add status fields to the plan. Before dispatching any worker, set `dag_baseline = HEAD` and `last_green_commit = HEAD`.

### Deterministic phase parsing

- Split only on literal `<!-- phase:start -->` and `<!-- phase:end -->` markers. Each start marker must have exactly one later end marker; text outside the markers is not phase data.
- Parse `target_files:` (and `read_context:`) first as a YAML-compatible inline list such as `target_files: ["path/a", "path/b"]`, or as an unambiguous Markdown list whose subsequent non-blank lines are list items containing one path scalar, optionally wrapped in backticks, until the next recognized field or phase end.
- If YAML/list parsing is unavailable, use this regex fallback within the phase block: locate `^target_files:\s*(.*)$`; accept a non-empty bracketed inline list, otherwise skip intervening blank lines and collect consecutive lines matching `^\s*-\s+` after that field. Strip one pair of backticks or quotes from each scalar. Apply the same fallback to `read_context:`.
- Parse `verification_gate:` and `commit_message:` as single-line YAML-compatible scalars. Strip one matching pair of backticks or quotes, but preserve the scalar contents exactly; do not split shell commands on punctuation.
- Reject duplicate fields, empty required values, malformed inline collections, or ambiguous prose. Formatting differences covered by the accepted inline/list forms are not grounds to halt. After parsing, enforce the existing exact-path, one-command, and Conventional Commit validations.

## Sequential phase loop

For each incomplete phase:

1. Set `task_baseline = HEAD` before dispatch. Do not reinitialize `last_green_commit`.
2. Spawn a fresh isolated worker through `$dev implement` with `orchestrated: true` and only the phase outcome, intent invariants, `target_files`, and `read_context`. The worker must not commit and must skip per-phase Assure.
3. After return, run `git diff --name-only <task_baseline>`. Include untracked paths from `git ls-files --others --exclude-standard` in the same bounds decision. Assert every changed path is exactly present in `target_files`; `read_context` grants no mutation permission.
4. Execute the phase's exact `verification_gate` independently. Accept only an observed exit code of 0. Worker reports are not evidence.
5. On bounds and gate success, stage only `target_files`, author the plan's exact `commit_message` as a Conventional Commit, set `last_green_commit = HEAD`, and advance.
6. On failure, restore the failed attempt to `task_baseline`, report the concrete bounds or gate error to a fresh worker, and retry.
7. After a successful phase commit, inspect its subject and body for `Resolves: DEBT-<NUMBER>` or `Fixes [DEBT-<NUMBER>]`. For each unique matching ledger entry, set **Status** to `resolved` and record that phase commit hash in `.agents/debt-ledger.md`. This governance mutation is orchestrator-owned and exempt from phase `target_files`; commit it separately as `chore(debt): resolve DEBT-<NUMBER>` before advancing. Halt on a missing or ambiguous entry.

`max_retries` defaults to 2 and counts retries after the initial attempt. Circuit-break when failures exceed `max_retries` (three failed attempts under the default).

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

`$dev` remains authoritative for classification, architecture routing, language adapters, and implementation behavior. The orchestrator owns dispatch, independent verification, bounds, commits, retries, and rollback.

## Circuit breaker

When failures exceed `max_retries`:

1. Execute `git reset --hard <last_green_commit>` under the recorded user consent.
2. Remove untracked files created by the failed attempt only after proving they were absent at the clean baseline.
3. Halt the entire DAG. Do not advance or edit the plan into a status tracker.

Never reset to a worker-supplied revision. Never continue after a circuit break.

## Full DAG completion

After every phase commit is green:

1. Compute the cumulative delivery diff from `dag_baseline` through `HEAD`.
2. Trigger exactly one fresh `review.gil findings` audit across that cumulative diff, adding warranted lenses such as security, tests, performance, or legacy.
3. Report delivery only after the audit returns. If findings require implementation, halt for an explicit follow-up plan; do not smuggle repair work into the completed DAG.

## Completion

- Phase green: exact bounds pass, independent gate exit 0, planned Conventional Commit authored.
- Circuit break: reset to `last_green_commit`, failed-attempt untracked files safely removed, pipeline halted.
- DAG green: all phase commits present and one cumulative `review.gil findings` pass complete.
