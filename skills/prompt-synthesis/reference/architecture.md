# Architecture branch rubric

Enrich the five-field brief for structure, seams, types, or measured performance craft. Do not invent a parallel template.

## Fold into Context

- Ownership and module seams under change (who owns what; where the boundary sits).
- Current shape vs desired shape in concrete terms (types, interfaces, locality) — no persona framing.
- State transitions and failure modes when the change alters lifecycle or error paths — only when earned by the ask.

## Fold into Constraints

- Non-goals (what must stay shallow, duplicated, or untouched).
- Invariants that must survive the redesign (proven in code or repo guidelines).
- Exclusions: language-recipe dumps, product-scope expansion, unmeasured “optimize everything.”

Omit Constraints if none of the above exist.

## Fold into Verify

- Structural checks: call-site sweep, ownership/deletion test, type boundary, or measured baseline before/after when performance is in scope.
- Prefer evidence of seams and invariants over subjective “looks cleaner.”
- If measurement tooling is unknown: pointer to discover it — do not invent benchmark commands.
