# Structure survey

Peer-directory survey for canonical shape, snowflakes, and ownership-move leverage. Discovery only — fixes go to craft branches. Load/skip rules: `SKILL.md` Pick branch.

## Procedure

1. Repo law (`AGENTS.md`, conventions) overrides inferred majority; note conflicts.
2. Compare sibling shapes level by level (top-level packages → peer feature/domain folders → shared layers): layer names, nesting depth, file-role suffixes.
3. State the canonical shape (peer majority within repo law).
4. Flag snowflakes: same job in different homes, incomplete twin stacks, placement drift, deletion-test micro-modules, dump/passthrough bags in shared trees.
5. Flag layer inversions: shared/lower layers importing domain layers; dual homes for one type/fact.
6. Verify orphans and inversions with call-site search before ranking Critical / Important; label each Strong / Worth / Speculative.
7. Rank moves by leverage, in order:
   1. delete orphans / passthroughs failing the deletion test
   2. relocate wrong-layer domain surfaces to the owner (before deepening in place)
   3. fold single-consumer micro-modules
   4. unify placement where peers of one kind diverge without an owned exception
   5. promote only truly shared, domain-free surfaces (shared kernel absorbing domain → push down)
   6. nest only when flat sprawl hides a real second job

## Handoff to craft branches

Ownership / depth / seams / deletion test → `deep-modules`; plus `refactor-types` for type dual homes / closed sets on the seam; `refactor-boundaries` for serialize shells / domain in boundaries; `design-patterns` for named GoF or ceremony without forces; `performance` for a measured hot path driving layout. Language fixes stay `$dev` → `{lang}-dev`.

## Anti-patterns

- LOC / file-count smells not naming dual ownership, inversion, or deletion-test failure.
- A second "shared" home to avoid moving files.
- Flattening intentional infra / nested mega-modules that own a different job than peer domains.
- Encoding repo-specific folder names as global law.

## Done when

- Canonical shape stated (law + majority, conflicts noted)
- Anomalies ranked with evidence labels
- Craft-branch handoff named for each Important+ item (or deferred with reason)
- Residual dual ownership called out
- No code required in this mode
