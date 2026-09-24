---
name: pull-request
description: >-
  Pull-request GitHub lifecycle. Use to open a pull request, slice one branch
  into smaller PRs, update PR title or description, post an already-verified
  finding ledger, resolve review feedback, reply on existing review threads, fix
  failing CI on a PR, resolve merge conflicts / rebase onto base, or unblock /
  make a PR merge-ready.
---

# Pull Request

## Pick branch

| User intent                                                  | Branch        |
| ------------------------------------------------------------ | ------------- |
| Commit session work, push, create PR                         | **open**      |
| Split one branch into smaller PRs                            | **slice**     |
| Update PR title and/or description (no code)                 | **retitle**   |
| Submit already-verified findings on a PR                     | **comment**   |
| Fix review feedback end-to-end (assess, code, push, resolve) | **resolve**   |
| Respond on existing threads only — no new findings, no code  | **reply**     |
| Fix failing CI on a PR / Actions run                         | **fix-ci**    |
| Resolve merge conflicts / rebase PR onto base                | **conflicts** |

**Unblock chain** (not a branch): "unblock", "make merge-ready", "get this PR green", "autopilot this PR" → refresh live PR state each pass; run **conflicts** → **resolve** → **fix-ci** in that order; stop for `needs-user`; never approve/merge.

Ambiguous routing:

| User says                                                                 | Route                                    |
| ------------------------------------------------------------------------- | ---------------------------------------- |
| "address PR comments", "fix review feedback", "resolve comments"          | **resolve** (not reply)                  |
| "update the PR" (no code change, no review-feedback ask)                  | **retitle** (not open)                   |
| "why is CI failing?" (no fix ask)                                         | report only — do not push                |
| "post these already-verified findings"                                    | **comment** (submit `COMMENT`)           |
| "add these as pending/draft comments" (verified list supplied)            | **comment** (remain pending)             |
| "review the PR"                                                           | stop — `review.gil`                      |
| "draft a review" (read-only findings)                                     | stop — `review.gil` `findings`           |
| "post review comments", "new findings on PR", "review and post on GitHub" | stop — `review.gil` `publish`            |
| "draft/pending a new review" (no supplied ledger)                         | stop — `review.gil` `publish` draft-only |

## Shared prep

- Tools: `git`, `gh`, `jq`; non-interactive commands. Escalate network permissions for `gh` when sandboxing blocks GitHub API calls.
- Resolve bundled script paths relative to this skill directory, not the repo. Thread data on **resolve**/**reply**: `./scripts/gh-review-comments --filter unresolved --format json <pr-url>`.
- Frugal fetches: failing-job logs only (**fix-ci**); unresolved threads only (**resolve**/**reply**); explicit `--json` field lists; never paste raw JSON into context or output. Don't ask the user to fetch PR/thread data unless automated discovery fails.
- **comment** submits GitHub `event: COMMENT` only — never `APPROVE` or `REQUEST_CHANGES`. Pending/draft → no `event`, no submission.
- Never auto-approve or merge.

## Branch reference

Load only the matched branch; for the unblock chain, load each when its step runs.

- **open** — [`reference/open.md`](reference/open.md); title/body per [`reference/pr-narrative.md`](reference/pr-narrative.md).
- **slice** — [`reference/slice.md`](reference/slice.md). No open/resolve for a slice until its ledger row marks it ready.
- **retitle** — [`reference/retitle.md`](reference/retitle.md) + [`reference/pr-narrative.md`](reference/pr-narrative.md).
- **comment** — [`reference/comment.md`](reference/comment.md); [`reference/gh-api.md`](reference/gh-api.md) when posting.
- **resolve** — [`reference/resolve.md`](reference/resolve.md); [`reference/gh-api.md`](reference/gh-api.md) when resolving.
- **reply** — [`reference/reply.md`](reference/reply.md); [`reference/gh-api.md`](reference/gh-api.md) when posting.
- **fix-ci** — [`reference/fix-ci.md`](reference/fix-ci.md).
- **conflicts** — [`reference/conflicts.md`](reference/conflicts.md).

## Handoff

- Pipeline land (the batch included a PR, readiness Yes or Conditional) → **open**. Do not ask "want a PR?".
- Read-only or end-to-end PR review (retrieve → review → reconcile → publish) → `review.gil`. Posting a supplied, verified ledger stays in **comment**; **reply** never adds findings or code.
- Dependabot PR assessment → `dependabot` **triage** (may call back into **fix-ci**/**conflicts**).
- Multi-repo attention list → `pr-sweep` (read-only).
- After landing a PR, resolving non-obvious review comments, or fixing systemic CI → `harvest` (`distill` mantras; `debt` → `.agents/debt-ledger.md`).

## Completion criteria

| Branch            | Done when                                                                                                                                                            |
| ----------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **open**          | Session-touched commits pushed; `gh pr view` shows a PR (or browser flow confirmed created); ticket in title when branch encodes one; body matches `pr-narrative.md` |
| **slice**         | Every planned slice has ledger row: branch, commits, validation result, PR URL or explicit deferred; worktrees cleaned only after user ok                            |
| **retitle**       | `gh pr edit` applied; `gh pr view` shows updated title + body; narrative rebuilt from full `base...HEAD`; Review map obeys size gates and tests-first ordering       |
| **comment**       | Every finding verified against PR head SHA + diff line; pending/submitted state matches user ask; landed comments verified via API                                   |
| **resolve**       | Every unresolved thread assessed; valid ones fixed+pushed; resolved threads cite commit hash or left open with reason                                                |
| **reply**         | Every requested thread has a reply; no new inline findings; no code changes                                                                                          |
| **fix-ci**        | Failures classified; caused-by-PR fixed+pushed or flake/infra/needs-user reported; checks watched once after push                                                    |
| **conflicts**     | Branch rebased/merged onto base; conflict intents preserved or user asked; `mergeable` (or only CI-dirty); pushed with lease when rebase required                    |
| **unblock chain** | Conflicts clear, unresolved threads triaged, CI green or blockers reported; no approve/merge                                                                         |
