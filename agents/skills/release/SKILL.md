---
name: release
description: >-
  Release notes from Conventional Commits in a merged ship range. Use when the
  user wants a changelog or release notes after merge.
disable-model-invocation: true
---

# Release

Notes-only: reads merged history; never opens PRs, tags, flags, promotes, rolls back, or rewrites commits.

## Pick branch

| Signal                                 | Branch                    |
| -------------------------------------- | ------------------------- |
| changelog, release notes, what shipped | `notes`                   |
| open/slice/resolve a PR                | stop — use `pull-request` |
| flag / promote / roll back a release   | out of scope              |

## Branch reference

- **`notes`** → [`reference/notes.md`](reference/notes.md)

## Handoff

- PR lifecycle → `pull-request`. Commit authoring → [`../dev/reference/plan.md`](../dev/reference/plan.md).

## Completion criteria

Notes emitted from real history, or the history gap reported.
