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
4. **Execution is `quality`:** You MUST view [`reference/quality.md`](reference/quality.md) and [`reference/legacy.md`](reference/legacy.md).
5. **Execution is `publish`:** You MUST view [`reference/publish.md`](reference/publish.md), [`reference/conventional-comments.md`](reference/conventional-comments.md), and [`reference/github-state.md`](reference/github-state.md).
6. **Ruby Hot Path / Allocations:** View [`reference/perf.md`](reference/perf.md).

Do NOT generate findings until the appropriate reference files are loaded into your working context.

## Required Output Schema (All Reviews)

Produce one combined report using this exact structure (specialized lenses contribute checks into these sections):

### Findings

- Categorize each item as **Critical**, **Important**, or **Nice-to-Have**.
- For each finding: cite exact file/line evidence, explain the concrete failure mechanism, and state the recommended remediation.

### Non-Goals

- Explicit exclusions and intentionally unaddressed areas.

### Confidence & Uncertainty

- Separate verified codebase facts from inferred or unverified assumptions (including security boundary assumptions).

### Compliance & Risk Posture

- Explicit evaluation: What passes review, what is flagged, and minimum viable remediation or compensating controls.

### Executive Summary

- **Production readiness:** `Yes` | `No` | `Conditional`
- **Top risks:** Bulleted highest-priority failure modes.
- **Immediate actions:** Clear next steps before merge/deployment.

## Incident & Fix-Diff Postures

When reviewing fixes, reverts, or incident-related changes, check:

1. Did this fix wander onto a second surface? (One-surface incident law).
2. Is a neighboring layer absorbing a boundary failure?
3. Does the path assume an invisible contract (shape, reload, cache identity, cutover successor)?
4. Is disclosure or access treated as mere presence?
5. Did validate and execute see the same truth?
6. Is each guard or policy owned at one lifecycle point?
7. Does the published contract accept only what runtime accepts?
8. Did uniqueness or readiness race across a suspension/startup gate?
9. Did a durable/plain bag get treated as a live domain object without rehydrate?
10. Did parse/unwrap or generated-client types escape the transport/adapter edge?
11. Was a wire enum renamed in app code instead of normalized once at the boundary?
12. Did TypeScript changes silence the checker with `as` / `!` / bare suppression instead of earning the type?

## Handoff

- End-to-end PR review + publish stays in this skill.
- Posting an already-verified ledger continues with the `pull-request` skill `comment` branch.
- Findings execution never posts to GitHub.
- If user asked to land and readiness is Yes/Conditional (owned residuals) → continue with `pull-request` **`open`**. Never auto-open without that ask.

## Completion criteria

| Execution  | Done when                                                                                                                                                               |
| ---------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `findings` | Every selected lens applied; Critical empty or owned; Important owned/rationale; readiness Yes/No/Conditional; Required Output Schema satisfied; no GitHub writes       |
| `quality`  | Audit table produced (legacy Find rows present or explicit empty); commit stack executed (or explicit empty); gates green; P0/P1 fixed or listed for re-invoke          |
| `publish`  | Fresh multi-lens ledger verified on PR head SHA; drafts reconciled; submitted as `COMMENT` or left PENDING when draft-only was explicit; URLs reported; no code changed |
