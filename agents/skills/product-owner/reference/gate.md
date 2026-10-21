# Gate (`gate`)

## Doctrine (overrides enthusiasm, founder bias, elegance)

When doctrine conflicts with a proposal: cut, defer, or redesign — never debate doctrine away.

- **More steps = worse.** Shortcuts don't remove cognitive load.
- **Persona:** every proposal serves a documented persona and usage context.
- **Golden path:** name the documented path served and its friction delta. Work not touching a golden path defaults to defer/reject until budgets exist.
- **Mental model:** name the documented model reinforced/violated, or `unknown`.
- **Simplification:** Remove → Hide → Consolidate → Automate → Add; prefer leftmost.
- **Default surface:** ship working defaults; no tuning knobs on the primary surface.
- **Concept budget:** >1 new concept needs explicit justification.
- **Cost-to-value:** new surface must justify customer value against golden-path friction.
- **Pragmatic subservience:** capabilities stay subservient to the primary surface.
- **Health Capacity Budget:** [`../../CONTEXT.md`](../../CONTEXT.md) — read `<project>/.agents/debt-ledger.md` before admitting scope.

## Workflow

Run in order for gate and overlay.

0. **Staleness check.** Read the doctrine section of `<project>/.agents/product.md`.
   - Absent → Evidence `ledger absent`; invent no thresholds. Quiet overlay Build Now → one line.
   - Declared threshold tripped → **Research Further**, reason `re-baseline`; do not evaluate the feature.
1. **Discover constraints** per router Shared prep; list sources and gaps; check the debt ledger.
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
4. **Founder-bias check** — enthusiasm, elegance, parity are insufficient alone.
5. **Decision Output** per router gate-vs-overlay rule.
6. **Record** — append to `.agents/product.md` only when it already has an evaluations section; never invent one.

## Decision Output

```text
**Recommendation**: Build Now | Build Later | Research Further | Reject
**Confidence**: High | Medium | Low
**Forced Challenge**: <one sentence: strongest "do not build" case, and why it fails or wins>
**Evidence**: <bullets of doc paths read; gaps explicit>
**Reason**: <one paragraph>
**Doctrine delta**: none | <anchor/registry/direction edit in this tranche>
```

Vocabulary meanings: [`../../CONTEXT.md`](../../CONTEXT.md). Confidence High requires cited constraints; unknowns cap at Medium.

**Invalid output:** any admit labeled a founder override with Doctrine delta `none`. A founder override is allowed only when the same tranche edits doctrine so the decision is non-override next time.
