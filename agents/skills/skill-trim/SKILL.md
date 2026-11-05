---
name: skill-trim
description: >-
  Prune a project-local skill store to the smallest text that changes a model's
  decision. Use to trim, prune, compress, or DRY project skills, or fight
  context bloat in .agents/skills and AGENTS.md.
disable-model-invocation: true
---

# Skill trim

Every kept line must change a model's decision. Vocabulary: [`../CONTEXT.md`](../CONTEXT.md).

## Pick branch

- project skills, `AGENTS.md`, or `CONTEXT.md` bloat (default): `project`
- global store (`~/.agents/skills`) or authoring a new rule → stop → `harvest`

## Shared prep

1. Record the baseline: `git rev-parse HEAD`.
2. Measure: `skill --project . lint --measure`.

## Branch reference

- **`project`** — keep-test, surfaces, dedupe, done check: [`reference/project.md`](reference/project.md).

## Handoff

Commit or PR only on explicit ask → `pull-request` `open`.

## Completion criteria

`reference/project.md` **Done** holds; baseline ref and before/after word counts reported.
