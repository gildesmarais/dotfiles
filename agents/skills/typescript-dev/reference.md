# typescript-dev reference

TypeScript-only postures; craft → `architecture`. ≤~10 bullets per harvest.

## Boundary typing

1. **Cache shape ≠ domain shape.** Durable bags hold plain records; rehydrate in `select` or model. UI props take domain types, not generated wire types.
2. **Fallible at untrusted edges.** `try*` / quarantine in render and display paths; throwing constructors only after trusted parse.
3. **Sentinel maps over branding.** One leaf of explicit layer mappers beats nominal brands for multi-layer identity.
4. **Generated owns wire; hand owns domain.** Don't force class instances through generated schemas or re-unwrap in services.
5. **Alias tables beat renames.** Wire vocabulary stays in schema/SDK; normalize to an app closed set once at the form/model edge.
6. **No leaks.** Map third-party and generated types to app types at the hook/model edge.
7. **Schema-first at IO; class/VO inward.**
8. **Verified generated client ≠ adoption.** A hand adapter owning fetch+normalize beside an unused generated path is drift — cut over or delete.

## Judgment

9. Name what crosses a seam or encodes a closed decision; local scratch may stay inferred.
10. Reject `string` / `object` / `any` / loose `Record` at seams when a closed set exists or is cheaper than the next bug.
11. Smallest named alias or union that prevents the failure class — no per-FK brands, one-site `<T>`, or parallel hierarchies.
12. Route-shared identity may keep wire field shape; alias closed decision enums once at normalize.

## Checker honesty

13. Excess-property checks apply only to **fresh** literals — assigning through a variable is not a fix.
14. `readonly` on props and shared collections the callee must not mutate.
15. `@ts-expect-error` needs reason + removal condition.

## Tooling

16. **Dual TypeScript graphs.** Document check CLI vs `require('typescript')` resolution when both are pinned.
17. Error-level lint ACLs for transport/SDK/UI boundaries when the project has them; warn-first for style. Live rule names from `AGENTS.md`.
18. Generated trees are read-only — no eslint-fix or hand edits.
19. **Split Vitest by environment.** Pure modules: `environment: 'node'`. Screen and timer-hook files: jsdom + one interceptor (`onUnhandledRequest: 'error'`).
20. **Drive DOM as the framework listens.** `@testing-library/user-event` over `fireEvent` for `onInput` and listbox keys; submit the real form.
