---
name: docs
description: >
  Verify and rewrite existing documentation against the repository, or author a
  control/auditor evidence pack. Use when refreshing a README, contributor,
  operator, or feature doc, when reducing documentation bloat or fixing stale
  and inaccurate docs, when aligning architecture docs, ADRs, design notes,
  diagrams, and system overviews with actual runtime behavior, or when proving
  a stated control from repo evidence.
---

# Docs

Rewrite documentation to match what the repository actually does, not what it was intended to do.

Assume existing prose may be outdated until verified. Prefer improving an existing document over creating a new one.

## Pick branch

Map the user prompt to exactly one branch:

| Branch         | Use when                                                                                     |
| -------------- | -------------------------------------------------------------------------------------------- |
| `editor`       | Public-facing or operational docs — README, contributor, operator, feature docs, runbooks    |
| `architecture` | Architecture-facing docs — ADRs, design notes, diagrams, system overviews, integration flows |
| `evidence`     | Prove a stated control from the repo (auditor pack; Assessment / Evidence / Scope / Task)    |

Routing signals:

| User says                                                                 | Branch                            |
| ------------------------------------------------------------------------- | --------------------------------- |
| "refresh the README", "these docs are stale", "trim this doc"             | `editor`                          |
| "clarity of usage", "a new reader can't follow this"                      | `editor`                          |
| "is this ADR still true", "document the real data flow", "update diagram" | `architecture`                    |
| "verify the architecture before we change it"                             | `architecture`                    |
| "auditor evidence", "provide the evidence", "control assessment"          | `evidence`                        |
| "is this branch ready to ship"                                            | stop — use the `review.gil` skill |

Use `architecture` when a task requires verifying real architecture before a decision or change, even if the user did not ask for a document rewrite. This branch is Solution-adjacent **verify/rewrite only** — it does not author net-new HLD/ADR (author path deferred).

## Shared prep

Every branch:

1. Identify the target document and the decisions or actions it must support.
2. Read `AGENTS.md` if present and follow repo-specific rules over defaults here.
3. Read the document if it exists, then build evidence from the repo before editing.
4. Classify only when a target already exists (`evidence` net-new packs skip this), then match effort:
   - `accurate`: tighten and clarify
   - `partial`: prune, then fill verified gaps
   - `misleading`: rewrite the main path from verified sources
   - `obsolete`: remove or recommend removal

Evidence rules that apply to every branch:

- Prefer the source closest to runtime behavior; each branch reference defines its own evidence ladder.
- When sources disagree, trust what is enforced at runtime and note the conflict in the handoff.
- Do not describe behavior that is not implemented or enforced.
- Remove stale, speculative, historical, or duplicate content unless it still changes a reader decision.
- Prefer removal over preserving uncertain content.
- Do not write absolute filesystem paths in published docs; prefer repo-relative or user-generic paths so docs do not reveal local identity details.
- Keep terminology consistent with the system, and keep project-specific terms only when current and correct.
- **Write forward** — teach the current system (what / when / how / success). State constraints as present facts; do not teach via eras, migrations, or expected-failure paths. Detail: `editor` [`reference/editor.md`](reference/editor.md).

Uncertainty handling:

- Do not present assumptions as facts.
- On `editor` / `architecture`: remove unverified claims when they are not essential; report remaining gaps in the handoff unless the document is about a known limitation.
- On `evidence`: publish Unverified and Not met in the document.

## Branch reference

Load exactly one disclosed reference file and follow it through completion:

- **`editor`** → [`reference/editor.md`](reference/editor.md)
- **`architecture`** → [`reference/architecture.md`](reference/architecture.md)
- **`evidence`** → [`reference/evidence.md`](reference/evidence.md)

## Handoff

Report for every branch:

- the target document and its role
- the doc-class (four-way classification) when classified
- the authoritative sources checked
- what was removed or clarified
- unresolved verification gaps

Each branch reference adds its own required handoff items.

When the ask turns out to be a message rather than documentation, stop and continue with the `communication` skill.

## Completion criteria

| Branch         | Done when                                                                                                                                         |
| -------------- | ------------------------------------------------------------------------------------------------------------------------------------------------- |
| `editor`       | Every technical claim re-checked against the repo; main path obvious; outdated content removed; next action explicit; prose forward-facing        |
| `architecture` | Flows, boundaries, and constraints verified as enforced; verification tier reached is stated; unknowns isolated instead of narrated               |
| `evidence`     | Control answer and verdict table stand alone; gaps explicit; verification tier stated; no invented live config; system under assessment unchanged |
