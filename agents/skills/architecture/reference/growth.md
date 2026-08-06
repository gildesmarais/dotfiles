# Growth (branch expansion + harvest)

Load only when adding an architecture branch or harvesting lessons. Not part of progressive craft load.

## Branch expansion law

Follow before adding any architecture branch:

1. **Never** add a branch named `refactor`. Use `refactor-<concern>` (e.g. `refactor-types`, `refactor-boundaries`).
2. **New branch only if** all hold: (a) distinct signals from existing branches; (b) cannot be a section inside an existing `reference/*.md`; (c) reusable ≥2 times; (d) language-free.
3. **Add a branch:** one row in `## Pick branch` + signals table + `reference/<branch>.md` + completion row. Do not invent a top-level skill. Survey/discovery modes that only feed craft branches may live as `reference/*.md` + router contract without becoming a fifth craft branch.
4. **Overlap rules:** tree / peer-layout / snowflake discovery → load `structure-survey` (survey mode); ownership/depth fixes still `deep-modules`; type dual homes → also `refactor-types`; serialize/layer shells → also `refactor-boundaries`; speed/allocations with measure → `performance`.
5. **Multi-load OK** when signals combine (same as review lenses).
6. **Growth default:** staging candidates → `learning-log.md`; **sparse promote** into matching `reference/<branch>.md` Checklist or Anti-patterns only when judgment changes and is not already covered by that file or [`glossary.md`](glossary.md); **drop** the rest. Edit the router (`SKILL.md`) only when the contract is wrong.
7. **Reject:** `refactor-misc`, `cleanup`, language-named branches (`refactor-rust`), third-party recipe dumps, a craft branch that only duplicates survey discovery.

## Growing reference

Stage candidates in [`learning-log.md`](learning-log.md) when a design or recurring failure class left a lesson that will prevent the next dual-ownership / shallow-seam / type / measured-perf mistake; guidance was missing/wrong; or the user asks for a learning capture.

Gems are **preventive mantras** for failure classes — reflective instruction an expert recalls before repeating the mistake — not incident write-ups, mining procedures, or technique recipes.

1. Scope corpus to structural cuts (ownership, seams, types, measured perf) — classes over incidents; dependency bumps and fixture moves are not harvest.
2. **Generalize before ingress.** Strip product nouns, paths, schemas, language APIs, and domain fingerprints; a stranger must not infer the source codebase.
3. Abstract: one imperative sentence an expert agent can apply in any language.
4. Filter: reject checklist / anti-pattern / glossary restatements and near-clones. A narrower failure class may specialize; a clone may not.
5. Tag each kept candidate with branch name(s): `deep-modules` | `refactor-types` | `refactor-boundaries` | `performance`. Multi-tag keepers → **one primary branch** (overlap heuristic in expansion law §4); other tags as co-load cues in the bullet only — no duplicate copies. Survey-mode lessons promote into `structure-survey.md` or sparse glossary — not a new craft branch.
6. Cap ~10 new candidates per harvest event unless the user asks for more. Noise-pass for product leakage and overlap.
7. **Sparse promote** into matching `reference/<branch>.md` Checklist or Anti-patterns only when judgment changes and is not already covered; **drop** the rest. Edit the router only when the contract is wrong (expansion law rule 6).
8. **Scarce reverts:** repeated harden / review-follow-up chains can mean a missing principle (signal shape only — no corpus identity in staging).

### Ingress

1. **Propose in staging → filter → promote or drop.** Candidates land in `learning-log.md` for the same harvest event; sparse-promote into `reference/<branch>.md` or drop. Leave the log empty/thin. No permanent archive of rejects.
2. **Write only from a fresh read.** Staging is concurrent shared state; a stale snapshot is how harvests collide or duplicate.
3. **Dropping weak harvests is required.** Reject checklist / anti-pattern / glossary restatements and near-clones; do not keep noise “for later.”
