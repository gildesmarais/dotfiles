# Plan

`$dev` `plan` contract and phase-commit law. Load for `plan`, and when committing or executing a plan.

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
- On default: commit only when asked (once at plan time, or up front for a surgical change); otherwise defer and record the deferral in the Delivery Ledger. Never silently on main/master.
- Carriers: `$dev` Shared prep (Build), `architecture` Shared prep (Solution). `release` `notes` only consumes merged history. Overlays never restate this.

## Execution

Todo tracking and sequencing belong to the host. Per todo: change only its files, run its gate (exit 0 observed), commit its message with only those files staged; a gate failing twice on one phase stops the run. After a plan's last commit, one `review.gil` `findings` regardless of per-phase skips (in chat); code-needing findings become a follow-up plan. Resume by comparing todos to `git log`.

## Token hygiene

- Delegate with a closed brief: exact files, one command, stop condition; point to `AGENTS.md`, never restate it. Disjoint file sets when parallel; read-only surveys only when the answer is not one grep away.
- Cheapest model that fits: mechanical edits on a small model, design calls on the strongest.
- Cap command output (`| tail -n 40`, `grep` the summary, full log to scratch). Clear or compact between unrelated tasks.
