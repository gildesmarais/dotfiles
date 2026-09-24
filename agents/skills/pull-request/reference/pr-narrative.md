# PR narrative

Title/body standard for **open** and **retitle**. Concrete paths, behaviors, contracts, failure modes. Banned filler: "enhances", "streamlines", "robust", "comprehensive", "leverages", and kin.

## Title

What + why, scannable; `type(scope): summary` when the repo uses it; branch ticket (`/[A-Z][A-Z0-9]+-\d+/`) → `type(scope): [ABC-123] summary`. Match the full `base...HEAD` diff, not branch-name wording.

## Body

```markdown
## What changed

- <concrete bullet: path/behavior/contract>

## Why

<problem, constraint, or intent; bug fixes: root cause here (or ### Root cause)>

## Risk

- <failure modes, rollout, compat, or "low — …">

## Review map

<see size gates>

## Validation

- <commands already run, or "not run: …">
```

Fast-scan bullets first, detail below. Keep What changed / Why / Risk / Validation; add `## Ticket` when known.

## Review map — size gates

**Large** = >400 lines changed (`git diff --stat` insertions + deletions vs base) **or** >15 files → Review map required, ordered "start here" list:

```markdown
## Review map

1. `path/to/test_or_spec` — <behavior it pins>
2. `path/to/core` — <why next>
```

**Small** → omit or one-liner: `Review map: whole PR is small — start at <path>.`

Ordering (tests-first): from `git diff --stat <base>...HEAD`, cluster by package/domain; list changed tests/specs first (they state the behavior), then highest-churn files in the primary cluster, then public contracts (CLI help, APIs). No changed tests → say `No test delta — start at <path>.` Skip pure renames/noise unless they are the story.
