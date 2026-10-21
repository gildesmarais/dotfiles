---
name: release
description: >-
  Release notes from Conventional Commits in a merged ship range. Use when the
  user wants a changelog or release notes after merge.
---

# Release

Notes-only: consumes merged history; never authors or rewrites it.

## Pick branch

| Signal                                 | Branch                    |
| -------------------------------------- | ------------------------- |
| changelog, release notes, what shipped | `notes`                   |
| open/slice/resolve a PR                | stop — use `pull-request` |
| flag / promote / roll back a release   | out of scope — no branch  |

## Shared prep

- Ship range: tags, merge-base…HEAD, or user-named commits; prefer default-branch merges.
- Commit types: [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/); authoring → [`../dev/reference/phase-commits.md`](../dev/reference/phase-commits.md). `git log` / `git show`; never invent commits.
- Does not open PRs, tag, flag, promote, or roll back.

## Branch reference

- **`notes`** → [`reference/notes.md`](reference/notes.md)

## Handoff

- PR lifecycle → `pull-request`. Phase-commit authoring → `dev` / `architecture`.

## Completion criteria

Per [`reference/notes.md`](reference/notes.md) Done when.
