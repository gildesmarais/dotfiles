---
name: review.gil
description: >
  Review a local change, branch, or pull request for production readiness, tests,
  performance, security, legacy/dead-compat debt, or merge-prep quality. Use when
  the user wants a findings-ready review, a PR code review, to publish a review
  to a PR, /code-review, /review.gil, or when another skill needs a
  production-readiness or test-quality pass.
---

# Review

Findings-first analysis of a working tree, branch, commit range, or pull request. A generic review runs the production-readiness baseline plus only the specialized lenses the diff warrants. It never asks the user to choose a review template.

## Choose execution

For a review associated with a pull request, the first step is to ask exactly:

> Publish review on PR?

Skip the question when the user already answered it, explicitly asked for a read-only/draft findings report, or the target has no pull request. The answer selects execution, not review lenses:

| Execution  | Use when                                                                                       |
| ---------- | ---------------------------------------------------------------------------------------------- |
| `findings` | Read-only review; default for non-PR targets or when the user declines publishing              |
| `publish`  | Review a PR end to end, reconcile drafts, and submit a friendly GitHub `COMMENT` review        |
| `quality`  | Explicit merge-prep execution: audit, boy-scout refactors, tests, and repo gates; changes code |

Routing rules:

- “Review and publish/post/ship the review” → `publish`; do not ask again.
- “Post these findings” with an already-verified list → stop and use the `pull-request` skill `comment` branch.
- “Draft review” means read-only findings unless the user explicitly asks for GitHub-pending review comments. End-to-end review drafts use `publish` and stop before submission; a supplied, already-verified ledger uses the `pull-request` skill `comment` branch even when it should remain pending.
- Never infer `quality` from “review.” It requires explicit permission to change code.

## Scope prep

Resolve bundled scripts relative to this installed skill directory.

- **Pull request:** skip local/default-branch comparison. Run `scripts/pr-context.sh <pr-url-or-number>` for findings or `scripts/pr-context.sh --publish <pr-url-or-number>` for publish, fetch the PR patch, and inspect surrounding code at the recorded head SHA.
- **Local branch/change:** identify repo root and default branch, then run `scripts/compare_default_branch.sh`. If unavailable, compare `HEAD` with `origin/<default>` directly.
- **Every target:** read `AGENTS.md` when present, distinguish unrelated dirty changes, and summarize scope plus high-risk areas before selecting lenses.
- **`quality`:** follow its Phase 0 instead of this prep.

## Phase 0: Mandatory Context Pre-Flight (Blocking)

Before evaluating code, drafting findings, or generating review output, execute `view_file` on the required reference files for this target:

1. **Always (Baseline):** You MUST view [`reference/finish.md`](reference/finish.md).
2. **Behavior or Tests Changed:** You MUST view [`reference/tests.md`](reference/tests.md).
3. **Auth, Tenancy, Sensitive Data, Secrets, APIs, SQL, or Boundaries:** You MUST view [`reference/security.md`](reference/security.md).
4. **Dead-compat signals** (deprecated markers, dual exports, superseded hydrate): You MUST view [`reference/legacy.md`](reference/legacy.md). Under `findings` / `publish`, report only — do not delete (deletion stays `quality`-only).
5. **Execution is `quality`:** You MUST view [`reference/quality.md`](reference/quality.md) and [`reference/legacy.md`](reference/legacy.md) (always under `quality`, even without dead-compat signals).
6. **Execution is `publish`:** You MUST view [`reference/publish.md`](reference/publish.md), [`reference/conventional-comments.md`](reference/conventional-comments.md), and [`reference/github-state.md`](reference/github-state.md).
7. **Hot path / allocations (any language):** View [`reference/perf.md`](reference/perf.md).

Do NOT generate findings until the appropriate reference files are loaded into your working context.

Output shape: [`reference/finish.md`](reference/finish.md) § Output format.

## Incident & Fix-Diff Postures

When reviewing fixes, reverts, or incident-related changes, apply the incident / fix-diff postures in [`reference/finish.md`](reference/finish.md) (single SoT — do not duplicate the list here).

## Handoff

- **Structural findings name craft:** when a finding is structural (shallow module, dual ownership, primitive obsession, boundary leak, unmeasured hot path — not just legacy debt), name the matching `architecture` craft branch (`deep-modules` / `refactor-types` / `refactor-boundaries` / `performance`) as the remediation route. Naming is not running — remediation still enters via `$dev`.
- End-to-end PR review + publish stays in this skill.
- Posting an already-verified ledger continues with the `pull-request` skill `comment` branch.
- Findings execution never posts to GitHub.
- If user asked to land and readiness is Yes/Conditional (owned residuals) → continue with `pull-request` **`open`**. Never auto-open without that ask.
- **Harvest feedback:** when review uncovers recurring failure classes, non-obvious security/perf traps, or deferred architectural friction that cannot be fixed in scope, hand off to `harvest` (`distill` for preventive mantras, `debt` for `.agents/debt-ledger.md`).

## Completion criteria

| Execution  | Done when                                                                                                                                                               |
| ---------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `findings` | Every selected lens applied; Critical empty or owned; Important owned/rationale; readiness Yes/No/Conditional; finish.md output shape satisfied; no GitHub writes       |
| `quality`  | Audit table produced (legacy Find rows present or explicit empty); commit stack executed (or explicit empty); gates green; P0/P1 fixed or listed for re-invoke          |
| `publish`  | Fresh multi-lens ledger verified on PR head SHA; drafts reconciled; submitted as `COMMENT` or left PENDING when draft-only was explicit; URLs reported; no code changed |
