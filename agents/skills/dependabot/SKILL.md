---
name: dependabot
description: >-
  GitHub Dependabot configuration and PR triage. Use to create or optimize
  dependabot.yml, group updates, or assess/fix fallout on a Dependabot PR.
---

# Dependabot

## Pick branch

| User intent                                                   | Branch        |
| ------------------------------------------------------------- | ------------- |
| Create/optimize `.github/dependabot.yml`, group updates       | **configure** |
| Assess / fix fallout on a Dependabot PR ("bot bump broke CI") | **triage**    |

## Shared prep

- Repo already generates Dependabot/CODEOWNERS from one ownership SoT → use that repo-local generator; never hand-edit its output.
- Never approve, enable auto-merge, or merge. Never rewrite/amend bot commits.
- No raw JSON or full Actions logs in context.

## Branch reference

- **configure** — [`reference/configure.md`](reference/configure.md); [`reference/yml-keys.md`](reference/yml-keys.md) only when editing keys.
- **triage** — [`reference/triage.md`](reference/triage.md); [`reference/pr-commands.md`](reference/pr-commands.md) only when posting `@dependabot` commands.

## Handoff

- CI fallout → `pull-request` **fix-ci** (separate fix commits on top of bot commits).
- Conflicts → `@dependabot rebase` when no manual commits yet; otherwise `pull-request` **conflicts**.
- Multi-repo stale Dependabot discovery → `pr-sweep`.

## Completion criteria

Per-branch Done when in the matched reference. Never approve/merge.
