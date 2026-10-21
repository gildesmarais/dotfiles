---
name: pull-request
description: >-
  Pull-request GitHub lifecycle. Use to open a PR, slice into smaller PRs,
  retitle, post a verified finding ledger, resolve review feedback, reply on
  threads, fix failing CI, resolve conflicts / rebase, or unblock / make a PR
  merge-ready.
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

**Unblock chain** (not a branch): "unblock", "make merge-ready", "get this PR green", "autopilot this PR" → refresh live PR state each pass; run **conflicts** → **resolve** → **fix-ci**; stop for `needs-user`; never approve/merge.

Ambiguous routing (state once here):

| User says                                                                 | Route                                    |
| ------------------------------------------------------------------------- | ---------------------------------------- |
| "address PR comments", "fix review feedback", "resolve comments"          | **resolve** (not reply)                  |
| "update the PR" (no code change, no review-feedback ask)                  | **retitle** (not open)                   |
| "why is CI failing?" (no fix ask)                                         | report only — do not push                |
| "post these already-verified findings" / "add as pending" (ledger given)  | **comment** (submit or remain pending)  |
| "review the PR" / "draft a review" (read-only findings)                   | stop — `review.gil` (`findings`)         |
| "post review comments", "new findings on PR", "review and post"           | stop — `review.gil` `publish`            |
| "draft/pending a new review" (no supplied ledger)                         | stop — `review.gil` `publish` draft-only |

`comment` = verified ledger only. End-to-end review → `review.gil` `publish`. **reply** = existing threads, no code, no new findings.

## Shared prep

- Tools: `git`, `gh`, `jq`; non-interactive. Escalate network for `gh` when sandboxed.
- Resolve scripts relative to this skill directory. Thread data on **resolve**/**reply**: `./scripts/gh-review-comments --filter unresolved --format json <pr-url>`.
- Frugal fetches: failing-job logs only (**fix-ci**); unresolved threads only (**resolve**/**reply**); explicit `--json` fields; never paste raw JSON. Don't ask the user to fetch PR/thread data unless discovery fails.
- **comment** submits `event: COMMENT` only — never `APPROVE` or `REQUEST_CHANGES`. Pending/draft → no `event`, no submission.
- Never auto-approve or merge.

## Branch reference

Load only the matched branch; for the unblock chain, load each when its step runs.

- **open** — [`reference/open.md`](reference/open.md); title/body per [`reference/pr-narrative.md`](reference/pr-narrative.md).
- **slice** — [`reference/slice.md`](reference/slice.md). No open/resolve until its ledger row marks ready.
- **retitle** — [`reference/retitle.md`](reference/retitle.md) + [`reference/pr-narrative.md`](reference/pr-narrative.md).
- **comment** — [`reference/comment.md`](reference/comment.md); [`reference/gh-api.md`](reference/gh-api.md) when posting.
- **resolve** — [`reference/resolve.md`](reference/resolve.md); [`reference/gh-api.md`](reference/gh-api.md) when resolving.
- **reply** — [`reference/reply.md`](reference/reply.md); [`reference/gh-api.md`](reference/gh-api.md) when posting.
- **fix-ci** — [`reference/fix-ci.md`](reference/fix-ci.md).
- **conflicts** — [`reference/conflicts.md`](reference/conflicts.md).

## Handoff

- Land ask + Assure readiness Yes/Conditional → **open** (do not re-ask "want a PR?").
- Dependabot PR assessment → `dependabot` **triage** (may call back into **fix-ci**/**conflicts**).
- Multi-repo attention list → `pr-sweep` (read-only).
- After landing a PR, resolving non-obvious review comments, or fixing systemic CI → `harvest` (`distill`; `debt` → `.agents/debt-ledger.md`).

## Completion criteria

| Branch            | Done when                                                                                                                          |
| ----------------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| **open**          | Session-touched commits pushed; `gh pr view` shows PR; ticket in title when branch encodes one; body matches `pr-narrative.md`     |
| **slice**         | Every planned slice has ledger row (branch, commits, validation, PR URL or deferred); worktrees cleaned only after user ok         |
| **retitle**       | `gh pr edit` applied; narrative rebuilt from full `base...HEAD`; Review map obeys size gates and tests-first ordering              |
| **comment**       | Every finding verified against PR head SHA + diff line; pending/submitted state matches ask; landed comments verified via API      |
| **resolve**       | Every unresolved thread assessed; valid ones fixed+pushed; resolved threads cite commit hash or left open with reason              |
| **reply**         | Every requested thread has a reply; no new inline findings; no code changes                                                        |
| **fix-ci**        | Failures classified; caused-by-PR fixed+pushed or flake/infra/needs-user reported; checks watched once after push                  |
| **conflicts**     | Rebased/merged onto base; intents preserved or user asked; `mergeable` (or only CI-dirty); pushed with lease when rebase required  |
| **unblock chain** | Conflicts clear, unresolved threads triaged, CI green or blockers reported; no approve/merge                                       |
