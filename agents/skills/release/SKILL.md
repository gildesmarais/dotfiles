---
name: release
description: >
  Release notes from Conventional Commits in a merged ship range. Use when the
  user wants a changelog or release notes after merge. Notes-only — does not
  flag, promote, or roll back releases, and does not open pull requests.
---

# Release

Changelog / release notes derived from merged Conventional Commits. Author history during Solution/Build phases — this skill only consumes it.

## Pick branch

| Branch  | Job                                                          | Status |
| ------- | ------------------------------------------------------------ | ------ |
| `notes` | Changelog from Conventional Commits in the merged ship range | active |

| Signal                                 | Branch                    |
| -------------------------------------- | ------------------------- |
| changelog, release notes, what shipped | `notes`                   |
| open/slice/resolve a PR                | stop — use `pull-request` |
| flag / promote / rollback a release    | out of scope — no branch  |

## Shared prep

1. Confirm the ship range (tags, merge base…HEAD, or user-named commits). Prefer merged history on the default branch.
2. Format and phase-commit law live in [`CONTEXT.md`](../CONTEXT.md) — do not re-author commits here.
3. Inspect with `git log` / `git show`; never invent commits or wait until notes to write history.

## Branch reference

- **`notes`** → [`reference/notes.md`](reference/notes.md)

## Handoff

- PR lifecycle stays in `pull-request`. Phase CC authoring stays in `architecture` / `dev` (leftover applicator: `pull-request` **`open`**).
- No flag / promote / rollback from this skill.

## Completion criteria

| Branch  | Done when                                                                                  |
| ------- | ------------------------------------------------------------------------------------------ |
| `notes` | Notes grouped Breaking → Features → Fixes → other from the ship range; no invented commits |
