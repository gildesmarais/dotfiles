# Docs — `editor`

Rewrite documentation for action, not explanation. Write so a new reader can act without guessing.

Use for:

- improving or refreshing existing documentation (README, contributor, operator, feature docs)
- documentation that is bloated, stale, unclear, contradictory, or partially incorrect
- reducing duplication and removing unverifiable content

Recommend a new document only when the repo is missing a standard, high-value document and the user asked for documentation work.

Do not:

- preserve prose for completeness
- invent behavior not proven by the repository

## Evidence ladder

Use the closest current source for each claim:

1. code and tests
2. configuration and scripts
3. generated artifacts
4. adjacent documentation

## Core rules

- Inspect relevant code and support files before editing docs.
- Verify commands, paths, flags, config keys, defaults, and outputs against the repo.
- Describe selection logic, fallback behavior, and precedence exactly as implemented.
- Keep every section useful for action or decision-making.
- Keep sections scannable. Use bullets and short paragraphs when they reduce reading effort.
- Make implicit assumptions explicit when they affect execution (cwd, environment, inputs).
- **Write forward.** Document the current system: what it is, when to use it, how to run it, what success looks like. State present constraints as facts. Do not teach via retired workflows, migration narratives, publication history, or “expected failure” paths. Prefer positive instructions over stacks of “do not / never / avoid” that assume prior knowledge. Keep a past name only when it still changes a present decision (e.g. compact alias → current skill lookup); otherwise remove.

## Workflow

1. Define the document's job.
   - What should the reader be able to do after reading it?
   - Who is the likely reader?
2. Build context from the repo.
   - Read the code, tests, scripts, config, and entrypoints that define its current behavior.
   - Check neighboring docs only to avoid contradiction or duplication.
3. Cut to the real scope.
   - Keep only content that helps the reader act or decide.
   - Remove history, speculation, duplicate explanation, deprecated flows, and unverifiable claims.
4. Rewrite for action.
   - Write forward: present system first; constraints as facts; no era/migration/expected-failure teaching.
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

## Recommended structure

Use this order when it fits the document, and cut sections that do not serve its job:

1. what this is
2. when or why to use it
3. prerequisites
4. quick start or exact procedure
5. expected result
6. next step or deeper reference

## What to keep

- current behavior
- exact prerequisites
- concrete examples
- explicit execution context when behavior depends on cwd, env vars, or invocation mode
- expected outcomes
- next actions
- caveats that materially change usage or decisions (as present constraints, not failure stories)
- alias → current name lookups only when they help route a prompt today

## What to remove or compress

- history and origin stories
- era / migration / “how we used to …” framing
- “expected failure” or “will fail — that is expected” as teaching devices
- vague motivation
- duplicated explanations
- deprecated or dead flows (unless a one-line present prune/cleanup fact remains)
- speculative future plans
- unverifiable claims
- content that does not change reader action or decisions
- negation stacks that only make sense if the reader already knows the past system

## Pattern guidance

### README

Optimize for first success in minutes. Usually include:

- what this repo or component is
- when to use it
- prerequisites
- copy-paste startup or usage steps
- expected result
- where to go next

### Change or feature docs

Anchor the writeup in the implementation. Usually include:

- what changed
- who it affects
- how to use or enable it
- actual selection, fallback, or precedence behavior
- constraints, migration notes, or rollout impact
- links to the current source of truth

### Contributor or operator docs

Optimize for repeatability. Usually include:

- required setup
- exact commands
- verification points
- important failure modes
- deeper troubleshooting references

For runbooks and troubleshooting docs, keep rollback notes, decision-critical edge cases, and failure handling even when that reduces brevity.

## Boundaries

- Do not document behavior you cannot verify.
- Do not create net-new documentation by default.
- Do not expand scope because related information exists nearby.
- Do not rewrite away nuance that affects correctness.
- Do not duplicate explanations across documents without a reason.

If the repo is missing a high-value document, call that out explicitly and explain why it should exist.

## Before finishing

Confirm:

- documentation matches current repo state
- the main path is obvious
- outdated content is removed
- the next action is explicit
- prose is forward-facing (no era/migration/expected-failure teaching; constraints stated as present facts)
