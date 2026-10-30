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

**Unblock chain** (not a branch; order: [`../CONTEXT.md`](../CONTEXT.md)): "unblock", "make merge-ready", "get this PR green", "autopilot this PR" → refresh live PR state each pass; **conflicts** → **resolve** → **fix-ci**; stop for `needs-user`.

Ambiguous routing:

| User says | Route |
| --------- | ----- |
| "address/fix/resolve PR comments" (code ok) | **resolve** (not reply) |
| "update the PR" (no code, no review-feedback) | **retitle** |
| "post these already-verified findings" (ledger given) | **comment** |
| "review the PR" / "post review" / draft without ledger | stop — `review.gil` (`findings` or `publish`) |

`comment` = verified ledger only. End-to-end review → `review.gil` `publish`. **reply** = existing threads, no code, no new findings. "why is CI failing?" (no fix) → report only.

## Shared prep

- Tools: `git`, `gh`, `jq`; non-interactive. Escalate network for `gh` when sandboxed.
- Resolve scripts relative to this skill directory. Thread data on **resolve**/**reply**: `./scripts/gh-review-comments --filter unresolved --format json <pr-url>`.
- Frugal fetches: failing-job logs only (**fix-ci**); unresolved threads only (**resolve**/**reply**); explicit `--json` fields; never paste raw JSON.
- Comment/event policy: [`reference/gh-api.md`](reference/gh-api.md). Never auto-approve or merge.

## Branch reference

Load only the matched branch; unblock chain loads each step when it runs.

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
- After landing, non-obvious review fixes, or systemic CI → `harvest` (`distill`; `debt` → `.agents/debt-ledger.md`).

## Completion criteria

Per-branch **Done when** in the matched reference. Unblock: conflicts clear, threads triaged, CI green or blockers reported.
