---
name: docs
description: >-
  Verify/rewrite docs against the repo, or author a control evidence pack. Use
  for README, contributor, operator, or feature docs; stale ADRs/diagrams; or
  prove a stated control from repo evidence.
---

# Docs

Rewrite docs to match what the repo actually does. Treat existing prose as unverified; improve an existing doc over creating a new one.

## Pick branch

| Branch         | Use when                                                                                     | Signals                                                                                              |
| -------------- | -------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------- |
| `editor`       | Public-facing or operational docs — README, contributor, operator, feature docs, runbooks    | "refresh the README", "docs are stale", "trim this doc", "a new reader can't follow this"            |
| `architecture` | Architecture-facing docs — ADRs, design notes, diagrams, system overviews, integration flows | "is this ADR still true", "document the real data flow", "update diagram", "verify the architecture" |
| `evidence`     | Prove a stated control from the repo (auditor pack; Assessment / Evidence / Scope / Task)    | "auditor evidence", "provide the evidence", "control assessment"                                     |

- Use `architecture` whenever real architecture must be verified before a decision or change, even without a rewrite ask. It is **verify/rewrite only** — no net-new HLD/ADR.
- "Is this branch ready to ship" → stop → `review.gil`.

## Shared prep

1. Identify the target doc and decisions it must support; `AGENTS.md` overrides defaults.
2. Classify by doc-class (`accurate` | `partial` | `misleading` | `obsolete`; `editor` starts at code/tests, `architecture` at live runtime); effort verbs live in the matched branch. `evidence` net-new packs skip classification.

Every branch: ladders are branch-local; only verified behavior; no absolute filesystem paths; **Write forward** once in [`reference/editor.md`](reference/editor.md).

## Branch reference

Load exactly one:

- **`editor`** → [`reference/editor.md`](reference/editor.md)
- **`architecture`** → [`reference/architecture.md`](reference/architecture.md)
- **`evidence`** → [`reference/evidence.md`](reference/evidence.md)

## Handoff

Report: target + role · doc-class · sources checked · removed/clarified · gaps — plus branch handoff additions. Message ask → `communication`.

## Completion criteria

Per-branch Done when in the matched reference.
