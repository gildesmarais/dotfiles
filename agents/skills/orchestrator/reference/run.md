# run

The plan `.agents/plan/<slug>.md` is immutable. Commits are progress. The brain does not edit application files and does not trust a hand's claim.

## Brain

Halt unless the plan has `target_files`, `read_context`, one `verification_gate`, one `commit_message`, and `depends_on` on every phase, circuit-breaker consent is already given, and the worktree is clean.

1. Next phase = first incomplete block whose `depends_on` ids already have commits. Read that block only.
2. Spawn one hand. Prompt: plan path, phase id, and on retry the one error line in gitignored `.agents/run/<slug>.md`. Do not paste the plan or prior transcripts.
3. Ignore the hand's transcript. `git diff --name-only` plus untracked files must be exactly `target_files` (the run log is exempt and never staged). Run `verification_gate`. Exit 0 → stage only `target_files`, commit with `commit_message`. Otherwise restore to that phase's baseline.
4. Append `phase id, exit code, one-line error` to the run log.
5. A second failure resets with `git reset --hard` to the last green commit and stops the run.

After a commit whose message resolves `DEBT-<NUMBER>`, mark that ledger row resolved and commit `chore(debt): resolve DEBT-<NUMBER>`. Missing row → stop.

Then one `review.gil findings` pass on the range. Append the findings to the run log. Findings that need code → one list, then stop for a follow-up plan.

Cursor multi-agent delivery of a fresh plan is `$dev plan`, not this loop. This loop is the shared-tree runner: one hand at a time.

## Hand

```text
Load `$dev` implement. orchestrated: true
Read only this phase in .agents/plan/<slug>.md and its read_context paths.
On retry, read the one error line in .agents/run/<slug>.md.
Edit target_files. Do not commit.
Skip review.gil.
```

## Completion

- Phase green: bounds match, gate exit 0, planned commit exists.
- Circuit break: hard reset to the last green commit, run stopped.
- Run green: every phase committed, one findings pass in the run log.
