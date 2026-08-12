---
name: review.gil
description: >
  Review a local change, branch, or pull request for production readiness, tests,
  performance, security, legacy/dead-compat debt, or merge-prep quality. Use when
  the user wants a finish readiness review, a PR code review, to publish a review
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

## Select review lenses

After scope prep, load references progressively:

| Lens       | Load when                                                                                                                                       |
| ---------- | ----------------------------------------------------------------------------------------------------------------------------------------------- |
| `finish`   | Baseline for every generic findings or publish review                                                                                           |
| `tests`    | Tests changed, behavior changed without convincing coverage, or the user explicitly asks for test quality                                       |
| `perf`     | Ruby code changes a plausibly hot path, query/allocation behavior, or the user explicitly asks for Ruby performance                             |
| `security` | Authn/authz, tenancy, sensitive data, external inputs, secrets, privileged operations, resilience, or explicit request                          |
| `legacy`   | Deprecated/obsolete markers, dual exports, superseded store/wire hydrate, or user asks for legacy/tech-debt cleanup; **always** under `quality` |

For an explicitly focused tests, performance, security, or legacy review, load only that lens unless another lens is necessary to verify a concrete finding. Never ask “which review?” when the target is known.

Produce one report, not one report per lens. Generic findings use the `finish` output structure; specialized references contribute checks and finding-specific evidence. Fold security assumptions into **Confidence & Uncertainty** and its compliance summary into **Compliance & Risk Posture**. Publish uses the ledger and review-body structure in `publish.md`. A focused review may use its lens-specific output.

## Scope prep

Resolve bundled scripts relative to this installed skill directory.

- **Pull request:** skip local/default-branch comparison. Run `scripts/pr-context.sh <pr-url-or-number>` for findings or `scripts/pr-context.sh --publish <pr-url-or-number>` for publish, fetch the PR patch, and inspect surrounding code at the recorded head SHA.
- **Local branch/change:** identify repo root and default branch, then run `scripts/compare_default_branch.sh`. If unavailable, compare `HEAD` with `origin/<default>` directly.
- **Every target:** read `AGENTS.md` when present, distinguish unrelated dirty changes, and summarize scope plus high-risk areas before selecting lenses.
- **`quality`:** follow its Phase 0 instead of this prep.

## References

- Baseline findings → [`reference/finish.md`](reference/finish.md)
- Tests lens → [`reference/tests.md`](reference/tests.md)
- Ruby performance lens → [`reference/perf.md`](reference/perf.md)
- Security/compliance lens → [`reference/security.md`](reference/security.md)
- Legacy / dead-compat lens → [`reference/legacy.md`](reference/legacy.md)
- Merge-prep execution → [`reference/quality.md`](reference/quality.md)
- PR publish orchestration → [`reference/publish.md`](reference/publish.md); at drafting load [`reference/conventional-comments.md`](reference/conventional-comments.md), and immediately before mutation load [`reference/github-state.md`](reference/github-state.md)
- Harvest only → [`reference/growth.md`](reference/growth.md) + [`reference/learning-log.md`](reference/learning-log.md)
- Plan embed (checklists only) → [`reference/plan-checklists.md`](reference/plan-checklists.md) via [`dev/reference/plan-pipeline.md`](../dev/reference/plan-pipeline.md); **not** a findings run

## Handoff

- End-to-end PR review + publish stays in this skill.
- Posting an already-verified ledger continues with the `pull-request` skill `comment` branch.
- Findings execution never posts.

## Completion criteria

| Execution  | Done when                                                                                                                                                               |
| ---------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `findings` | Every selected lens applied; Critical empty or owned; Important owned/rationale; readiness Yes/No/Conditional; no GitHub writes                                         |
| `quality`  | Audit table produced (legacy Find rows present or explicit empty); commit stack executed (or explicit empty); gates green; P0/P1 fixed or listed for re-invoke          |
| `publish`  | Fresh multi-lens ledger verified on PR head SHA; drafts reconciled; submitted as `COMMENT` or left PENDING when draft-only was explicit; URLs reported; no code changed |
