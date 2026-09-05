---
name: pull-request
description: >
  Pull-request GitHub lifecycle. Use when the user wants to open a pull request,
  slice one branch into smaller pull requests, update PR title or description,
  post an already-verified finding ledger, resolve review feedback on the current
  branch, reply on existing review threads, fix failing CI on a PR, resolve merge
  conflicts / rebase a PR onto its base, or unblock / make a PR merge-ready.
---

# Pull Request

GitHub pull request lifecycle on a remote PR or branch destined to become one.

## Pick branch

Map the user prompt to exactly one branch (or the unblock chain):

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

**Unblock chain** (not a branch): "unblock this PR", "make merge-ready", "autopilot this PR" → refresh live PR state each pass; run **conflicts** → **resolve** → **fix-ci** in that order; stop for `needs-user`; never approve/merge.

Ambiguous routing:

| User says                                                                                                             | Branch                                         |
| --------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------- |
| "address PR comments", "fix review feedback", "resolve comments"                                                      | **resolve**                                    |
| "reply to comments", "respond on GitHub", "draft replies" (existing threads only)                                     | **reply**                                      |
| "post these already-verified findings"                                                                                | **comment** (submit `COMMENT`)                 |
| "add these as pending/draft comments" (verified list)                                                                 | **comment** (remain pending)                   |
| "open a PR", "commit and create PR"                                                                                   | **open**                                       |
| "split into PRs", "slice branch"                                                                                      | **slice**                                      |
| "update title", "update description", "update PR title/desc", "refresh PR summary", "/pull-request update title+desc" | **retitle**                                    |
| "update the PR" (no code change and no review-feedback ask)                                                           | **retitle**                                    |
| "failing ci", "fix CI", Actions run URL + fix                                                                         | **fix-ci**                                     |
| "why is CI failing?" (no fix ask)                                                                                     | report only — do not push                      |
| "merge conflicts", "rebase on main", "rebase onto base"                                                               | **conflicts**                                  |
| "unblock", "make merge-ready", "get this PR green"                                                                    | **unblock chain**                              |
| "review the PR"                                                                                                       | stop — use the **review.gil** skill            |
| "draft a review" (read-only findings)                                                                                 | stop — use **review.gil** `findings`           |
| "post review comments", "new findings on PR", "review and post on GitHub"                                             | stop — use **review.gil** `publish`            |
| "draft/pending a new review" (no supplied ledger)                                                                     | stop — use **review.gil** `publish` draft-only |
| "publish review to PR" / end-to-end review+publish                                                                    | stop — use **review.gil** skill `publish`      |

**comment** vs **reply**: **comment** posts already-verified findings supplied by the user or another workflow. End-to-end retrieve → review → reconcile → publish belongs to **`review.gil` `publish`**, not this skill. **reply** answers an existing thread and must not add new findings or code changes.

Default ambiguous "address comments" → **resolve**, not **reply**. Ambiguous "update the PR" with no code/feedback → **retitle**, not **open**.

## Shared contract

- Required tools: `git`, `gh`, `jq`.
- Use non-interactive commands and explicit flags.
- Escalate network permissions for `gh` when sandboxing blocks GitHub API calls.
- Resolve bundled script paths relative to this skill directory, not the repo working directory.
- Prefer `./scripts/gh-review-comments --filter unresolved --format json <pr-url>` for structured thread data on **resolve** and **reply**.
- Frugal fetches: failing-job logs only on **fix-ci**; unresolved threads only on **resolve**/**reply**; explicit `--json` field lists; never paste raw JSON payloads into context or output.
- Do not ask the user to manually fetch PR or review-comment data unless automated discovery fails.
- When **comment** submits, use GitHub `event: COMMENT` only; never submit `APPROVE` or `REQUEST_CHANGES`. Pending/draft language means no `event` and no submission.
- Title/body narrative for **open** and **retitle** follows [`reference/pr-narrative.md`](reference/pr-narrative.md).
- Never auto-approve or merge from this skill.

## Context pointers

Load only the matched branch reference:

- **open** — follow [`reference/open.md`](reference/open.md) until `gh pr view` confirms a PR (or browser flow confirmed created). Prefill title/body per [`reference/pr-narrative.md`](reference/pr-narrative.md).
- **slice** — follow [`reference/slice.md`](reference/slice.md). Do not start open or resolve until the slice ledger marks that PR ready.
- **retitle** — follow [`reference/retitle.md`](reference/retitle.md); load [`reference/pr-narrative.md`](reference/pr-narrative.md) for title/body.
- **comment** — follow [`reference/comment.md`](reference/comment.md). Load [`reference/gh-api.md`](reference/gh-api.md) when posting.
- **resolve** — follow [`reference/resolve.md`](reference/resolve.md). Load [`reference/gh-api.md`](reference/gh-api.md) when resolving threads.
- **reply** — follow [`reference/reply.md`](reference/reply.md). Load [`reference/gh-api.md`](reference/gh-api.md) when posting replies.
- **fix-ci** — follow [`reference/fix-ci.md`](reference/fix-ci.md).
- **conflicts** — follow [`reference/conflicts.md`](reference/conflicts.md).
- **unblock chain** — load each branch reference only when that step runs.

## Handoff

- Read-only or end-to-end PR review → the `review.gil` skill; it asks whether to publish before reviewing.
- Posting a supplied, already-verified ledger stays in **comment**.
- Resolving or replying to existing feedback stays in this skill.
- Narrative-only PR updates stay in **retitle**.
- Dependabot PR assessment (changelog / approve-readiness) → `dependabot` **triage** (may call back into **fix-ci**).
- Multi-repo attention list → `pr-sweep` (read-only; does not fix).
- Harvest feedback: after landing a PR, resolving non-obvious review comments, or fixing systemic CI failures, hand off to `harvest` (`distill` for preventive mantras, `debt` for `.agents/debt-ledger.md`).

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
