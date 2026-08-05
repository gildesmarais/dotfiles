---
description: "Language-free solution craft for module depth, type-driven refactors, and measured performance. Use when design or structural cleanup is earned, when a *-dev skill classifies design, or when the user asks to deepen modules, replace primitives with domain types, or optimize with a baseline.\n"
---
# Architecture

Change how the codebase is structured, typed, or measured for performance — not whether to build a feature, and not language-runtime validation.

## Pick branch

Never ask the user to pick a template when signals are clear. Load one or more branches when signals combine (same as review lenses).

| Branch                | Job                                                                | Status |
| --------------------- | ------------------------------------------------------------------ | ------ |
| `deep-modules`        | Module/interface/depth/seam/adapter/locality/deletion test         | active |
| `refactor-types`      | Primitives/strings → domain types; logic on types; type hygiene    | active |
| `refactor-boundaries` | Wire/API/adapter contract maps; keep domain out of boundary shells | active |
| `performance`         | Measure → baseline → optimize; language-free stop rules            | active |

| Signal                                                    | Branch                |
| --------------------------------------------------------- | --------------------- |
| deepen, shallow modules, seams, locality, dual ownership  | `deep-modules`        |
| primitive obsession, stringly enums, logic-on-types       | `refactor-types`      |
| wire/API maps, adapter contract shape, boundary serialize | `refactor-boundaries` |
| slow, hot path, allocate, profile, benchmark              | `performance`         |

If the ask is “should we build X?”, stop — use `product-owner`. If the ask is surgical language work only, stay in the relevant `*-dev` skill.

## Shared prep

1. Read `AGENTS.md` when present; prefer repo law over defaults here.
2. Evidence before claims: call sites, ownership, existing tests. Label Strong / Worth / Speculative when surveying.
3. Apply the glossary in [`reference/glossary.md`](reference/glossary.md) on every loaded branch.
4. Multi-load OK when signals combine; one handoff covering all loaded branches.
5. Keep craft language-free. Language recipes belong in `*-dev`, overlays, third-party packs, or project `AGENTS.md` — not here.
6. **Phase → validate → commit:** after each craft phase (architecture phase, surgical milestone, or user-named plan step), validate, then create ≥1 Conventional Commit with a rationale/intent body before the next phase. Format and phase law: [`CONTEXT.md`](../CONTEXT.md). Inspect `git log` / `git show` when deepening history. Do not wait until `release` **`notes`** or PR open to author history.

### Branch expansion law

Agents must follow these before adding any architecture branch:

1. **Never** add a branch named `refactor`. Use `refactor-<concern>` (e.g. `refactor-types`, `refactor-boundaries`).
2. **New branch only if** all hold: (a) distinct signals from existing branches; (b) cannot be a section inside an existing `reference/*.md`; (c) reusable ≥2 times; (d) language-free.
3. **Add a branch:** one row in `## Pick branch` + signals table + `reference/<branch>.md` + completion row. Do not invent a top-level skill.
4. **Overlap rules:** module ownership/depth → `deep-modules`; closed sets / newtypes / logic-on-types → `refactor-types`; serialize/deserialize and adapter contract shape → `refactor-boundaries`; speed/allocations with measure → `performance`.
5. **Multi-load OK** when signals combine (same as review lenses).
6. **Growth default:** harvest bullet tagged with branch name → `reference/learning-log.md`. Edit branch checklist only when the contract is wrong.
7. **Reject:** `refactor-misc`, `cleanup`, language-named branches (`refactor-rust`), third-party recipe dumps.

## Branch reference

Load each selected branch’s reference and follow it through completion. Always load the glossary with any branch.

- Glossary → [`reference/glossary.md`](reference/glossary.md)
- **`deep-modules`** → [`reference/deep-modules.md`](reference/deep-modules.md)
- **`refactor-types`** → [`reference/refactor-types.md`](reference/refactor-types.md)
- **`refactor-boundaries`** → [`reference/refactor-boundaries.md`](reference/refactor-boundaries.md)
- **`performance`** → [`reference/performance.md`](reference/performance.md)
- Learning log → [`reference/learning-log.md`](reference/learning-log.md) (consult when a loaded branch has tagged gems)

## Handoff

- Implementation and language validation continue in the relevant `*-dev` / overlay after craft decisions are clear.
- Assure / ship continues with `review` / `pull-request` — never reverse.
- Product scope questions go to `product-owner`, not this skill.
- Changelog from merged history → `release` **`notes`** (consumer only).

## Growing reference

Grow `reference/learning-log.md` when a design or recurring failure class left a lesson that will prevent the next dual-ownership / shallow-seam / type / measured-perf mistake; guidance was missing/wrong; or the user asks for a learning capture.

Gems are **preventive mantras** for failure _classes_ — reflective instruction an expert recalls before repeating the mistake — not incident write-ups, mining procedures, or technique recipes.

1. Scope corpus to structural cuts (ownership, seams, types, measured perf) — classes over incidents; dependency bumps and fixture moves are not harvest.
2. **Generalize before ingress.** Strip product nouns, paths, schemas, language APIs, and domain fingerprints; a stranger must not infer the source codebase.
3. Abstract: one imperative sentence an expert agent can apply in any language.
4. Filter: reject bullets that only restate an existing branch checklist **or any existing learning-log gem**. A narrower failure class may specialize; a clone may not.
5. Tag each kept gem with branch name(s): `deep-modules` | `refactor-types` | `refactor-boundaries` | `performance`.
6. Cap ~10 new bullets per harvest event unless the user asks for more. Noise-pass for product leakage and overlap.
7. Do not grow branch checklists unless the contract itself is wrong (expansion law rule 6).
8. **Scarce reverts:** repeated harden / review-follow-up chains can mean a missing principle (signal shape only — no corpus identity in the log).

### Ingress

1. **Harvests accumulate; they do not replace.** A new corpus is a new dated section. Overwriting a peer section to “make room” destroys shared memory.
2. **Write only from a fresh read.** The log is concurrent shared state; a stale snapshot is how harvests disappear.
3. **One corpus, one section, one numbering continuum.** Name the _signal_ in the heading (e.g. deepen, fix/revert year)—never a product or repo name; continue global ids; filter against the entire log.
4. **Pointers may thin; the corpus must not.** Folding into `*-dev` / review is optional posture thinner than the gem — cues that awaken judgment, not procedures or deletion. Restore missing harvests by append, never by rewriting unrelated sections. The learning-log remains the only full-gem store.

## Completion criteria

| Branch                | Done when                                                                                                          |
| --------------------- | ------------------------------------------------------------------------------------------------------------------ |
| `deep-modules`        | Deletion test / ownership / seams addressed; phases validated; residual dual ownership called out                  |
| `refactor-types`      | Primitive obsession at target cleared or scoped; logic on types; consumers cleaned; boundaries mapped              |
| `refactor-boundaries` | Contract map for targeted edges; domain out of shells; serialize ownership clear; phases committed per Shared prep |
| `performance`         | Baseline or hot path identified before changes; stop rules applied; no language-specific recipe invented here      |
| multi-load            | Each loaded branch’s done-when met or explicitly N/A with reason; one combined handoff                             |
