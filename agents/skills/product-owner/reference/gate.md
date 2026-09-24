# Gate (`gate`)

## Doctrine (overrides enthusiasm, founder bias, elegance)

When doctrine conflicts with a proposal: cut, defer, or redesign — never debate doctrine away.

- **More steps = worse.** Shortcuts/power-user affordances don't remove cognitive load.
- **Persona:** every proposal serves a documented persona and usage context.
- **Golden path:** name the documented path served and its friction delta. Adding steps is suspect. Work not touching a golden path defaults to defer/reject until documented budgets exist (never invent them mid-evaluation).
- **Mental model:** name the documented model reinforced/violated, or `unknown` (no invented catalog).
- **Simplification:** Remove → Hide → Consolidate → Automate → Add; prefer leftmost that delivers the outcome.
- **Default surface:** ship working defaults; no tuning knobs / sliders / expert controls on the primary surface.
- **Concept budget:** >1 new concept needs explicit justification.
- **Cost-to-value:** new surface (UI, API, compute, copy) must justify customer value; reject elegant work that doesn't reduce golden-path friction.
- **Pragmatic subservience:** capabilities (search, links, tags, tasks) are fine while subservient to the primary surface and plain data models; drift once they demand secondary containers, isolated dashboards, or DB sidecars.
- **Health Capacity Budget** (share per [`../../CONTEXT.md`](../../CONTEXT.md)): read `<project>/.agents/debt-ledger.md` (or `ROADMAP.md` health section) before admitting scope; high-friction debt blocking/slowing golden paths qualifies for Build Now without a new feature.

## Workflow

Run in order for gate and overlay.

0. **Staleness check.** Read the repo-local product-owner wrapper for `Doctrine ledger: <path>`.
   - Absent: never invent a ledger or path; Evidence note `ledger absent` + recommend the wrapper declare one. On quiet overlay Build Now this is one line — not a reason to emit the full block.
   - Present: read it (last re-baseline date, override count, tranche count). Thresholds come only from the wrapper; missing → note the gap, invent none.
   - Any declared threshold tripped → **Research Further**, reason `re-baseline`; do not evaluate the feature.
1. **Discover constraints** per router Shared prep; list sources and gaps; check the debt ledger for capacity/debt tranches.
2. **Doctrine Check** — answer all seven:
   1. Documented persona and context served? (cite or `unknown`)
   2. Golden path served? (cite or `unknown`)
   3. Net step/click change on it? (+/− only if budget documented; else qualitative)
   4. New concepts introduced? (count; >1 justify)
   5. Mental model reinforced/violated? (cite or `unknown`)
   6. What to remove or hide if this ships?
   7. Adds cognitive load or steps to primary workflows?

   Weak or uncited where citation required → Reject, Build Later, or Research Further.

3. **Forced Challenge** — strongest honest "do not build" case; unanswerable → Reject or Build Later.
4. **Founder-bias check** — enthusiasm, elegance, parity ("competitor had it") are insufficient alone; documented paths + models decide.
5. **Decision Output** per router gate-vs-overlay rule.
6. **Record** — only if the repo already records evaluations, using that convention; never invent a doc scheme.

## Decision Output

```text
**Recommendation**: Build Now | Build Later | Research Further | Reject
**Confidence**: High | Medium | Low
**Forced Challenge**: <one sentence: strongest "do not build" case, and why it fails or wins>
**Evidence**: <bullets of doc paths read; gaps explicit>
**Reason**: <one paragraph>
**Doctrine delta**: none | <anchor/registry/direction edit in this tranche>
```

- **Build Now**: serves a documented golden path, within documented budgets/models, Forced Challenge answered, concepts justified.
- **Build Later**: valuable, but paths/budgets not ready or higher-priority friction remains.
- **Research Further**: missing docs, unclear outcome, thin evidence (e.g. silent docs → name smallest missing artifact such as golden-path budgets).
- **Reject**: violates doctrine, adds golden-path friction without offsetting removal, or only founder/parity justification.

Confidence High requires cited constraints; unknowns cap at Medium.

**Invalid output:** any admit the evaluation labels a founder override with Doctrine delta `none`. A founder override is allowed only when the same tranche edits doctrine so the decision is non-override next time.
