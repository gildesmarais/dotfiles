---
name: review.gil
description: >-
  Review a local change, branch, or pull request for production readiness,
  tests, performance, security, legacy/dead-compat debt, or merge-prep quality.
  Use for a findings-ready review, a PR code review, publishing a review to a
  PR, /code-review, /review.gil, or when another skill needs a
  production-readiness or test-quality pass.
---

# Review

Findings-first review of a working tree, branch, commit range, or PR: the `finish` baseline plus only the lenses the diff warrants. Never ask the user to choose a template. Vocabulary: [`../CONTEXT.md`](../CONTEXT.md).

## Pick branch

| Execution | Use when |
| --- | --- |
| `findings` | Default: non-interactive/orchestrated (PR targets too), non-PR targets, or publish declined |
| `publish` | PR reviewed end to end, drafts reconciled, submitted as GitHub `COMMENT` |
| `quality` | Explicit merge-prep: audit, boy-scout refactors, tests, repo gates; changes code |

- Ask exactly "Publish review on PR?" only in a top-level interactive human session targeting an existing PR with unspecified intent. Skip if already answered, read-only/draft findings requested or implied, publication requested, or no PR. The answer selects execution, not lenses.
- "Review and publish/post/ship the review" → `publish`, no ask.
- "Post these findings" with an already-verified list → `pull-request` `comment`.
- "Draft review" = read-only findings unless GitHub-pending comments are explicitly asked: end-to-end review drafts → `publish` stopping before submit; a supplied verified ledger → `pull-request` `comment` (even if it stays pending).
- Never infer `quality` from "review"; it needs explicit permission to change code.

## Shared prep

Resolve scripts relative to this skill directory. `quality` skips this and runs its own Phase 0 (no `compare_default_branch.sh` first).

- **PR:** no local/default-branch comparison. `scripts/pr-context.sh <pr>` (findings) or `scripts/pr-context.sh --publish <pr>` (publish); review the PR patch and surrounding code at the recorded head SHA, never the local tree/`HEAD`.
- **Local:** `scripts/compare_default_branch.sh` (fallback: diff `HEAD` vs `origin/<default>`).
- **Every target:** read `AGENTS.md`; separate unrelated dirty changes; summarize scope + high-risk areas before selecting lenses.

**Mandatory reference load (blocking — no findings before these are read):**

1. Always: [`reference/finish.md`](reference/finish.md) (baseline, output format, incident/fix-diff postures).
2. Behavior or tests changed: [`reference/tests.md`](reference/tests.md).
3. Auth, tenancy, sensitive data, secrets, APIs, SQL, boundaries: [`reference/security.md`](reference/security.md).
4. Dead-compat signals (deprecated markers, dual exports, superseded hydrate): [`reference/legacy.md`](reference/legacy.md) — report only under `findings`/`publish`; deletion is `quality`-only.
5. `quality`: [`reference/quality.md`](reference/quality.md) + [`reference/legacy.md`](reference/legacy.md) (always, even without signals).
6. `publish`: [`reference/publish.md`](reference/publish.md), [`reference/conventional-comments.md`](reference/conventional-comments.md), [`reference/github-state.md`](reference/github-state.md).
7. Hot path / allocations (any language): [`reference/perf.md`](reference/perf.md).

## Branch reference

- Output shape (all executions' findings): [`reference/finish.md`](reference/finish.md) § Output format.
- Fixes, reverts, incident diffs: postures in [`reference/finish.md`](reference/finish.md) (single SoT).
- Reviewing an implementation plan (not code) or embedding review gates in a `$dev` `plan`: [`reference/plan-checklists.md`](reference/plan-checklists.md).
- Adding a lens or harvesting review lessons: [`reference/growth.md`](reference/growth.md).

## Handoff

- Structural findings (shallow module, dual ownership, primitive obsession, boundary leak, unmeasured hot path — not just legacy debt) **name** the `architecture` branch (`deep-modules` / `refactor-types` / `refactor-boundaries` / `performance`). Naming ≠ running; remediation enters via `$dev`.
- End-to-end PR review + publish stays here; posting an already-verified ledger → `pull-request` `comment`. Never reverse.
- `findings` never writes to GitHub.
- Land asked + readiness Yes/Conditional (owned residuals) → `pull-request` `open`. Never auto-open.
- Recurring failure classes, non-obvious security/perf traps, out-of-scope architectural friction → `harvest` (`distill` mantras; `debt` → `.agents/debt-ledger.md`).
- Delivery Ledger fields: [`../CONTEXT.md`](../CONTEXT.md).

## Completion criteria

| Execution | Done when |
| --- | --- |
| `findings` | Selected lenses applied; Critical empty or owned; Important owned/rationale; readiness Yes/No/Conditional; finish output shape; no GitHub writes |
| `quality` | Audit table (legacy Find rows or explicit empty); commit stack executed (or explicit empty); gates green; P0/P1 fixed or listed for re-invoke |
| `publish` | Fresh multi-lens ledger verified on PR head SHA; drafts reconciled; submitted `COMMENT` or left PENDING (explicit draft-only); URLs reported; no code changed |
