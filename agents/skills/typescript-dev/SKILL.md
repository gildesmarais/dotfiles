---
name: typescript-dev
description: >-
  TypeScript/JavaScript deltas: named types over string/object soup, green ≠
  correct, one runtime truth for closed sets.
disable-model-invocation: true
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

- **Named types with judgment.** Closed sets, domain types, precise records over bare `string` / `object` / `any` / `Record<string, unknown>` at module boundaries. Don't brand every id or add generics for one call site. Plain shapes at rest (cache/wire/forms) are intentional — rehydrate at the read seam.
- **Green compile ≠ correct change.** `as`, `!`, and checker-silencing suppressions are failed surgical work — parse, narrow, or restructure. Suppressions need an owned reason + removal condition; bare `@ts-ignore` banned.
- **One runtime truth for a closed set.** No parallel hand interfaces, schemas, and guards that can disagree; infer/generate one direction, map at the boundary.

## Surgical posture

Load [`reference.md`](reference.md) for boundary typing, dual compilers, schema ownership, Vitest/DOM testing, and surgical recipes (unions, narrowing, exports, async ownership).

## Compose routes

- React / Next performance → `vercel-react-best-practices` when installed.

## Non-goals

Type-level golf and default branded-type theater; inventing ESLint rules (cite `AGENTS.md`); framework list/scroll/UI recipes (overlays).

## Handoff deltas

Boundary typing judgment when string/object/`any` appeared at a seam: named type, intentional plain-at-rest, or explicit deferral.
