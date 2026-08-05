# Code branch rubric

Enrich the five-field brief for implementation, refactor, bugfix, or test work. Do not invent a parallel template.

## Fold into Context

- Seams and files in scope (paths or search pointers when not yet opened).
- Current broken or target behavior in one or two sentences.
- Relevant repo invariants already grounded (style gates, tenancy, auth) — as facts, not lectures.

## Fold into Constraints

- Out-of-scope paths, layers, or “do not touch” surfaces.
- Regression risks called out by the user or proven in code (call sites, shared helpers).
- Exclusions: drive-by refactors, unrelated cleanups, invented APIs.

Omit Constraints if none of the above exist.

## Fold into Verify

- Repo-native proof: named test files, `make`/`mise`/CI commands, or lint targets when known from the workspace.
- If commands are unknown: pointer to discover them (e.g. “read package scripts / CI workflow for the check that covers X”) — do not invent command strings.
- Success remains the observable outcome; Verify remains the checklist that proves it.
