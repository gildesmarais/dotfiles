# Plan

`$dev` `plan` contract and phase-commit law. Load for `plan`, and when committing or executing a plan todo loop.

## Plan contract

The planning session writes no code. Each todo names:

- exact repo-relative files
- one gate copied from repo evidence (`AGENTS.md`, `Makefile`, CI); none trustworthy → halt and name the missing contract, never invent
- its Conventional Commit message

Embed these checklist lines where signaled (a plan is not a findings report; `review.gil` `findings` runs after implement):

- **finish:** one home per fact; golden-path invariants (cite `AGENTS.md`); non-goals + residual risks with mitigations.
- **tests** (behavior changes): each phase names its test flight height per `surgical-laws.md`.
- **perf:** budgets + measure method; hot path isolated; optimize only measured breaches.
- **security** (sandbox/boundary): capabilities justified; boundaries validated; no secrets/PII in logs.
- **observability** (≥2 phases): log category per subsystem; levels + privacy; bridged error path if applicable.

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
