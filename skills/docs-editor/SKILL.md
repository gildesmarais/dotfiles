---
name: docs-editor
description: Rewrite, tighten, and verify existing public-facing documentation against the current codebase and supporting files in high-churn, low-trust environments. Use primarily to improve existing docs, reduce documentation bloat, refresh README or contributor docs, or fix inaccurate, stale, unclear, or obsolete documentation. Inspect the repository first, prefer verified public-facing clarity, and avoid inventing behavior that is not present in code or supporting artifacts.
---

# Docs Editor

Rewrite documentation for action, not explanation.

Write so a new reader can act without guessing.

Use the repository as the source of truth. Verify all claims against code, tests, configuration, scripts, generated artifacts, or executable entrypoints.

Prefer improving an existing document. Recommend a new document only when the repo is missing a standard, high-value document and the user asked for documentation work.

## When To Use

- Improve or refresh existing documentation (README, contributor, operator, feature docs).
- Fix documentation that is bloated, stale, unclear, contradictory, or partially incorrect.
- Reduce duplication and remove unverifiable content.

Do not:

- preserve prose for completeness
- invent behavior not proven by the repository

## Core Rules

- Inspect relevant code and support files before editing docs.
- Verify commands, paths, flags, config keys, defaults, and outputs against the repo.
- Do not write absolute filesystem paths in published docs; prefer repo-relative paths or user-generic paths so documentation does not reveal local identity details.
- Prefer sources closest to runtime behavior (code, tests) over indirect sources (scripts, config, prose).
- Describe selection logic, fallback behavior, and precedence exactly as implemented.
- Remove stale, speculative, historical, or duplicate content unless it still changes a reader decision.
- Prefer removal over preserving uncertain content.
- Keep every section useful for action or decision-making.
- Keep sections scannable. Use bullets and short paragraphs when they reduce reading effort.
- Make implicit assumptions explicit when they affect execution (cwd, environment, inputs).
- Preserve project-specific terminology only when it is current and correct.
- Keep unresolved uncertainty out of published docs; report it in the handoff instead.

## Verification Order

Use the closest current source for each claim:

1. code and tests
2. configuration and scripts
3. generated artifacts
4. adjacent documentation

When sources disagree, trust the source closest to runtime behavior and note the conflict in the handoff.

## Triage

Classify the target document before rewriting:

- `accurate`: tighten and compress
- `partially accurate`: prune and rewrite from verified sources
- `unreliable`: rebuild the main path from verified sources
- `obsolete`: remove or recommend removal

Use effort proportional to that classification.

## Workflow

1. Define the document's job.
   - What should the reader be able to do after reading it?
   - Who is the likely reader?
2. Build context from the repo.
   - Read the document.
   - Read the code, tests, scripts, config, and entrypoints that define its current behavior.
   - Check neighboring docs only to avoid contradiction or duplication.
3. Cut to the real scope.
   - Keep only content that helps the reader act or decide.
   - Remove history, speculation, duplicate explanation, deprecated flows, and unverifiable claims.
4. Rewrite for action.
   - Use short sections, explicit labels, and examples that match the repo.
   - Make working directory, path, and environment assumptions explicit when they matter.
   - When an example needs multiple shell steps, format chained commands for human scanning: use `&&`, `;`, and line continuations `\` deliberately, and align the trailing `\` into a readable vertical rail.
   - Keep examples self-contained, or state their dependencies directly.
5. Validate the rewritten document.
   - Re-check every technical claim against the repo.
   - Confirm commands are runnable or at least repo-consistent.
   - Confirm links and file references still exist.
   - Confirm examples are mutually consistent.
   - Confirm defaults, guarantees, uniqueness, and precedence claims are actually enforced.

## Recommended Structure

Use this order when it fits the document:

1. what this is
2. when or why to use it
3. prerequisites
4. quick start or exact procedure
5. expected result
6. next step or deeper reference

Cut sections that do not serve the document's job.

## What To Keep

- current behavior
- exact prerequisites
- concrete examples
- explicit execution context when behavior depends on cwd, env vars, or invocation mode
- expected outcomes
- next actions
- caveats that materially change usage or decisions

## What To Remove Or Compress

- history and origin stories
- vague motivation
- duplicated explanations
- deprecated or dead flows
- speculative future plans
- unverifiable claims
- content that does not change reader action or decisions

## Pattern Guidance

### README

Optimize for first success in minutes.

Usually include:

- what this repo or component is
- when to use it
- prerequisites
- copy-paste startup or usage steps
- expected result
- where to go next

### Change Or Feature Docs

Anchor the writeup in the implementation.

Usually include:

- what changed
- who it affects
- how to use or enable it
- actual selection, fallback, or precedence behavior
- constraints, migration notes, or rollout impact
- links to the current source of truth

### Contributor Or Operator Docs

Optimize for repeatability.

Usually include:

- required setup
- exact commands
- verification points
- important failure modes
- deeper troubleshooting references

For runbooks and troubleshooting docs, keep rollback notes, decision-critical edge cases, and failure handling even when that reduces brevity.

## Uncertainty Handling

If verification is incomplete:

- remove unverified claims when they are not essential
- isolate the gap during drafting rather than turning it into confident prose
- do not present assumptions as facts
- report the unresolved gap in the final handoff, not in the published document, unless the document itself is explicitly about a known limitation

## Boundaries

- Do not document behavior you cannot verify.
- Do not create net-new documentation by default.
- Do not expand scope because related information exists nearby.
- Do not rewrite away nuance that affects correctness.
- Do not duplicate explanations across documents without a reason.

If the repo is missing a high-value document, call that out explicitly and explain why it should exist.

## Handoff

Report:

- the target document and its role
- the triage result
- what authoritative sources were checked
- what was removed or clarified
- any unresolved verification gaps

Before finishing, confirm:

- documentation matches current repo state
- the main path is obvious
- outdated content is removed
- the next action is explicit
