# prioritize

Rank a SCRUM-style backlog under readiness and sequence signals. Order admitted/ready work and park the rest — do not replace `gate`, invent Priority scales, OKRs, or product doctrine.

## Earn this branch

Backlog ranking across items; Priority labels flat or untrusted; Ready vs held / On Hold; refinement readiness (refined vs needs-refine); dependency or phased-sequence ordering; research-blocked / spike-held clusters.

If the ask is only “should we build X?” with no ranking set → stay on `gate`.

## Checklist

1. **Discover axes (no invention)**
   - Read product docs and board fields already in use (Rank, Ready/held, refined vs needs-refine, dependency/phase notes). Cite sources; mark gaps `unknown`.
   - When Priority is uniform or untrusted, ignore Priority as an ordering signal — use Rank plus readiness axes. Do not invent a Priority scale mid-rank.

2. **Split pullable vs parked**
   - Separate **pullable** (ready + refined enough for delivery capacity) from **parked/held** (On Hold, blocked, needs refine, research-blocked) before ranking.
   - Rank only within the pullable set. List parked items separately with one-line park rationale each.

3. **Refinement before capacity**
   - Treat refinement readiness as a gate before delivery-capacity ranking. Unrefined work is not pullable capacity — park or send toward refine, do not interleave as if ready.

4. **Sequence over isolated value**
   - Prefer documented or evident dependency / phased-sequence order over isolated “value” ranking. If sequence is unclear, say so and keep Confidence ≤ Medium — do not invent OKRs or value scores.

5. **Research-blocked clusters**
   - Park clusters held on spike/research outcomes until the outcome unlocks delivery. Do not promote delivery children ahead of the unlock.

6. **Path serve (reuse gate — do not replace)**
   - Work that does not serve a named end-user or operator path → deprioritize or park. Cite product docs or mark `unknown`. Do not invent golden/operator paths mid-rank.
   - Admission (“does this deserve capacity?”) remains `gate`. This branch orders admitted/ready work and parks the rest.

7. **Output posture**
   - Default: **read-only** ranking advice. Mutate the board only if the user explicitly asks — this branch does not teach board-tool recipes.

## Sequencing

1. Discover axes and gaps from docs/board fields.
2. Split pullable vs parked/held (incl. needs-refine and research-blocked).
3. Order the pullable set by Rank + readiness, then dependency/phase when evident.
4. Emit Decision Output. Stop unless the user asks for board mutations or a `gate` admit on unadmitted items.

## Decision Output

Emit always for this branch:

**Ordered (pullable)** — ranked list; each item: one-line rationale (axis used: Rank / ready / refined / sequence).
**Parked** — held / needs-refine / research-blocked / pathless; each item: one-line park reason.
**Confidence**: [High | Medium | Low] — High requires cited axes; unknowns and invented-value temptation cap at Medium.
**Evidence**: Docs/board fields read (paths or field names). Note gaps explicitly.
**Mutations**: `none (read-only)` unless the user explicitly requested board changes — then list only what they asked to change.

Do not invent Priority labels, OKR scores, click budgets, or golden/operator paths in the output.

## Anti-patterns

- Ranking by Priority when every item shares the same Priority.
- Interleaving held / needs-refine / research-blocked items into the pullable order “for completeness.”
- Inventing Priority scales, OKRs, value scores, or golden paths mid-rank.
- Treating `prioritize` as a substitute for `gate` admission.
- Mutating the board without an explicit user ask.
- Product fingerprints (names, ticket keys, domain nouns) in skill text or invented doctrine.

## Completion

Done when: pullable vs parked split stated; pullable set ordered with one-line rationales; parked items listed with park reasons; Evidence lists sources or gaps; Mutations default `none (read-only)`; no invented Priority/OKR/path doctrine.
