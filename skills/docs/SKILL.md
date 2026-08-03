---
name: docs
description: >
  Verify and rewrite existing documentation against the repository. Use when
  refreshing a README, contributor, operator, or feature doc, when reducing
  documentation bloat or fixing stale and inaccurate docs, or when aligning
  architecture docs, ADRs, design notes, diagrams, and system overviews with
  actual runtime behavior, boundaries, constraints, and failure modes.
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

Routing signals:

| User says                                                                 | Branch                                            |
| ------------------------------------------------------------------------- | ------------------------------------------------- |
| "refresh the README", "these docs are stale", "trim this doc"             | `editor`                                          |
| "clarity of usage", "a new reader can't follow this"                      | `editor`                                          |
| "is this ADR still true", "document the real data flow", "update diagram" | `architecture`                                    |
| "verify the architecture before we change it"                             | `architecture`                                    |
| "is this branch ready to ship"                                            | stop — use the `review` skill **`finish`** branch |

Use `architecture` when a task requires verifying real architecture before a decision or change, even if the user did not ask for a document rewrite.

## Shared prep

Every branch:

1. Identify the target document and the decisions or actions it must support.
2. Read `AGENTS.md` if present and follow repo-specific rules over defaults here.
3. Read the document, then build evidence from the repo before editing.
4. Classify the document, then match effort to the classification:
   - `accurate`: tighten and clarify
   - `partial`: prune, then fill verified gaps
   - `misleading`: rewrite the main path from verified sources
   - `obsolete`: remove or recommend removal

Evidence rules that apply to both branches:

- Prefer the source closest to runtime behavior; each branch reference defines its own evidence ladder.
- When sources disagree, trust what is enforced at runtime and note the conflict in the handoff.
- Do not describe behavior that is not implemented or enforced.
- Remove stale, speculative, historical, or duplicate content unless it still changes a reader decision.
- Prefer removal over preserving uncertain content.
- Do not write absolute filesystem paths in published docs; prefer repo-relative or user-generic paths so docs do not reveal local identity details.
- Keep terminology consistent with the system, and keep project-specific terms only when current and correct.

Uncertainty handling, both branches:

- Do not present assumptions as facts.
- Remove unverified claims when they are not essential; isolate the gap during drafting rather than turning it into confident prose.
- Report unresolved gaps in the handoff, not in the published document, unless the document is explicitly about a known limitation.

## Branch reference

Load exactly one disclosed reference file and follow it through completion:

- **`editor`** → [`reference/editor.md`](reference/editor.md)
- **`architecture`** → [`reference/architecture.md`](reference/architecture.md)

## Handoff

Report for every branch:

- the target document and its role
- the triage classification
- the authoritative sources checked
- what was removed or clarified
- unresolved verification gaps

Each branch reference adds its own required handoff items.

When the ask turns out to be a message rather than documentation, stop and continue with the `communication` skill.

## Completion criteria

| Branch         | Done when                                                                                                                           |
| -------------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| `editor`       | Every technical claim re-checked against the repo; main path obvious; outdated content removed; next action explicit                |
| `architecture` | Flows, boundaries, and constraints verified as enforced; verification tier reached is stated; unknowns isolated instead of narrated |
