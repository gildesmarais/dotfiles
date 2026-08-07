---
name: typescript-dev
description: >-
  Always load $dev first; this pack is deltas only. Language-runtime adapter
  loaded by $dev — not the Build entry. Use when $dev routed here or the user
  names this skill with $dev already loaded. TypeScript deltas: named types over
  string/object soup, green≠correct, one runtime truth.
---

# TypeScript Dev

**Stop:** read `$dev` Shared prep before any delta.

Follow `$dev` for classify, shared stance, API truth / Dash recipe, compat ask, no-destructive git, workflow/plan, validation law, phase commits, and handoff skeleton. This pack adds TypeScript deltas only. Craft (modules, types, measured perf) lives in `architecture` — do not inline it here.

## When to use

- Loaded by `$dev` for TypeScript/JavaScript packages, apps, CLIs, and adapters.
- Explicit `@typescript-dev` / `$typescript-dev` compose when `$dev` is already loaded.
- Compose sibling guideline or domain skills when they apply; never paste their contents into this workflow.
- Framework overlays (e.g. React Native) stay in project skills/`AGENTS.md` — compose them; do not invent framework recipes here.

## Also earn `design` when

Generated client or wire types leaking past the adapter / parse-unwrap outside the transport edge / plain cache or form bags used as live domain objects / sentinel identity conflated across layers / wire enum renamed in app code instead of normalized once / check-then-act uniqueness across awaits / freshness conflated with sync / capture edge doing domain construction / wrong-owner absorb of serialize/cache/encode / verified client unused beside hand transport / primary success rolled back by secondary hydrate.

## Docsets

- Prefer Dash docsets: **TypeScript** / **MDN** / **Node** as installed. Secondary: repo/`node_modules` types and package docs.

## Stable-surface hints

- Treat exported package/public module types and published API contracts as stable unless the ask or `AGENTS.md` says otherwise.

## Stance deltas

- **Named types with judgment.** Prefer closed sets, domain types, and precise records over bare `string`, `object`, `any`, or `Record<string, unknown>` at module boundaries and for decisions that cross seams. Do **not** brand every id, invent generics for one call site, or build type-level scaffolding where inference and a local named alias suffice. Plain serializable shapes at rest (cache/wire/forms) are intentional — rehydrate at the read seam rather than forcing class instances everywhere.
- **A green compile is not a correct change.** `as`, `!`, and suppressions that only silence the checker are failed surgical work — prefer parse, narrow, or restructure until the type is earned. Suppressions need an owned reason and a removal condition; bare `@ts-ignore` is banned.
- **One runtime truth for a closed set.** Do not maintain parallel hand interfaces, schemas, and ad-hoc guards that can disagree. Infer or generate one direction; map at the boundary when wire and domain must differ.
- Evidence: touched modules, public contracts, real call sites, existing tests, generated vs hand types, compat posture (ask via `$dev` if unclear).

## Surgical posture

- **Optional-field soup is not a state machine.** Mutually exclusive variants belong in discriminated unions (or equivalent closed sets).
- **Narrow by restructuring, not by assertion.** When control flow will not narrow, rewrite for the checker (`const`, predicate, discriminant) — do not win with `!` / `as`.
- **Generics must earn the parameter.** Prefer named domain types; introduce `<T>` only when two+ real call sites share structure.
- **Errors are `unknown` until narrowed** at an edge that owns the closed error set.
- **Export surface is a contract.** Do not export “for tests” or leak generated types into UI; prefer `import type` on type-only edges.
- Prefer `satisfies` when checking a value against a type without widening.
- Tests may cast fixtures; production must not inherit that weakness.
- Floating async needs an owner — who awaits, cancels, or swallows with cause.
- Load thin postures in [`reference.md`](reference.md) when boundary typing, dual compilers, or schema ownership is in play.

## Tooling

- Use repo-native entrypoints (`typecheck`, `lint`, `test`, Make/`mise` targets). Prefer a ready, documented target over inventing one-off commands.
- Start narrow (touched package/module/tests), then broaden when the change crosses seams.
- When the repo pins separate **check** and **tooling API** TypeScript versions, treat both as contracts — do not “upgrade TypeScript” by breaking programmatic consumers.
- Prefer project law for `strict-type-checked` on app sources vs relaxed tests when documented.

## Contracts

- Preserve existing repo conventions for contracts and docs.
- Do not invent a new global docs regime.
- If a touched public API already has docs or contract comments, keep them accurate in scope.
- Generated clients and OpenAPI output are read-only in the change — regenerate; never hand-edit.

## Compose routes

Pointers only — load when present; do not paste their bodies here:

- React / Next performance depth → `vercel-react-best-practices` when installed.
- Project RN/UI overlays and `AGENTS.md` when present.

## Explicit non-goals

- Type-level programming encyclopedias, utility-type golf, branded-type theater by default.
- Portable ESLint rule dumps or inventing local rules inside this skill — cite project `AGENTS.md`.
- Framework list/scroll/UI recipes (overlays).
- Inlining architecture craft checklists here.

## Handoff deltas

Before handoff (on top of `$dev` skeleton), confirm:

- Boundary typing judgment stated when string/object/`any` appeared at a seam (named type, intentional plain-at-rest, or explicit deferral).
- Residual risk, unverified paths, and intentional out-of-scope work called out.
