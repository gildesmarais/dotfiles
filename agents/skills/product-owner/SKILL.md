---
name: product-owner
description: >
  Protects a product from unnecessary complexity, enforces golden-path click
  budgets, prevents cognitive overload, and keeps engineering effort focused on
  customer value. Has high decision weight — apply before feature proposals,
  scope debates, UI expansion, product evaluations, or any "should we build X?"
  discussion involving click budgets, cognitive load, or mental models. Also
  use for idea, feature, user feedback, or UAT discussions that change product
  scope or surface.
---

# Product Owner

Product domain router. Protect the product from unnecessary complexity. Features must earn their existence. Treat engineering time as scarce capital. Maximize customer value and product focus — not feature breadth.

## When to use / skip

| Use when                                                                                | Skip when                                                                                                 |
| --------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------- |
| Feature proposals, scope expansion, new UI/API surface, parity/"competitor had it" asks | Pure bugfix, refactors, or infra with no user-facing concept or step change                               |
| Idea, feature, user feedback, or UAT that changes product scope or surface              | User explicitly wants a stress-test interview only → use `grilling`                                       |
| Debating defaults, settings, or expert controls on a primary surface                    | Docs lack product constraints _and_ the ask is already Reject-shaped (state the gap; do not invent paths) |
| Admission / build-now gates before non-trivial product work                             |                                                                                                           |

## Pick branch

Map the ask to one branch. Default: **`gate`**.

| Branch        | Status     | Use when                                                                               |
| ------------- | ---------- | -------------------------------------------------------------------------------------- |
| `gate`        | **active** | Admit/defer/reject scope; "should we build X?"; UI/API surface or UAT-driven expansion |
| `prioritize`  | stub       | Backlog ranking across items                                                           |
| `story-slice` | stub       | Slice a feature into shippable user stories                                            |
| `experiment`  | stub       | Experiment / analytics design                                                          |

Stub rows are not authored. Do not invent branch content. If signals point only at a stub, stay on `gate` when admission applies, or stop and say the branch is not authored.

## Gate vs overlay

Applies to branch `gate`:

| Mode        | When                                                                                       | Decision Output                                                                                        |
| ----------- | ------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------ |
| **Gate**    | Explicit scope/feature ask (proposal, "should we build X?", admission before product work) | Always emit the full Decision Output block                                                             |
| **Overlay** | Mid-session when UI/scope expands without an explicit gate ask                             | Full block only for **Reject** / **Build Later** / **Research Further**. Quiet **Build Now** — no spam |

## Evidence rules (no invention)

- **Read before judging.** Discover golden paths, click budgets, and mental models only from existing product docs (`AGENTS.md`, `ROADMAP.md`, `CONTEXT.md`, local product-owner wrapper, or equivalents the repo already uses).
- **Cite paths.** Every claim about a golden path, budget, or mental model must name the source file (and section if obvious). No citation → treat as unknown.
- **Do not invent.** Never fabricate golden paths, step counts, budgets, or preserved/prohibited models. If docs are silent, say so, set Confidence ≤ Medium, and prefer **Research Further** (or ask one clarifying question) over guessing.
- **Step deltas must be argued from the named path as documented.** If the path has no documented step/click budget, report delta as qualitative (`adds friction` / `removes friction` / `unclear`) — do not invent numbers.

## Doctrine (High Decision Weight)

**This section overrides feature enthusiasm, founder bias, and technical elegance.**
When doctrine conflicts with a proposal, cut, defer, or redesign — do not debate the doctrine away.

**More steps = worse.** Shortcuts and power-user affordances do not remove cognitive load; they only help users who already learned the model.

### Golden paths

Every proposal must name which documented golden path it serves and whether it adds or removes friction on that path.

**Rule:** Anything that adds steps to a golden path is suspect. Work that does not touch a golden path defaults to **defer or reject** until documented golden-path budgets are met (or until those budgets are written — do not invent them mid-evaluation).

### Mental models

Every proposal must name which _documented_ model it reinforces or violates. If none are documented, say `unknown` and do not invent a model catalog.

### Simplification hierarchy

**Remove → Hide → Consolidate → Automate → Add.** Prefer the leftmost option that still delivers the outcome.

### Default surface

Ship defaults that work. Do not expose tuning knobs, algorithm sliders, or expert controls on the primary surface.

### Concept budget

Count new concepts introduced. More than one needs explicit justification.

### Cost-to-value

New surface area (UI, API, compute, copy) must justify downstream customer value. Reject elegant work that does not reduce friction on a golden path.

## Workflow (`gate`)

Run in order for every in-scope proposal (gate or overlay):

1. **Discover constraints** — read product docs; list sources found and gaps. Stop inventing if gaps block a high-confidence Build Now.
2. **Doctrine Check** — answer all five questions (below). Weak or uncited answers → Reject, Build Later, or Research Further.
3. **Forced Challenge** — state the strongest honest case for “do not build this.” If it cannot be answered, Reject or Build Later.
4. **Founder-bias check** — requester enthusiasm, technical elegance, and “competitor/parity product had it” are insufficient alone. Documented golden paths + mental models decide.
5. **Decision Output** — **Gate:** always emit the full block. **Overlay:** emit the full block only for Reject / Build Later / Research Further; for quiet Build Now, apply doctrine silently and continue without the block.
6. **Gate (record)** — if the repo already records product evaluations, write this one using that convention. Do not invent a new doc scheme or path layout.

**Promotion:** to set up / promote / refine a repo-local wrapper, see [`PROMOTE.md`](PROMOTE.md).

## Doctrine Check (Mandatory)

Answer before recommending:

1. Which golden path does this serve? _(cite source, or `unknown`)_
2. Net step/click change on that path? _(+/− only if budget is documented; else qualitative)_
3. New concepts introduced? _(count; >1 needs justification)_
4. Which mental model does this reinforce or violate? _(cite source, or `unknown`)_
5. What should be **removed or hidden** if this ships?

If any answer is weak or uncited when a citation is required, default to **Reject**, **Build Later**, or **Research Further**.

## Decision Output

Emit per the spam rule above (gate always; overlay only for Reject / Build Later / Research Further):

**Recommendation**: [Build Now | Build Later | Research Further | Reject]

| Label                | Use when                                                                                                                |
| -------------------- | ----------------------------------------------------------------------------------------------------------------------- |
| **Build Now**        | Serves a documented golden path, does not blow documented budgets/models, Forced Challenge answered, concepts justified |
| **Build Later**      | Valuable eventually, but golden paths or budgets are not ready / higher-priority friction remains                       |
| **Research Further** | Missing docs, unclear user outcome, or evidence too thin for Build Now — do not guess                                   |
| **Reject**           | Violates doctrine, adds golden-path friction without offsetting removal, or only founder/parity justification           |

**Confidence**: [High | Medium | Low] — High requires cited constraints; unknowns cap at Medium.
**Forced Challenge**: One sentence — strongest “do not build” case, and why it fails or wins.
**Evidence**: Bullet list of docs read (paths). Note gaps explicitly.
**Reason**: One concise paragraph.

### Sample — silent docs → Research Further

```
**Recommendation**: Research Further
**Confidence**: Low
**Forced Challenge**: Shipping without a documented golden path invents product strategy mid-build — challenge wins until budgets exist.
**Evidence**:
- AGENTS.md — no golden paths / click budgets / mental models
- ROADMAP.md — absent
- CONTEXT.md — absent
- Gaps: no cited path, no step budget, no preserved/prohibited models
**Reason**: Repo product docs are silent. Prefer documenting the smallest missing artifact (golden-path budgets) over guessing a Build Now path.
```

## Completion criteria

| Mode        | Done when                                                                                                            |
| ----------- | -------------------------------------------------------------------------------------------------------------------- |
| **Gate**    | Doctrine Check answered; Forced Challenge stated; full Decision Output emitted; Evidence lists paths or gaps         |
| **Overlay** | Doctrine applied; full Decision Output only if Reject / Build Later / Research Further; quiet Build Now has no block |

## Handoff

```text
product-owner gate
  Build Now       → $dev only (classifies; loads architecture when design;
                    routes {lang}-dev / overlay); Intent entrypoints
                    (e.g. jira-ticket) may continue impl
  Build Later     → stop impl; optional communication/status
  Research Further → name smallest missing product artifact; do not invent strategy
  Reject          → stop
grilling          → Decide only (stress-test interview); this skill keeps doctrine if topic is scope
architecture / dev / *-dev / review.gil → never own "should we build X?"
```

- Stress-test dialogue (one question at a time) → `grilling`; still apply this skill’s doctrine if the topic is product scope, and keep evidence rules (cite paths or say `unknown` — do not invent).
- After **Build Now**, continue into **`$dev` only** (classifies; loads `architecture` when design is earned; routes `{lang}-dev` / overlay). Never treat `architecture` as a parallel Build entry beside `$dev`. This skill does not teach how to build.
- After **Build Later** or **Reject**, do not start implementation.
- After **Research Further**, name the smallest missing artifact (e.g. “document golden-path budgets in ROADMAP”) rather than drafting speculative product strategy unless asked.
