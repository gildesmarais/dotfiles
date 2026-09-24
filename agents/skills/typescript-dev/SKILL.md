---
name: typescript-dev
description: >-
  TypeScript/JavaScript deltas loaded by $dev (load $dev first; not a Build
  entry): named types over string/object soup, green ≠ correct, one runtime
  truth for closed sets.
---

# TypeScript Dev

**Stop:** read `$dev` Shared prep before any delta. Craft lives in `architecture`; compose sibling skills by name, never paste them. Framework overlays (e.g. React Native) stay in project skills / `AGENTS.md`.

## Also earn `design` when

Generated client or wire types leaking past the adapter / parse-unwrap outside the transport edge / plain cache or form bags used as live domain objects / sentinel identity conflated across layers / wire enum renamed in app code instead of normalized once / check-then-act uniqueness across awaits / freshness conflated with sync / capture edge doing domain construction / wrong-owner absorb of serialize/cache/encode / verified client unused beside hand transport / primary success rolled back by secondary hydrate.

## Docsets

Dash: **TypeScript** / **MDN** / **Node** as installed. Secondary: repo/`node_modules` types and package docs.

## Stable surfaces

Exported package/public module types and published API contracts — unless the ask or `AGENTS.md` says otherwise.

## Stance

- **Named types with judgment.** Closed sets, domain types, precise records over bare `string` / `object` / `any` / `Record<string, unknown>` at module boundaries and cross-seam decisions. Don't brand every id, add generics for one call site, or build type-level scaffolding where inference + a local alias suffice. Plain shapes at rest (cache/wire/forms) are intentional — rehydrate at the read seam.
- **Green compile ≠ correct change.** `as`, `!`, and checker-silencing suppressions are failed surgical work — parse, narrow, or restructure. Suppressions need an owned reason + removal condition; bare `@ts-ignore` banned.
- **One runtime truth for a closed set.** No parallel hand interfaces, schemas, and guards that can disagree; infer/generate one direction, map at the boundary.

## Surgical posture

- Mutually exclusive variants → discriminated unions, not optional-field soup.
- Won't narrow → restructure (`const`, predicate, discriminant), not `!` / `as`.
- `<T>` only when 2+ real call sites share structure.
- Errors are `unknown` until narrowed at the edge owning the closed error set.
- Export surface is a contract: no exports "for tests", no generated types in UI; `import type` on type-only edges.
- `satisfies` to check without widening. Tests may cast fixtures; production may not.
- Floating async needs an owner (await, cancel, or swallow with cause).
- Generated clients / OpenAPI output: regenerate, never hand-edit.
- Separate pinned **check** vs **tooling API** TypeScript versions are both contracts — don't break programmatic consumers when upgrading.
- Follow project law for `strict-type-checked` on app sources vs relaxed tests.
- Load [`reference.md`](reference.md) for boundary typing, dual compilers, schema ownership, Vitest/DOM testing.

## Compose routes

- React / Next performance → `vercel-react-best-practices` when installed.

## Non-goals

Type-level golf and default branded-type theater; inventing ESLint rules (cite `AGENTS.md`); framework list/scroll/UI recipes (overlays).

## Handoff deltas

Boundary typing judgment when string/object/`any` appeared at a seam: named type, intentional plain-at-rest, or explicit deferral.
