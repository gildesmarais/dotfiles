---
name: pull-request
description: >-
  Pull-request lifecycle: open, slice, retitle, post a verified finding ledger,
  resolve feedback, reply on threads, fix CI, resolve conflicts, unblock a PR.
---

# Pull Request

## Pick branch

| User intent                                                  | Branch                                         |
| ------------------------------------------------------------ | ---------------------------------------------- |
| Commit session work, push, create PR                         | [**open**](reference/open.md)                  |
| Split one branch into smaller PRs                            | [**slice**](reference/slice.md)                |
| Update PR title and/or description (no code)                 | [**retitle**](reference/retitle.md)            |
| Submit already-verified findings on a PR                     | [**comment**](reference/comment.md)            |
| Fix review feedback end-to-end (assess, code, push, resolve) | [**resolve**](reference/resolve.md)            |
| Respond on existing threads only — no new findings, no code  | [**reply**](reference/reply.md)                |
| Fix failing CI on a PR / Actions run                         | [**fix-ci**](reference/fix-ci.md)              |
| Resolve merge conflicts / rebase PR onto base                | [**conflicts**](reference/conflicts.md)        |

**Unblock chain** ("unblock", "make merge-ready", "get this PR green"; preserve intents, push with lease when rebased): refresh live PR state each pass; **conflicts** → **resolve** → **fix-ci**; stop for `needs-user`.

Routing edges: "address/fix PR comments" → **resolve**, not reply. "update the PR" with no code → **retitle**. A ledger of verified findings → **comment**; "review the PR" / "post review" without a ledger → stop, `review.gil` (`findings` or `publish`). "Why is CI failing?" (no fix) → report only.

## Shared prep

- Tools: `git`, `gh`, `jq`; non-interactive.
- Target PR: given, else current branch; ask only when none or several plausible.
- Threads for **resolve**/**reply** (script path relative to this skill): `./scripts/gh-review-comments --filter unresolved --format json <pr-url>`.
- Frugal fetches: failing-job logs only (**fix-ci**); unresolved threads only; explicit `--json` fields; never paste raw JSON.
- Comment/event policy: [`reference/gh-api.md`](reference/gh-api.md). Never auto-approve or merge.

## Branch reference

Load only the matched branch's reference; the unblock chain loads each step as it runs. Extras: **open** and **retitle** also load [`reference/pr-narrative.md`](reference/pr-narrative.md); **comment**, **resolve** and **reply** load [`reference/gh-api.md`](reference/gh-api.md) when posting or resolving. **slice** blocks open/resolve until its ledger row is ready.

## Handoff

Handoff load: [`../CONTEXT.md`](../CONTEXT.md).

- Land ask + Assure readiness Yes/Conditional → **open** (do not re-ask "want a PR?").
- Dependabot PR assessment → `dependabot` **triage** (may call back into **fix-ci**/**conflicts**).
- Multi-repo attention list → `pr-sweep` (read-only).
- After landing, non-obvious review fixes, or systemic CI → `harvest` (`distill`; `debt` → `.agents/debt-ledger.md`).

## Completion criteria

Per-branch **Done when** in the matched reference. Unblock: conflicts clear, threads triaged, CI green or blockers reported.
