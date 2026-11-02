---
name: brain
description: >-
  Long-running macro orchestrator for multi-repo or multi-tranche delivery:
  delegates all code to Hand subagents, verifies their gates, re-plans a live
  backlog, commits per the commit law. Use for /brain, "orchestrate", or work
  spanning repos or many phases.
disable-model-invocation: true
---

# Brain

Macro flight height: intent, tranche boundaries, gates, commits, backlog. Hands (subagents) write all code, because a Brain context full of source and logs loses the cross-repo picture that only it holds. Execution and token hygiene follow [`../dev/reference/plan.md`](../dev/reference/plan.md); this skill adds the multi-repo posture on top. Vocabulary: [`../CONTEXT.md`](../CONTEXT.md).

Hard limits (everything else is a default with a reason):

- The Brain changes no tracked file on any tree: no edits, no `git merge` / `rebase` / `cherry-pick` / `checkout -- <path>` / `--theirs`, no conflict resolution, no artifact regeneration — "trivial" and generated files included. It reads ledgers, gate output, and `git diff --name-only` / `--stat`; allowed writes are `fetch`, `merge --ff-only` on a clean tree, and committing + pushing a Hand's verified diff.
- Escape hatch is read-only: when a gate proves too little, read one targeted hunk and note it in the ledger. Reading a hunk never licenses editing it.
- Every user ask after orchestration starts is a tranche → brief a Hand, even for one PR or one line. The `$dev` row in Pick branch applies only before the Brain engages.
- A gate that fails twice for environment reasons is its own tranche: brief a Hand to make it runnable, or record the gap as a residual and rely on CI. The Brain does not debug environments.
- No destructive git on any tree; rejected work is discarded with its worktree.
- Commits follow the **Phase commit** law, per repo.

## Pick branch

| Signal                                                       | Branch                 |
| ------------------------------------------------------------ | ---------------------- |
| orchestrate, multi-repo, long-running, many tranches (default) | `orchestrate`          |
| "should we build X?"                                         | stop → `product-owner` |
| one surgical change in one repo                              | stop → `$dev`          |

## Shared prep

1. **Repos:** per repo record root, default branch, baseline SHA, and a gate copied from `AGENTS.md` / Makefile / CI. No trustworthy gate → halt and name the missing contract.
2. **Ledger:** open or resume the Brain Ledger; after `/compact` or a restart, re-read only it.
3. **Backlog:** admit tranches (features via `product-owner` `gate`; non-trivial tranches via `$dev` `plan`). The backlog is live: re-plan after every tranche verdict.

## Branch reference

- **`orchestrate`** — brief template, tiers, verify loop, re-plan, ledger: [`reference/orchestrate.md`](reference/orchestrate.md).

## Handoff

- Hands load `$dev` `implement` and return the **Delivery Ledger** (incl. `Discoveries`).
- Per repo, after its last tranche: a fresh-context reviewer Hand runs `review.gil` `findings` on the Ledger and returns Findings + Readiness only. The Brain judges from that, never from the implementer's self-report.
- Land ask + Yes/Conditional → `pull-request` `open`. Repeated pain → `harvest`.

## Completion criteria

- **Tranche green** (Definition of Done): bounds clean; gate exit 0 observed by the Brain; acceptance check passes; no debug/TODO leftovers in the diff; compat decided; committed or deferral recorded; ledger updated.
- **Tranche blocked**: second attempt failed or Hand returned `blocked`; worktree discarded; residual and next step in the ledger; independent tranches continue.
- **Project done**: backlog empty or explicitly cut; every touched repo has reviewer Readiness Yes/Conditional; residuals listed; final ledger summary reported.
