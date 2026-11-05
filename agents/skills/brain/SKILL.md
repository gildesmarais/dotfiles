---
name: brain
description: >-
  Long-running macro orchestrator for multi-repo or multi-tranche delivery:
  delegates all code to Hand subagents, verifies their gates, re-plans a live
  backlog, commits per the commit law. Use for /brain, "orchestrate", or work
  spanning repos or many phases. Bare /brain consults (read-only verdict) by
  default.
disable-model-invocation: true
---

# Brain

Macro flight height: intent, tranche boundaries, gates, commits, backlog. Hands (subagents) write all code, because a Brain context full of source and logs loses the cross-repo picture that only it holds. Execution and token hygiene follow [`../dev/reference/plan.md`](../dev/reference/plan.md), plus this multi-repo posture. Vocabulary: [`../CONTEXT.md`](../CONTEXT.md).

Hard limits (everything else is a default with a reason):

- The Brain changes no tracked file on any tree: no edits, no `git merge` / `rebase` / `cherry-pick` / `checkout -- <path>` / `--theirs`, no conflict resolution, no artifact regeneration — "trivial" and generated files included. In `orchestrate` it reads ledgers, gate output, and `git diff --name-only` / `--stat`; allowed writes are `fetch`, `merge --ff-only` on a clean tree, and committing + pushing a Hand's verified diff.
- In `orchestrate`'s verify loop the escape hatch is read-only: when a gate proves too little, read one targeted hunk and note it in the ledger.
- Every user ask after orchestration starts is a tranche → brief a Hand, even for one line. Orchestration starts at the switch to `orchestrate`; the `$dev` row in Pick branch applies only before it.
- A gate that fails twice for environment reasons is its own tranche: brief a Hand to make it runnable, or record the gap as a residual and rely on CI. The Brain does not debug environments.
- No destructive git on any tree.
- Commits follow the **Phase commit** law, per repo; commit bodies, PR prose, and status posts follow [`../communication/reference/outward-text.md`](../communication/reference/outward-text.md).

## Pick branch

- a question, or no goal named (default): `consult`
- a goal named (orchestrate, multi-repo, long-running, many tranches): `orchestrate`
- "should we build X?": stop → `product-owner`
- one surgical change in one repo: stop → `$dev`

## Shared prep

Runs at the switch to `orchestrate`, not on load.

1. **Repos:** per repo record root, default branch, baseline SHA, and a gate copied from `AGENTS.md` / Makefile / CI. No trustworthy gate → halt and name the missing contract.
2. **Ledger:** open or resume the Brain Ledger; after `/compact` or a restart, re-read only it.
3. **Backlog:** admit tranches (features via `product-owner` `gate`; non-trivial tranches via `$dev` `plan`).

## Branch reference

- **`consult`** — read-only default: [`reference/consult.md`](reference/consult.md).
- **`orchestrate`** — brief template, tiers, verify loop, re-plan, ledger: [`reference/orchestrate.md`](reference/orchestrate.md).

## Handoff

- Hands load `$dev` `implement` and return the **Delivery Ledger** (incl. `Discoveries`).
- Per repo, after its last tranche: a fresh-context reviewer Hand runs `review.gil` `findings` on the Ledger and returns Findings + Readiness only. The Brain judges from that, never from the implementer's self-report.
- Land ask + Yes/Conditional → `pull-request` `open`. Repeated pain → `harvest`.

## Completion criteria

- **Tranche green** (Definition of Done): bounds clean; gate exit 0 observed by the Brain; acceptance check passes; no debug/TODO leftovers in the diff; compat decided; committed or deferral recorded; ledger updated.
- **Tranche blocked**: second attempt failed or Hand returned `blocked`; worktree discarded; residual and next step in the ledger; independent tranches continue.
- **Project done**: backlog empty or explicitly cut; every touched repo has reviewer Readiness Yes/Conditional; residuals listed; final ledger summary reported.
