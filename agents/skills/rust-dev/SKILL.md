---
name: rust-dev
description: >-
  Rust workflow for surgical fixes and design handoffs. Use when Rust work needs
  evidence-first investigation, repo-native validation, and clear routing to
  architecture on design or to review on assure/ship asks.
---

# Rust Dev

Language-runtime adapter for Rust. Craft (modules, types, measured perf) lives in `architecture` — do not inline it here.

## When to use

- Use for Rust implementation work: surgical fixes and small feature adjustments.
- Read `AGENTS.md` first when present. Compose sibling guideline or domain skills when they apply; never paste their contents into this workflow.
- Prefer `review` **`tests`** when the user mainly wants test/spec review quality.
- Prefer `review` **`finish`** when the user wants end-of-branch production-readiness review.
- Prefer `architecture` when design/structure/types/measured perf is the job (or when classification is `design`).

## Classify

| Class             | Action                                                        |
| ----------------- | ------------------------------------------------------------- |
| `surgical`        | Stay here; smallest safe change; language validation          |
| `design`          | Load `architecture`; do not inline craft advice in this skill |
| `review-hand-off` | Route to `review`                                             |

Earn `design` when any of: dual ownership / shallow modules / primitive obsession across boundaries / user asks for structural cleanup / measured perf work / type-driven refactor.

## Stance

- Evidence before claims. Prefer `rg`, file reads, and in-tree call sites over guesswork. When surveying, label findings Strong / Worth / Speculative.
- API truth: prefer Dash docs, `cargo doc`, and local usage. Say when unknown; do not invent crate APIs.
- Compatibility is context-gated. Detect whether the change surface is internal-only or a stable public contract. If unsure whether a break is allowed, **ask** before shipping. No silent shim theater; no silent breaks on surfaces treated as stable.
- Prefer simple, forward, clean diffs. Default to surgical unless design is earned.

## Workflow

1. Classify: `surgical` | `design` | `review-hand-off`.
2. Evidence first: touched modules, public contracts, real call sites, existing tests, compat posture (ask if unclear).
3. Branch:
   - **Surgical:** smallest safe change → validate → handoff.
   - **Design:** load `architecture` (branch pick inside) → implement decisions here with Rust validation → handoff.
   - **Review-hand-off:** stop and continue with `review`.
4. Handoff: commands run, residual risk, whether `architecture` learning-log should grow (harvest there, not here).

## Surgical path

- Change only what the bug or ask requires.
- Preserve behavior unless the ask is an intentional break and compat allows it.
- Add or tighten a focused test when the failure can be expressed cheaply.
- Validate with the narrowest repo-native command that covers the change.

## Validation Defaults

- Use repo-native entrypoints (`cargo test`, `cargo clippy`, project wrappers, `mise exec --`, Make targets). Prefer a ready, documented target over inventing one-off commands.
- Start narrow (touched crate/module/tests), then broaden when the change crosses seams.
- Never claim green without observing exit status 0 for the commands you cite.
- For design phases: validate after each phase before starting the next.

## Contracts and Documentation

- Preserve existing repo conventions for contracts and docs.
- Do not invent a new global docs regime.
- If a touched public API already has docs or contract comments, keep them accurate in scope.
- **Phase commits:** after each plan phase or surgical milestone, validate → ≥1 Conventional Commit with rationale/intent body before the next phase. Format: [`CONTEXT.md`](../CONTEXT.md). Inspect `git log` / `git show` when needed. `release` **`notes`** consumes history later — do not defer authoring to notes.

## Handoff Checklist

Before handoff, confirm:

- Classification stated (`surgical` / `design` / `review-hand-off`).
- For `design`: which `architecture` branches were loaded.
- Commands run listed with scope and pass/fail (exit 0 only when claiming pass).
- Compat decision stated, or that the user was asked.
- Residual risk, unverified paths, and intentional out-of-scope work called out.
