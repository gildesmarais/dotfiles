# typescript-dev reference

Language-only postures. Architecture craft lives on `architecture` branch refs — never duplicate it here as a parallel doctrine log.

Grow this file only for TypeScript-specific lessons that cannot be stated language-free. Cap ~10 new bullets per harvest unless the user asks for more. Routine surgical fixes do not grow this file.

## Boundary typing

1. **Cache shape ≠ domain shape.** Durable bags hold plain/serializable records; rehydrate domain types in `select` or model. UI props accept domain types, not generated wire types.
2. **Fallible at untrusted edges.** Prefer `try*` / quarantine in render and display paths; throwing constructors only after trusted parse.
3. **Sentinel maps over branding.** One leaf of explicit layer mappers beats nominal brands for multi-layer identity. Test illegal inhabitants never cross the wire.
4. **Generated owns wire; hand owns domain.** Do not force class instances through generated schemas; do not re-unwrap in services.
5. **Alias tables beat renames.** Keep wire vocabulary in schema/SDK; normalize to an app closed set once at the form/model edge.
6. **Wrapper / leak rule.** Map third-party and generated types to app types at the hook/model edge — do not leak them into UI props.
7. **Schema-first at IO; class/VO inward.** Avoid “schema everywhere” and “interface-only at HTTP.”
8. **Verified generated client ≠ runtime transport.** CI regenerate/assert does not prove adoption. Hand adapter owning fetch+normalize beside an unused generated runtime path is drift — cut over or delete; verify-green ≠ adoption.

## Judgment — string / object / abstraction

9. **Type what crosses a seam or encodes a closed decision.** Local scratch may stay inferred. Module boundaries, public functions, and XOR state deserve names.
10. **Reject `string` / `object` / `any` / loose `Record` at seams** when a closed set or domain type already exists — or when introducing one is cheaper than the next bug.
11. **Do not over-abstract.** No branded ids for every foreign key; no `<T>` for one call site; no parallel type hierarchies “for purity.” Prefer the smallest named alias or union that prevents the failure class.
12. **Plain-at-rest is not laziness** when the bag is cache/wire/form — rehydrate at the read seam (see architecture `refactor-types`).
13. **Route-shared identity may keep wire field shape.** When a domain id is also a route token, retaining wire name/shape on that field is allowed; alias closed decision enums once at normalize. Do not camel-fork the same identity across URL and model.

## Checker honesty

14. Excess-property checks apply to **fresh** object literals — assigning through a variable loses them; do not “fix” that way.
15. Prefer `Readonly` / `readonly` on props and shared collections the callee must not mutate.
16. Prefer `satisfies` over annotate-and-cast-looser.
17. `@ts-expect-error` needs reason + removal condition; `@ts-ignore` banned.

## Tooling

18. **Dual TypeScript graphs.** Document check CLI vs `require('typescript')` tooling resolution when the repo pins both — upgrading one must not silently break the other.
19. **Lint the seam you keep forgetting.** Prefer error-level ACL for transport/SDK/UI boundaries when the project has them; warn-first for stylistic noise. Cite `AGENTS.md` for live rule names — do not invent rules here.
20. **Generated trees are read-only** in the change; do not eslint-fix or hand-edit them.
