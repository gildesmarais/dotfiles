---
name: typescript-dev
description: >-
  TypeScript workflow for surgical fixes and design handoffs. Use when TypeScript
  or JavaScript work needs evidence-first investigation, repo-native validation,
  named types over string/object soup (without over-abstraction), and clear
  routing to architecture on design or to review.gil on assure/ship asks.
---

# TypeScript Dev

Language-runtime adapter for TypeScript. Craft (modules, types, measured perf) lives in `architecture` — do not inline it here.

## When to use

- Default for TypeScript/JavaScript packages, apps, CLIs, and adapters.
- Use for implementation work: surgical fixes, incidents, and small feature adjustments.
- Read `AGENTS.md` first when present. Compose sibling guideline or domain skills when they apply; never paste their contents into this workflow.
- Prefer `review.gil` **`tests`** when the user mainly wants test/spec review quality.
- Prefer `review.gil` **`finish`** when the user wants end-of-branch production-readiness review.
- Prefer `architecture` when design/structure/types/measured perf is the job (or when classification is `design`).
- Framework overlays (e.g. React Native) stay in project skills/`AGENTS.md` — compose them; do not invent framework recipes here.

## Classify

| Class             | Action                                                        |
| ----------------- | ------------------------------------------------------------- |
| `surgical`        | Stay here; smallest safe change; language validation          |
| `design`          | Load `architecture`; do not inline craft advice in this skill |
| `review-hand-off` | Route to `review.gil`                                         |

Earn `design` when any of: dual ownership / shallow modules / primitive obsession across boundaries / user asks for structural cleanup / measured perf work / type-driven refactor / generated client or wire types leaking past the adapter / parse-unwrap outside the transport edge / plain cache or form bags used as live domain objects / sentinel identity conflated across layers / wire enum renamed in app code instead of normalized once / check-then-act uniqueness across awaits / freshness conflated with sync / capture edge doing domain construction / wrong-owner absorb of serialize/cache/encode / verified client unused beside hand transport / primary success rolled back by secondary hydrate.

## Stance

- Evidence before claims. Prefer `rg`, file reads, and in-tree call sites over guesswork. When surveying, label findings Strong / Worth / Speculative.
- Prefer simple, forward, clean diffs. Default to surgical unless design is earned.
- **Named types with judgment.** Prefer closed sets, domain types, and precise records over bare `string`, `object`, `any`, or `Record<string, unknown>` at module boundaries and for decisions that cross seams. Do **not** brand every id, invent generics for one call site, or build type-level scaffolding where inference and a local named alias suffice. Plain serializable shapes at rest (cache/wire/forms) are intentional — rehydrate at the read seam rather than forcing class instances everywhere.
- **A green compile is not a correct change.** `as`, `!`, and suppressions that only silence the checker are failed surgical work — prefer parse, narrow, or restructure until the type is earned. Suppressions need an owned reason and a removal condition; bare `@ts-ignore` is banned.
- **One runtime truth for a closed set.** Do not maintain parallel hand interfaces, schemas, and ad-hoc guards that can disagree. Infer or generate one direction; map at the boundary when wire and domain must differ.
- API truth: prefer repo docs, Dash MCP when available, and local usage over invented library APIs. Say when unknown.

## Workflow

1. Classify: `surgical` | `design` | `review-hand-off`.
2. Evidence first: touched modules, public contracts, real call sites, existing tests, generated vs hand types, compat posture (ask if unclear).
3. Branch:
   - **Surgical:** smallest safe change → validate → handoff.
   - **Design:** load `architecture` (branch pick inside) → implement decisions here with TypeScript validation → handoff.
   - **Review-hand-off:** stop and continue with `review.gil`.
4. Handoff: commands run, residual risk, whether architecture harvest should run (stage → promote/drop per `architecture/reference/growth.md` — not a permanent learning-log store).

## Surgical path

- Change only what the bug or ask requires.
- Preserve behavior unless the ask is an intentional break and compat allows it.
- Add or tighten a focused test when the failure can be expressed cheaply.
- Keep the incident diff on **one surface**; drive-by edits on a second surface travel with the revert when the primary fix is wrong.
- **Optional-field soup is not a state machine.** Mutually exclusive variants belong in discriminated unions (or equivalent closed sets).
- **Narrow by restructuring, not by assertion.** When control flow will not narrow, rewrite for the checker (`const`, predicate, discriminant) — do not win with `!` / `as`.
- **Generics must earn the parameter.** Prefer named domain types; introduce `<T>` only when two+ real call sites share structure.
- **Errors are `unknown` until narrowed** at an edge that owns the closed error set.
- **Export surface is a contract.** Do not export “for tests” or leak generated types into UI; prefer `import type` on type-only edges.
- Prefer `satisfies` when checking a value against a type without widening.
- Tests may cast fixtures; production must not inherit that weakness.
- Floating async needs an owner — who awaits, cancels, or swallows with cause.
- Load thin postures in [`reference.md`](reference.md) when boundary typing, dual compilers, or schema ownership is in play.

## Validation Defaults

- Use repo-native entrypoints (`typecheck`, `lint`, `test`, Make/`mise` targets). Prefer a ready, documented target over inventing one-off commands.
- Start narrow (touched package/module/tests), then broaden when the change crosses seams.
- Never claim green without observing exit status 0 for the commands you cite.
- When the repo pins separate **check** and **tooling API** TypeScript versions, treat both as contracts — do not “upgrade TypeScript” by breaking programmatic consumers.
- Prefer project law for `strict-type-checked` on app sources vs relaxed tests when documented.
- For design phases: validate after each phase before starting the next.

## Contracts and Documentation

- Preserve existing repo conventions for contracts and docs.
- Do not invent a new global docs regime.
- If a touched public API already has docs or contract comments, keep them accurate in scope.
- Generated clients and OpenAPI output are read-only in the change — regenerate; never hand-edit.
- **Phase commits:** after each plan phase or surgical milestone, validate → ≥1 Conventional Commit with rationale/intent body before the next phase. Format: [`CONTEXT.md`](../CONTEXT.md). Inspect `git log` / `git show` when needed. `release` **`notes`** consumes history later — do not defer authoring to notes.

## Compose routes

Pointers only — load when present; do not paste their bodies here:

- Structure / types / measured perf → `architecture`.
- Assure / merge readiness → `review.gil`.
- Product scope → `product-owner`.
- Project RN/UI overlays and `AGENTS.md` when present.

## Explicit non-goals

- Type-level programming encyclopedias, utility-type golf, branded-type theater by default.
- Portable ESLint rule dumps or inventing local rules inside this skill — cite project `AGENTS.md`.
- Framework list/scroll/UI recipes (overlays).
- Inlining architecture craft checklists here.

## Handoff Checklist

Before handoff, confirm:

- Classification stated (`surgical` / `design` / `review-hand-off`).
- For `design`: which `architecture` branches were loaded.
- Commands run listed with scope and pass/fail (exit 0 only when claiming pass).
- Boundary typing judgment stated when string/object/`any` appeared at a seam (named type, intentional plain-at-rest, or explicit deferral).
- Compat decision stated, or that the user was asked.
- Residual risk, unverified paths, and intentional out-of-scope work called out.
