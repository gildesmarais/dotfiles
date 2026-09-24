# Legacy

Dead compat: dual public names, superseded persisted shapes, markers keeping both live. PR targets: judge at the recorded head SHA.

Load on deprecated/obsolete markers, dual exports, readers accepting a superseded store/wire shape beside the current one, explicit legacy/no-compat cleanup asks, and always under `quality`. Skip when the only hit is a live published contract (a test title saying "legacy" is not evidence).

## Law

One public name and one accepted shape per concept. `findings` / `publish`: report, never delete. `quality`: delete dead API, retarget callers, delete migration-only tests. User explicitly requires backward compat → report and stop; never invent shims.

## Find (verify by search/read)

| Class               | Signal                                                                            |
| ------------------- | --------------------------------------------------------------------------------- |
| Marker              | `@deprecated`, `Obsolete`, `DEPRECATED`, "compat", "during refactor" comments     |
| Dual export         | Two exported names for one schema/type/function; alias with both live             |
| Superseded hydrate  | Parse-old → map-to-current beside a current-only path; unbounded old-shape accept |
| Wrong type home     | Shared kernel imports a re-export duplicating the owned type module               |
| Migration-only test | Suite whose only job is proving the old shape still loads                         |

## Severity

| Finding                                                                  | Findings              | `quality`   |
| ------------------------------------------------------------------------ | --------------------- | ----------- |
| Dual live API / unbounded old-shape hydrate (correctness/security blast) | Critical or Important | P0          |
| Dead export with retargetable in-repo callers                            | Important             | P1          |
| Unused deprecated export, zero callers                                   | Nice-to-Have          | P2 (delete) |

## Before deleting (`quality` only)

1. Search the whole repo (source, tests, fixtures, docs, generated clients, config), not just the diff.
2. Published surface (package export, wire contract, semver'd API) or unknown external consumers → report only.
3. Deletion is its own commit; a removed published name carries `!` / `BREAKING CHANGE` per [`../../CONTEXT.md`](../../CONTEXT.md) Phase commit law — never buried in a `refactor:` boy-scout commit.

Output folds into the `finish` report (a focused legacy review may use the tables directly). Dual type homes / layer inversion → name `architecture` `refactor-types` / `deep-modules` / `refactor-boundaries`; review never runs them. Out of scope: unrelated renames, a third compat layer.
