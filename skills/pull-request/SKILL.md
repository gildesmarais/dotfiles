---
name: pull-request
description: >
  Pull-request GitHub lifecycle. Use when the user wants to open a pull request,
  slice one branch into smaller pull requests, comment verified findings on a pull
  request, resolve review feedback on the current branch, or reply on existing
  review threads.
---

# Pull Request

GitHub pull request lifecycle on a remote PR or branch destined to become one.

## Pick branch

Map the user prompt to exactly one branch:

| User intent                                                  | Branch      |
| ------------------------------------------------------------ | ----------- |
| Commit session work, push, create PR                         | **open**    |
| Split one branch into smaller PRs                            | **slice**   |
| Post new verified findings on a PR (inline review comments)  | **comment** |
| Fix review feedback end-to-end (assess, code, push, resolve) | **resolve** |
| Respond on existing threads only — no new findings, no code  | **reply**   |

Ambiguous routing:

| User says                                                                         | Branch                                      |
| --------------------------------------------------------------------------------- | ------------------------------------------- |
| "address PR comments", "fix review feedback", "resolve comments"                  | **resolve**                                 |
| "reply to comments", "respond on GitHub", "draft replies" (existing threads only) | **reply**                                   |
| "post review comments", "pending review comments", "new findings on PR"           | **comment**                                 |
| "open a PR", "commit and create PR"                                               | **open**                                    |
| "split into PRs", "slice branch"                                                  | **slice**                                   |
| "review the PR" (local findings only)                                             | stop — use **review** skill, not this skill |
| "review the PR" (post on GitHub)                                                  | **comment**                                 |

**comment** vs **reply**: **comment** introduces new verified findings as inline review comments. **reply** answers an existing thread and must not add new findings or code changes.

Default ambiguous "address comments" → **resolve**, not **reply**.

## Shared contract

- Required tools: `git`, `gh`, `jq`.
- Use non-interactive commands and explicit flags.
- Escalate network permissions for `gh` when sandboxing blocks GitHub API calls.
- Resolve bundled script paths relative to this skill directory, not the repo working directory.
- Prefer `./scripts/gh-review-comments --filter unresolved --format json <pr-url>` for structured thread data on **resolve** and **reply**.
- Do not ask the user to manually fetch PR or review-comment data unless automated discovery fails.

## Context pointers

Load only the matched branch reference:

- **open** — follow [`reference/open.md`](reference/open.md) until `gh pr view` confirms a PR (or browser flow confirmed created).
- **slice** — follow [`reference/slice.md`](reference/slice.md). Do not start open or resolve until the slice ledger marks that PR ready.
- **comment** — follow [`reference/comment.md`](reference/comment.md). Load [`reference/gh-api.md`](reference/gh-api.md) when posting.
- **resolve** — follow [`reference/resolve.md`](reference/resolve.md). Load [`reference/gh-api.md`](reference/gh-api.md) when resolving threads.
- **reply** — follow [`reference/reply.md`](reference/reply.md). Load [`reference/gh-api.md`](reference/gh-api.md) when posting replies.

## Completion criteria

| Branch      | Done when                                                                                                                                 |
| ----------- | ----------------------------------------------------------------------------------------------------------------------------------------- |
| **open**    | Session-touched commits pushed; `gh pr view` shows a PR (or browser flow confirmed created); ticket in title when branch encodes one      |
| **slice**   | Every planned slice has ledger row: branch, commits, validation result, PR URL or explicit deferred; worktrees cleaned only after user ok |
| **comment** | Every finding verified against PR head SHA + diff line; pending/submitted state matches user ask; landed comments verified via API        |
| **resolve** | Every unresolved thread assessed; valid ones fixed+pushed; resolved threads cite commit hash or left open with reason                     |
| **reply**   | Every requested thread has a reply; no new inline findings; no code changes                                                               |
