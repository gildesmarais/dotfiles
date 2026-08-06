# Legacy

Dead compatibility: dual public names, superseded persisted shapes, and markers that keep both live.

After scope prep in `SKILL.md`, continue here. For a pull request, judge compat evidence at the recorded head SHA — never the local working tree or local `HEAD`.

## Load when

- Diff or tree shows deprecated/obsolete markers, dual exports for one concept, or readers that accept a superseded store/wire shape beside the current one
- User asks for legacy / tech-debt / no-compat cleanup
- Execution is `quality` (always)

Skip when the only hit is a live contract still on the published API (a test title is not evidence).

## Law

One public name and one accepted shape per concept.

| Execution              | Action                                                          |
| ---------------------- | --------------------------------------------------------------- |
| `findings` / `publish` | Report; do not delete                                           |
| `quality`              | Delete dead API + retarget callers; delete migration-only tests |

Exception: user explicitly requires backward compatibility — report and stop; do not invent shims.

## Find (verify with search/read)

| Class               | Signal                                                                            |
| ------------------- | --------------------------------------------------------------------------------- |
| Marker              | Deprecated/obsolete annotations or comments (“compat”, “during refactor”)         |
| Dual export         | Two exported names for one schema/type/function; alias with both live             |
| Superseded hydrate  | Parse-old → map-to-current beside a current-only path; unbounded old-shape accept |
| Wrong type home     | Shared kernel imports a re-export that duplicates the owned type module           |
| Migration-only test | Suite whose only job is proving the old shape still loads                         |

Marker examples (signals, not definitions): `@deprecated`, `Obsolete`, `DEPRECATED`, `obsolete`.

## Severity

Findings report uses Critical / Important / Nice-to-Have. Under `quality`, map into the Phase 1 audit table:

| Finding                                                                   | Findings default                              | `quality` priority |
| ------------------------------------------------------------------------- | --------------------------------------------- | ------------------ |
| Dual live API or unbounded old-shape hydrate (correctness/security blast) | Critical or Important                         | P0                 |
| Dead export with retargetable in-repo callers                             | Important                                     | P1                 |
| Unused deprecated export, zero callers                                    | Nice-to-Have in findings; delete in `quality` | P2                 |

## Before deleting (`quality` only)

1. Search the **whole repo** for the name — source, tests, fixtures, docs, generated clients, config — not only the diff.
2. Published surface (package export, wire contract, semver'd API) or unknown external consumers → report only; do not delete.
3. Deletion is its own commit. When the removed name was published, the commit carries `!` / `BREAKING CHANGE` per the Conventional Commits law in [`CONTEXT.md`](../../CONTEXT.md) — never bury it in a `refactor:` boy-scout commit.

## Output

Fold into the single Findings report per `SKILL.md`. A focused legacy review may use the Find / Severity tables directly.

## Handoff

Dual type homes / layer inversion → **name** `architecture` (`refactor-types`, `deep-modules`, `refactor-boundaries`) as remediation. Naming is not running craft — review does not execute those branches.

## Out of scope

Unrelated renames; third compat layer; treating current published wire as debt because a test title says “legacy.”
