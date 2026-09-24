---
name: pr-sweep
description: >-
  Read-only morning PR attention ledger across a GitHub org or owner the user
  names; each row names the store skill invocation to run next. Use for
  /pr-sweep, "what PRs need me?", or weekday chore sweeps.
---

# PR Sweep

Self-contained on purpose (automation bootstrap).

## Pick branch

Single branch: **`report`**.

## Shared prep

- Never fixes anything: **never** checkout, push, comment, approve, or merge. Output is the ledger only.
- Require an org/owner from the user or automation prompt; no default org.
- Tools `gh`, `jq`; escalate network when sandboxed. Explicit `--json` field lists; no raw JSON, diffs, or CI logs in output.

## Branch reference

- **report** — [`reference/report.md`](reference/report.md)

## Handoff

Each row points at a store invocation:

| Blocker                       | Invocation                               |
| ----------------------------- | ---------------------------------------- |
| Failing CI                    | `/pull-request fix-ci <url>`             |
| Merge conflicts               | `/pull-request conflicts <url>`          |
| Unresolved review on owned PR | `/pull-request resolve <url>`            |
| Dependabot fallout            | `/dependabot triage <url>`               |
| Review requested (you)        | `/review.gil <url>` (ask publish)        |
| Unblock several blockers      | `/pull-request` unblock chain on `<url>` |

## Completion criteria

| Branch     | Done when                                                                                            |
| ---------- | ---------------------------------------------------------------------------------------------------- |
| **report** | Compact ledger emitted (or explicit empty); each row has repo, PR, blocker, invocation; no mutations |
