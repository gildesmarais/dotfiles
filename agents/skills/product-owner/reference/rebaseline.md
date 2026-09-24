# Doctrine re-baseline (`rebaseline`)

Re-derive doctrine from what shipped and was kept (doctrine written before exploration ends is a fossil). Never evaluate a feature here; never invent a ledger, thresholds, golden paths, personas, or registry rows; never hardcode a product name or repo path — read the repo-local wrapper and the files it cites.

Not this branch: "should we build X?" on a trusted basis → `gate`; slicing → `story-slice`.

## Inputs (discover)

- **Doctrine ledger:** wrapper line `Doctrine ledger: <path>`; absent → record `ledger absent`, recommend declaring one, fabricate no path.
- **Thresholds:** wrapper only; ledger present without thresholds → note the gap.
- **Have / shipped record:** the repo's existing status log / roadmap.
- **Direction, anchors, reject registry:** files the wrapper or product docs already name; a role with no file → name the gap, no new doc scheme.

## Procedure

Cite paths; silent source → `unknown`.

1. **Have since baseline:** shipped-and-kept since the ledger's last re-baseline date (no date → say so). Every row cites a path.
2. **Overrides:** founder overrides since baseline, each cited; flag mismatch with the ledger's override count.
3. **Direction delta:** one delta (not a wishlist) — what the product became that written direction doesn't say. No direction doc → name the gap; only edit an existing direction artifact.
4. **Re-derive anchors:** each kept anchor justified by Have or an explicit kept decision; drop anchors nothing kept serves.
5. **Re-gate registry:** every remaining reject cites the new direction, else delete or flip to Have.
6. **Re-gate Admitted-not-Have tranches** against the new direction; drop unsupported Build Nows.
7. **Unexplained-by-direction list:** shipped/kept surfaces the new direction doesn't explain (seeds removal; not a backlog).
8. **Removal shortlist:** ≥3 candidates, each with cited surface, evidence it doesn't serve the direction, and what would be lost.
9. **Reset ledger** (if the file exists): set last re-baseline date (or the repo's tranche id) and override count `0`. Never declared → stop at the `ledger absent` recommendation.

## Output

1. Have-since-baseline (cited) 2. Overrides (cited, or explicitly none) 3. Direction delta (one paragraph) 4. Anchor delta (changed/dropped) 5. Registry disposition (kept-with-citation / deleted / flipped to Have) 6. Admitted-not-Have re-gate results 7. Unexplained-by-direction list 8. Removal shortlist (≥3, evidence) 9. Ledger reset note (or `ledger absent`)

## Completion criteria

Steps 1–9 emitted; doctrine edits land only in files the repo already uses.

**Falsification:** zero registry rows flipped/deleted **and** zero removal candidates **fails** unless an explicit "why nothing changed" paragraph is written. A date bump with no delta is not a re-baseline.

## Handoff

```text
product-owner rebaseline
  done → gate can run again against the new basis
  feature that tripped staleness → do not evaluate it until this branch is done
```
