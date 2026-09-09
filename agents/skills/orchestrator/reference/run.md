# run

Execute one unified implementation plan from `.agents/plan/<slug>.md`. The plan is the immutable phase definition; git history is execution progress. Trust no worker claim.

## Input contract

Halt unless all conditions hold:

1. The plan exists and every `<!-- phase:start -->` block has exact `target_files`, `read_context`, one `verification_gate`, and one Conventional Commit `commit_message`.
2. Target paths are repository-relative files with no globs, directories, or prose bounds.
3. Circuit-breaker consent is approved explicitly in the plan or by the user in the current thread.
4. The worktree is clean before the first phase. Never reset over unrelated work.
5. Default-branch commit consent satisfies `$dev` law.

Read phases in document order. Determine completed phases from matching commits on the current plan execution range; do not add status fields to the plan.

## Sequential phase loop

For each incomplete phase:

1. Set `task_baseline = HEAD` and `last_green_commit = HEAD` before dispatch.
2. Spawn a fresh isolated worker through `$dev implement` with only the phase outcome, intent invariants, `target_files`, and `read_context`. The worker must not commit and must skip per-phase Assure.
3. After return, run `git diff --name-only <task_baseline>`. Include untracked paths from `git ls-files --others --exclude-standard` in the same bounds decision. Assert every changed path is exactly present in `target_files`; `read_context` grants no mutation permission.
4. Execute the phase's exact `verification_gate` independently. Accept only an observed exit code of 0. Worker reports are not evidence.
5. On bounds and gate success, stage only `target_files`, author the plan's exact `commit_message` as a Conventional Commit, set `last_green_commit = HEAD`, and advance.
6. On failure, restore the failed attempt to `task_baseline`, report the concrete bounds or gate error to a fresh worker, and retry.

`max_retries` defaults to 2 and counts retries after the initial attempt. Circuit-break when failures exceed `max_retries` (three failed attempts under the default).

## Worker contract

```text
Load and follow `$dev`, branch `implement`.
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

1. Compute the cumulative delivery diff from the pre-DAG baseline through `HEAD`.
2. Trigger exactly one fresh `review.gil findings` audit across that cumulative diff, adding warranted lenses such as security, tests, performance, or legacy.
3. Report delivery only after the audit returns. If findings require implementation, halt for an explicit follow-up plan; do not smuggle repair work into the completed DAG.

## Completion

- Phase green: exact bounds pass, independent gate exit 0, planned Conventional Commit authored.
- Circuit break: reset to `last_green_commit`, failed-attempt untracked files safely removed, pipeline halted.
- DAG green: all phase commits present and one cumulative `review.gil findings` pass complete.
