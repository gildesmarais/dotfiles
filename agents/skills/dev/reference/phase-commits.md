# Phase commits

Load when committing (plan phase or surgical milestone), or when executing a `$dev` `plan` todo loop.

## Commit law

- Detect the default branch early (`AGENTS.md` / remote HEAD).
- Off default: after each plan phase or surgical milestone, validate → ≥1 [Conventional Commit](https://www.conventionalcommits.org/) (v1.0.0) with a rationale body before the next. Store vocabulary: **Phase commit**.
- On default: commit only when asked once at plan time. Never silently commit on main/master.
- Carriers: `$dev` Shared prep (Build), `architecture` Shared prep (Solution). `release` `notes` only consumes merged history — don't defer authoring. Overlays never restate this.

## Plan todo loop

Host-neutral (plan todos or plan text). The plan file is exempt from clean-tree, bounds, and stash.

1. Next = first todo with no matching commit; worktree clean **except the plan file**.
2. Hand prompt: plan path, phase id, files, gate; load `$dev` `implement`; skip `review.gil`; do not commit. Retry adds one error line.
3. Bounds: `git diff --name-only` + untracked (plan file exempt) equals the todo's files. Gate exit 0 → stage those files, commit the todo message. Else `git stash push --include-untracked -m "<slug>/<phase>" -- . ':!<plan path>'`. Second failure on the same phase stops.
4. After the last commit: one `review.gil` `findings` (return in chat). Code-needing findings → follow-up plan.
5. Resume: compare todos to `git log`.
