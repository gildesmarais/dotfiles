# Structure survey

Peer-directory tree survey: discover canonical shape, snowflakes, and promote/relocate leverage. Language-free. Discovery only — hand off craft fixes to craft branches.

## Earn this mode

Load when ≥1 structural signal matches the router matrix in `SKILL.md` (tree / layout / peer conformity / snowflake / ownership-move ranking).

Skip when the ask is bare “review code”, product “promote”, UX “unify”, or surgical deepen of one named module already in hand (`deep-modules` and siblings).

## Procedure

1. **Read repo law first** — `AGENTS.md` / project conventions override inferred majority when they conflict. Note the conflict in the survey output.
2. **Peer-directory compare** — at each meaningful level (top-level packages/modules, then peer feature/domain folders, then shared layers), list sibling folder shapes: layer names, nesting depth, file-role suffixes.
3. **Infer canonical shape** — majority practice among peers of the same kind, constrained by repo law. Document the chosen canonical.
4. **Flag snowflakes** — same job in different homes; incomplete twin stacks; screens/hooks/utils placement drift; micro-modules that fail the deletion test; dump / passthrough bags in “shared” trees.
5. **Flag layer inversions** — lower/shared layers importing owning/domain layers; dual homes for one type/fact across `types` / shared utils / domain modules.
6. **Rank moves by leverage** (prefer deletion of orphans over relocation theater):
   - **promote** — shared kernel absorbing domain → push down; presentational shell rising only when props-only / domain-free
   - **relocate** — wrong layer → owning module
   - **unify** — placement convention across peers of one kind
   - **fold** — micro-module into one consumer home
   - **nest** — flat sprawl → intentional sub-module
7. **Evidence labels** — Strong / Worth / Speculative. Verify orphans and inversions with call-site search before ranking Critical / Important.
8. **Handoff** — ranked ledger + which craft branches to load next. Language-runtime fixes stay in `$dev` → `{lang}-dev`.

## Leverage ranking

Prefer this order:

1. Delete orphans / passthroughs that fail the deletion test
2. Relocate wrong-layer domain surfaces to the owning module (before deepening in place)
3. Fold micro-modules with a single consumer home
4. Unify placement when peers of one kind diverge without an owned exception
5. Promote only when the surface is truly shared and domain-free
6. Nest only when flat sprawl hides a real second job

Label each item Strong / Worth / Speculative. Call out residual dual ownership even when deferred.

## Handoff to craft branches

| Survey finding                                                         | Load next                  |
| ---------------------------------------------------------------------- | -------------------------- |
| Ownership / depth / seams / locality / deletion-test failure           | `deep-modules`             |
| Dual homes for one type / closed set / primitive obsession on the seam | also `refactor-types`      |
| Serialize shells / adapter contract / domain in boundary layers        | also `refactor-boundaries` |
| Measured hot path driving a layout move                                | also `performance`         |

Survey first → multi-load craft branches as warranted → one combined handoff.

## Anti-patterns

- LOC / file-count smells without naming dual ownership, inversion, or deletion-test failure
- A second “shared” home for domain UI or logic to avoid moving files
- Flattening intentional infra / nested mega-modules that already own a different job than peer domains
- Encoding repo-specific folder names as global skill law
- Auto-loading from bare “promote” / “unify” without tree, snowflake, layout, or ownership-move cues
- Whole-tree survey when the ask is surgical deepen of one named module already in hand

## Done when

- Canonical shape stated (law + majority, conflicts noted)
- Anomalies ranked with evidence labels
- Craft-branch handoff named for each Important+ item (or deferred with reason)
- Residual dual ownership called out
- No code required in this mode
