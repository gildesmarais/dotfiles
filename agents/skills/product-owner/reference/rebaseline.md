# Doctrine re-baseline (`rebaseline`)

Re-derive doctrine from what shipped and was kept. Do **not** evaluate a new feature on this branch. Do **not** invent a ledger, thresholds, golden paths, personas, or registry rows. Do **not** hardcode a product name or a repo path — read the repo-local product-owner wrapper and the files it already cites.

Load this file only when the branch is **`rebaseline`**.

**Anti-pattern:** Doctrine written before exploration ends is a fossil — re-derive from what shipped and was kept.

## Triggers

North star or anchors predate the shipped product. Founder overrides have piled up because the written basis no longer matches what was kept. The `gate` staleness check returned Research Further with reason `re-baseline`.

Not this branch: “should we build X?” against a basis you still trust → **`gate`**. Slice admitted scope → **`story-slice`**.

## Inputs (discover, do not invent)

From the repo-local product-owner wrapper and the product docs it points at:

| Input | Where |
| ----- | ----- |
| Doctrine ledger path | Wrapper line `Doctrine ledger: <path>`. If that line is absent, record `ledger absent`, recommend the wrapper declare one, and do not fabricate a path. |
| Thresholds | Whatever the wrapper states. If the ledger exists but the wrapper states no thresholds, note the gap. Do not invent numbers. |
| Have / shipped record | The status log, roadmap, or equivalent the repo already uses. |
| Direction, anchors, reject registry | The files the wrapper or existing product docs already name. If a role has no file, name the gap. Do not create a new doc scheme. |

## Procedure

Run in order. Cite paths. If a source is silent, say `unknown`.

1. **List Have since baseline.** From the repo’s existing shipped record, list what shipped and was kept since the ledger’s last re-baseline date. No ledger date → say so; do not invent one. Every row cites a path.
2. **List overrides.** List founder overrides recorded since that baseline (evaluations, roadmap, ledger). Cite each. If the ledger’s override count and the cited list disagree, say so.
3. **Derive direction delta.** From Have + overrides, state what the product became that the written direction does not yet say. One delta, not a feature wishlist. Absent direction doc → name that gap; do not author a new direction file unless this tranche is already editing the repo’s existing direction artifact.
4. **Re-derive anchors.** Rewrite anchors so they describe what shipped and was kept. Every kept anchor must be justifiable from the Have list or an explicit kept decision. Drop anchors that nothing kept still serves.
5. **Re-gate the registry.** Every remaining reject must cite the new direction. If it cannot, delete the row or flip it to Have. Do not leave a reject that only cites the old north star.
6. **Re-gate every Admitted-not-Have tranche.** Work already admitted but not yet shipped gets a fresh gate against the new direction. Do not carry a Build Now the new direction does not support.
7. **Emit the unexplained-by-direction list.** Shipped or kept surfaces the new direction does not explain. This list seeds removal. It is not a backlog.
8. **Emit a removal shortlist.** At least three candidates. Each names the surface, the evidence it does not serve the new direction, and what would be lost if it went. No candidate without a cited surface.
9. **Reset the doctrine ledger.** When a ledger file exists: set the last re-baseline date (or the repo’s tranche id, if that is how the ledger records it) and set override count to `0`. If the wrapper never declared a ledger, stop at the `ledger absent` recommendation — do not invent the file.

## Output

1. Have-since-baseline list (cited)
2. Override list (cited, or explicitly none)
3. Direction delta (one paragraph)
4. Anchor delta (what changed, what was dropped)
5. Registry disposition (kept-with-citation / deleted / flipped to Have)
6. Admitted-not-Have re-gate results
7. Unexplained-by-direction list
8. Removal shortlist (≥ 3, with evidence)
9. Ledger reset note (or `ledger absent`)

## Completion criteria

Done when steps 1–9 are emitted and any doctrine edits land in files the repo already uses.

**Falsification:** A re-baseline that flips or deletes zero registry rows **and** names zero removal candidates **fails** unless it writes an explicit “why nothing changed” paragraph. A date bump with no delta is not a re-baseline.

## Handoff

```text
product-owner rebaseline
  done → gate can run again against the new basis
  feature that tripped staleness → do not evaluate it until this branch is done
```
