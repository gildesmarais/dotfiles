# PR narrative

Shared title and body standards for **open** and **retitle**. Write for humans who understand code and engineering principles.

## Voice

- Concrete paths, behaviors, contracts, and failure modes.
- No abstract AI speech. Ban filler: “enhances”, “streamlines”, “robust”, “comprehensive”, “leverages”, and similar.

## Title

- Scannable; what + why for reviewers (not only what).
- Prefer conventional `type(scope): summary` when the repo uses that.
- When the branch encodes a ticket (`/[A-Z][A-Z0-9]+-\d+/`), put it in the title (e.g. `type(scope): [ABC-123] summary`).
- Align with the full `base...HEAD` diff, not branch-name typos or temporary wording.

## Body shape (always)

1. **Fast-scan bullets first** — What changed
2. **Then precise info below** — Why / Risk / detail

### Template

```markdown
## What changed

- <concrete bullet: path/behavior/contract>
- <…>

## Why

<short paragraph or bullets: problem, constraint, or intent>

## Risk

- <failure modes, rollout, compat, or “low — …”>

## Review map

<required when large; see size gates below>

## Validation

- <commands already run, or “not run: …”>
```

Omit empty sections only when they truly have nothing useful (e.g. no ticket field). Keep What changed / Why / Risk / Validation whenever possible. Add `## Ticket` with the key when a ticket is known.

For bug fixes, put root cause under **Why** (or a `### Root cause` under Why) and the fix behavior under **What changed**.

## Review map — size gates

Treat the PR as **large** when either:

- **>400 lines changed** (`git diff --stat` insertions + deletions vs base), **or**
- **>15 files** changed vs base

**Large PRs — Review map required.** List ordered “start here” paths and what to look for:

```markdown
## Review map

1. `path/to/highest-churn-or-core` — <why first>
2. `path/to/next` — <contract / edge cases>
3. …
```

**Small PRs** may omit the section or use a one-liner:

```markdown
## Review map

Review map: whole PR is small — start at `<path>`.
```

### Deriving “Start here” from diffstat

1. Run `git diff --stat <base>...HEAD` (and `--name-only` if needed).
2. Cluster files by command / package / top-level domain (e.g. `commands/github/`, `lib/`, `test/`).
3. Prefer highest-churn files in the primary domain cluster first; then public contracts (CLI help, APIs); then tests.
4. Skip pure renames/noise unless they are the story.
