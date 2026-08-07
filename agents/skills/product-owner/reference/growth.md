# Growth (branch expansion + harvest)

Load only when adding a product-owner branch or harvesting product-judgment lessons. Not part of normal gate load.

## Branch expansion law

Follow before adding any product-owner branch:

1. **New branch only if** all hold: (a) distinct signals from existing branches; (b) cannot be a section inside `SKILL.md` or an existing `reference/*.md`; (c) reusable ≥2 times; (d) domain-agnostic (no product fingerprints).
2. **Add a branch:** one row in `## Pick branch` + authored `reference/<branch>.md` (or inline branch body) + completion row. Do not invent a top-level skill.
3. **Stub rows** stay stubs until authored. Do not invent stub content mid-harvest.
4. **Growth default:** staging candidates → [`learning-log.md`](learning-log.md); **sparse promote** into `SKILL.md` Doctrine / Doctrine Check / Decision Output / Workflow only when judgment changes and is not already covered; **drop** the rest. Edit the router (`SKILL.md` Pick branch / When to use) only when the contract is wrong.
5. **Reject:** product-named doctrine, incident write-ups, implementation recipes, checklist clones of Simplification / Concept budget / Default surface, activating stubs without authored reference.

## Growing reference

Stage candidates in [`learning-log.md`](learning-log.md) when a gate or scope debate left a lesson that will prevent the next wrong admit/defer; guidance was missing/wrong; or the user asks for a learning capture.

Gems are **preventive mantras** for failure classes — reflective instruction an expert recalls before repeating the mistake — not ticket write-ups or technique recipes.

Product-judgment classes (prefer these over incidents):

- operator / internal paths vs end-user golden paths
- scope exclusions and diagnose-before-mutate
- concept slices (one identity / one model per v1)
- gate artifacts (ticket density for skilled engineers)

1. Scope corpus to product-judgment classes — not implementation details, field lists, or auth recipes.
2. **Generalize before ingress.** Strip product nouns, paths, schemas, ticket keys, and domain fingerprints; a stranger must not infer the source product.
3. Abstract: one imperative sentence an expert agent can apply in any product domain.
4. Filter: reject checklist / doctrine restatements and near-clones. A narrower failure class may specialize; a clone may not.
5. Tag each kept candidate with primary landing: `doctrine` | `doctrine-check` | `decision-output` | `workflow` | `branch:<name>`. One primary only.
6. Cap ~10 new candidates per harvest event unless the user asks for more. Noise-pass for product leakage and overlap.
7. **Sparse promote** into matching `SKILL.md` sections (or authored branch reference) only when judgment changes; **drop** the rest.
8. Structural craft / ownership / types / seams → `architecture` growth. Assure / review judgment → `review.gil` growth. Language-only → `*-dev`.

### Ingress

1. **Propose in staging → filter → promote or drop.** Candidates land in `learning-log.md` for the same harvest event; sparse-promote into `SKILL.md` (or branch reference) or drop. Leave the log empty/thin. No permanent archive of rejects.
2. **Write only from a fresh read.** Staging is concurrent shared state; a stale snapshot is how harvests collide or duplicate.
3. **Dropping weak harvests is required.** Reject restatements and near-clones; do not keep noise “for later.”
