# typescript-dev reference

TypeScript-only postures; craft → `architecture`.

## Boundary typing

1. **Cache shape ≠ domain shape.** Durable bags hold plain records; rehydrate in `select` or model. UI props take domain types, not generated wire types.
2. **Fallible at untrusted edges.** `try*` / quarantine in render and display paths; throwing constructors only after trusted parse.
3. **Sentinel maps over branding.** One leaf of explicit layer mappers beats nominal brands for multi-layer identity.
4. **Generated owns wire; hand owns domain.** Don't force class instances through generated schemas or re-unwrap in services. Map third-party and generated types to app types at the hook/model edge; schema-first at IO, class/VO inward.
5. **Alias tables beat renames.** Wire vocabulary stays in schema/SDK; normalize to an app closed set once at the form/model edge. Route-shared identity may keep wire field shape.
6. **Verified generated client ≠ adoption.** A hand adapter owning fetch+normalize beside an unused generated path is drift: cut over or delete.

## Checker honesty

7. Excess-property checks apply only to **fresh** literals; assigning through a variable is not a fix.
8. `readonly` on props and shared collections the callee must not mutate.

## Tooling

9. **Dual TypeScript graphs.** Document check CLI vs `require('typescript')` resolution when both are pinned.
10. Error-level lint ACLs for transport/SDK/UI boundaries when the project has them; warn-first for style. Rule names from `AGENTS.md`.
11. Generated trees are read-only: no eslint-fix or hand edits.
12. **Split Vitest by environment.** Pure modules: `environment: 'node'`. Screen and timer-hook files: jsdom + one interceptor (`onUnhandledRequest: 'error'`).
13. **Drive DOM as the framework listens.** `@testing-library/user-event` over `fireEvent` for `onInput` and listbox keys; submit the real form.
