---
name: review.gil
description: >-
  Review a change, branch, or PR for production readiness, tests, performance,
  security, dead compat, or merge-prep; publish a review to a PR. Use for PR
  code review, /code-review, /review.gil.
---

# Review

Findings-first review of a working tree, branch, commit range, or PR: the `finish` baseline plus only the lenses the diff warrants (`tests` / `perf` / `security` / `legacy`; a lens is a findings rubric on the same diff prep). Never ask the user to choose a template.

## Pick branch

| Execution  | Use when                                                                                    |
| ---------- | ------------------------------------------------------------------------------------------- |
| `findings` | Default: non-interactive/orchestrated (PR targets too), non-PR targets, or publish declined |
| `publish`  | PR reviewed end to end, drafts reconciled, submitted as GitHub `COMMENT`                    |
| `quality`  | Explicit merge-prep: audit, boy-scout refactors, tests, repo gates; changes code            |

- Ask "Publish review on PR?" only in a top-level interactive human session targeting an existing PR with unspecified intent. The answer selects execution, not lenses.
- "Review and publish/post/ship the review" → `publish`, no ask.
- "Post these findings" with a verified list → `pull-request` `comment`.
- "Draft review" = read-only findings, unless GitHub-pending is asked: end-to-end → `publish` stopping before submit; verified ledger supplied → `pull-request` `comment`.
- `quality` needs explicit permission to change code; never infer it from "review".

## Shared prep

Scripts resolve relative to this skill directory. `quality` skips this and runs its own Phase 0.

- **PR:** `scripts/pr-context.sh <pr>` (findings) or `scripts/pr-context.sh --publish <pr>` (publish); review the PR patch at the recorded head SHA, never the local tree/`HEAD`; no default-branch comparison.
- **Local:** `scripts/compare_default_branch.sh` (fallback: diff `HEAD` vs `origin/<default>`).
- **Every target:** **AGENTS.md load** ([`../CONTEXT.md`](../CONTEXT.md)). Separate unrelated dirty changes before selecting lenses.

**Reference load (before findings, each on its signal):**

1. Always: [`reference/finish.md`](reference/finish.md) (includes surfaces).
2. Behavior or tests changed: [`reference/tests.md`](reference/tests.md).
3. Auth, tenancy, sensitive data, secrets, APIs, SQL, boundaries: [`reference/security.md`](reference/security.md).
4. Dead-compat signals: [`reference/legacy.md`](reference/legacy.md) — report-only outside `quality`.
5. Hot path / allocations: [`reference/perf.md`](reference/perf.md).
6. `quality`: [`reference/quality.md`](reference/quality.md) + `legacy.md` (always).
7. `publish`: [`reference/publish.md`](reference/publish.md), [`reference/conventional-comments.md`](reference/conventional-comments.md), [`reference/github-state.md`](reference/github-state.md).

## Branch reference

- New lens / harvest: [`reference/growth.md`](reference/growth.md).

## Handoff

- Structural findings **name** the `architecture` branch; remediation enters via `$dev`.
- End-to-end PR review + publish stays here; verified ledger → `pull-request` `comment`. Never reverse.
- `findings` never writes to GitHub. Land + Yes/Conditional → `pull-request` `open` only when land was asked.
- Recurring failure classes → `harvest`. Delivery Ledger: `../CONTEXT.md`.

## Completion criteria

- **`findings`**: lenses applied; Critical empty/owned; Important owned/rationale; readiness Yes/No/Conditional; finish shape; no GitHub writes.
- **`quality`**: audit table (or empty); commit stack done/empty; gates green; P0/P1 fixed or listed.
- **`publish`**: fresh ledger on PR head SHA; drafts reconciled; `COMMENT` or PENDING (draft-only); URLs; no code.
