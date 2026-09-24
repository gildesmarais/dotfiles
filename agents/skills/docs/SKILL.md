---
name: docs
description: >-
  Verify and rewrite existing docs against the repository, or author a
  control/auditor evidence pack. Use to refresh a README, contributor, operator,
  or feature doc; fix stale, inaccurate, or bloated docs; align ADRs, design
  notes, diagrams, and system overviews with runtime behavior; or prove a stated
  control from repo evidence.
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

1. Identify the target doc and the decisions/actions it must support; `AGENTS.md` rules override defaults here.
2. Read the doc if it exists, then build evidence from the repo before editing.
3. Classify existing targets by doc-class ([`../CONTEXT.md`](../CONTEXT.md)); `evidence` net-new packs skip this. Effort: `accurate` → tighten · `partial` → prune, fill verified gaps · `misleading` → rewrite main path from verified sources · `obsolete` → remove or recommend removal.

Rules for every branch:

- Evidence ladders are branch-local. When sources disagree, trust what runtime enforces and note the conflict in the handoff.
- Only verified, implemented behavior; no assumptions as facts. `editor` / `architecture`: remove non-essential unverified or stale content, report remaining gaps in the handoff (unless the doc is about a known limitation). `evidence`: publish Unverified and Not met in the document.
- No absolute filesystem paths in published docs — repo-relative or user-generic only.
- **Write forward**: teach the current system; constraints as present facts; no eras, migrations, or expected-failure paths. Detail: [`reference/editor.md`](reference/editor.md).

## Branch reference

Load exactly one and follow it through completion:

- **`editor`** → [`reference/editor.md`](reference/editor.md)
- **`architecture`** → [`reference/architecture.md`](reference/architecture.md)
- **`evidence`** → [`reference/evidence.md`](reference/evidence.md)

## Handoff

Report: target doc and its role · doc-class when classified · authoritative sources checked · what was removed or clarified · unresolved verification gaps — plus the branch's handoff additions.

Ask is a message, not documentation → stop → `communication`.

## Completion criteria

| Branch         | Done when                                                                                                                                         |
| -------------- | ------------------------------------------------------------------------------------------------------------------------------------------------- |
| `editor`       | Every technical claim re-checked against the repo; main path obvious; outdated content removed; next action explicit; prose forward-facing        |
| `architecture` | Flows, boundaries, and constraints verified as enforced; verification tier reached is stated; unknowns isolated instead of narrated               |
| `evidence`     | Control answer and verdict table stand alone; gaps explicit; verification tier stated; no invented live config; system under assessment unchanged |
