---
name: dependabot
description: >
  GitHub Dependabot configuration and PR triage. Use when creating or optimizing
  dependabot.yml, grouping updates, or assessing/fixing fallout on a Dependabot PR.
  Stops before approve/merge. Prefer repo-local ownership generators when the repo
  already manages CODEOWNERS/Dependabot from a single source of truth.
---

# Dependabot

Ship-domain helper for Dependabot config and Dependabot PR triage.

## Pick branch

| User intent                              | Branch        |
| ---------------------------------------- | ------------- |
| Create/optimize `.github/dependabot.yml` | **configure** |
| Assess / fix fallout on a Dependabot PR  | **triage**    |

Ambiguous routing:

| User says                                             | Branch                                     |
| ----------------------------------------------------- | ------------------------------------------ |
| "dependabot.yml", "group updates", "ecosystem"        | **configure**                              |
| "dependabot PR", "bot bump broke CI"                  | **triage**                                 |
| "generate CODEOWNERS + dependabot" from ownership SoT | stop → repo's ownership tooling if present |

## Shared contract

- Progressive load: only the matched branch reference.
- Never paste raw JSON or full Actions logs into context.
- Never approve or merge from this skill.
- If the repo already generates Dependabot/CODEOWNERS from ownership config, prefer that tool over hand-editing.

## Context pointers

- **configure** — [`reference/configure.md`](reference/configure.md); load [`reference/yml-keys.md`](reference/yml-keys.md) only when editing keys.
- **triage** — [`reference/triage.md`](reference/triage.md); load [`reference/pr-commands.md`](reference/pr-commands.md) only when posting `@dependabot` commands.

## Handoff

- CI fallout on a Dependabot PR → `pull-request` **fix-ci** (separate fix commits; never rewrite bot commits).
- Conflicts on a Dependabot PR → `pull-request` **conflicts**, or `@dependabot rebase` per pr-commands when no manual commits yet.
- Multi-repo discovery of stale Dependabot PRs → `pr-sweep` (read-only).

## Completion criteria

| Branch        | Done when                                                                               |
| ------------- | --------------------------------------------------------------------------------------- |
| **configure** | Valid `dependabot.yml` written or reviewed; ecosystems/directories match repo           |
| **triage**    | Risk assessed; CI fallout fixed or reported; approve-readiness stated; no approve/merge |
