# capacity

Suggest a sprint story-point **commitment** from historical estimated-done velocity, named absences, and already-queued estimated load. Do not replace `gate`, `prioritize`, invent Priority/OKRs, or teach board-tool mutation recipes.

## Earn this branch

Sprint planning capacity / commitment asks: “how many story points next sprint?”; velocity-based targets; OOO- or absence-adjusted planning; optional delivery-uplift judgment the user asserts (e.g. tooling maturity).

If the ask is backlog **ordering** across items → `prioritize`. If the ask is “should we build X?” → `gate`.

## Checklist

1. **Discover sprint window and absences**
   - Confirm sprint start/end (or length in working days) from the board or the user.
   - List **named** absences (who, how many working days in-sprint). Do not invent headcount or assume full team size — use only what the user or board provides. Express lost person-days vs a full-sprint baseline the user supplies, or state capacity fraction as `unknown` and cap Confidence ≤ Medium.

2. **Read board evidence (no invention)**
   - Query the team’s existing issue tracker for: recent **closed** sprints’ **completed estimated** story points; the **next** (or target) sprint’s **already estimated** points; count of **unestimated** items already on that sprint (bugs/chores if the team’s policy skips estimating them).
   - Cite sprint names and the story-point field the board already uses. Do not hard-code tool APIs, custom-field IDs, or product fingerprints in reasoning presented as doctrine.

3. **Baseline velocity**
   - Prefer the last **3–5** closed sprints’ estimated-done totals. State median and range.
   - Cap Confidence ≤ Medium when a large share of completed work was unestimated — unestimated shipped work may support a **stretch** judgment but must not invent a second numeric baseline.

4. **Adjust for remaining capacity**
   - Scale the baseline by the remaining capacity fraction implied by named absences (when headcount/person-day baseline is known). If that baseline is `unknown`, adjust qualitatively and keep Confidence ≤ Medium.
   - Mantra: commitment follows estimated-done velocity and named absences; unestimated shipped work raises confidence in stretch but never invents a second baseline.

5. **Compare to already-queued estimated load**
   - If estimated points already on the sprint approach or exceed the adjusted target, recommend light fill only — or explicit **cuts** after refinement — rather than adding a second epic’s worth of work.
   - Commitment must leave headroom for priority **unestimated** items once refined, or call out that those items force cuts elsewhere.

6. **Optional uplift (user-asserted only)**
   - Stretch above the OOO-adjusted baseline only when the user explicitly claims a delivery uplift (e.g. AI-assisted throughput). Treat uplift as judgment, not invented math. Always keep a planning **band** around the single recommended number.

7. **Output posture**
   - Default: **read-only** commitment advice. Mutate the board only if the user explicitly asks — this branch does not teach board-tool recipes.

## Sequencing

1. Sprint window + named absences.
2. Closed-sprint estimated-done + next-sprint estimated/unestimated load.
3. Baseline → capacity-adjust → compare to queued load → optional user uplift → band + single recommendation.
4. Emit Decision Output. Stop unless the user asks for board mutations or routes to `prioritize` / `gate`.

## Decision Output

Emit always for this branch:

**Recommended commitment** — single story-point number.
**Planning band** — low–high around that number (required when velocity is noisy or uplift is asserted).
**Capacity adjustments** — named absences and approx % of sprint capacity remaining (or `unknown`).
**Board load** — estimated points already in the target sprint; unestimated count and risk if refined heavy.
**Confidence**: [High | Medium | Low] — High needs cited sprints + clear absence math; gaps and heavy unestimated history cap at Medium.
**Evidence** — sprint names / fields / sources read; gaps explicit.
**Risks / cuts** — what to drop or hold if priority unestimated work lands heavy after refinement.
**Mutations**: `none (read-only)` unless the user explicitly requested board changes — then list only what they asked to change.

Do not invent Priority labels, OKR scores, golden/operator paths, or a fake second velocity baseline from unestimated throughput.

## Anti-patterns

- Publishing one commitment number with no band when closed-sprint estimated-done is noisy.
- Treating unestimated bugs/chores as zero historical throughput (undercounts delivery) _or_ as a numeric second baseline (invention).
- Inventing team size, Priority scales, OKRs, or product-named doctrine.
- Stretching for “AI” or tooling uplift the user did not assert.
- Ignoring already-queued estimated load when recommending a target.
- Substituting for `prioritize` (ordering) or `gate` (admission).
- Mutating the board without an explicit user ask; dumping API/field-ID recipes into skill text or user-facing doctrine.

## Completion

Done when: recommended SP + planning band stated; capacity adjustments and board load cited; Confidence + Evidence + Risks/cuts present; Mutations default `none (read-only)`; no invented Priority/OKR/path/second-baseline doctrine.
