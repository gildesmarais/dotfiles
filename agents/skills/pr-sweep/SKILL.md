---
name: pr-sweep
description: >
  Read-only morning PR attention ledger across a GitHub org or owner the user
  names. Use for /pr-sweep, "what PRs need me?", or weekday chore sweeps. Never
  fixes anything — each row names the exact store skill invocation to run next.
---

# PR Sweep

Intent-domain, read-only multi-repo attention report. Proliferation-guard exception: automation bootstrap needs a self-contained skill.

## Pick branch

Single branch: **`report`**.

## Shared contract

- Tools: `gh`, `jq`. Escalate network when sandboxed.
- Require an org/owner from the user (or automation prompt). Do not invent a default org.
- Explicit `--json` field lists only. Never paste raw JSON, diffs, or CI logs into output.
- **Never** checkout, push, comment, approve, or merge.

## Context pointers

- **report** — [`reference/report.md`](reference/report.md)

## Handoff

Ledger rows point at store skills only:

| Blocker                       | Invocation                               |
| ----------------------------- | ---------------------------------------- |
| Failing CI                    | `/pull-request fix-ci <url>`             |
| Merge conflicts               | `/pull-request conflicts <url>`          |
| Unresolved review on owned PR | `/pull-request resolve <url>`            |
| Dependabot fallout            | `/dependabot triage <url>`               |
| Review requested (you)        | `/review.gil <url>` (ask publish)        |
| Unblock several blockers      | `/pull-request` unblock chain on `<url>` |

Sweep never fixes — it only emits the ledger.

## Completion criteria

| Branch     | Done when                                                                                            |
| ---------- | ---------------------------------------------------------------------------------------------------- |
| **report** | Compact ledger emitted (or explicit empty); each row has repo, PR, blocker, invocation; no mutations |
