# Orchestrate

`brain` `orchestrate`: brief, tiers, verify loop, re-plan, ledger. Time matters: optimize wall-clock to a shippable state without lowering the Definition of Done.

## Hand brief

Fixed part first, task fields last, so repeated spawns reuse the cached prefix. Spawn with worktree isolation; parallel Hands get disjoint whitelists.

```text
Load `$dev`, branch `implement`. You are a Hand: one task, then return.
Time matters: run the narrowest check each iteration and the full gate once at
the end; make the smallest correct change; put improvements you notice under
Discoveries instead of editing them; at the timebox or on a wrong assumption,
stop and return `blocked` or `partial` with evidence rather than guessing.
Edit only whitelisted paths. Do not commit. Full logs go to a scratch file.
Return the Delivery Ledger in <=25 lines; unknowns are allowed, unevidenced
claims count as not done.

Task: <id> — <imperative intent>
Repo: <root> @ <baseline>
Whitelist: <paths>
Read-only context: <paths or none>
Acceptance: <observable check; behavior change → test failing before, passing after>
Gate: <repo-native command>
Timebox: <turns or minutes>
```

## Tiers

Set `model` and `effort` per spawn; the strongest tier is where defects get caught, the small tier is where cost is saved.

| Work                                           | Model     | Effort |
| ---------------------------------------------- | --------- | ------ |
| Mechanical: rename, lint fix, format, config   | smallest  | low    |
| Bounded change inside one module               | mid       | medium |
| Design, cross-boundary, reviewer Hand          | strongest | high   |

## Verify loop

1. **Bounds:** `git diff --name-only <baseline>` in the Hand's worktree ⊆ whitelist.
2. **Gate:** the Brain runs the gate and acceptance check itself; exit 0 observed.
3. **Land:** merge the worktree branch; commit per the commit law; record SHA.
4. **Reject:** discard the worktree; write a diagnosis (what failed, likely cause, what the brief changes); retry once with the revised brief, or a higher tier. Second failure → tranche blocked.

Pipeline: while verifying tranche N, brief the next tranche that does not depend on it. Independent tranches go out in one message.

## Re-plan

After every verdict, fold `Discoveries` into the Backlog, then merge, split, reorder, drop, or add tranches with a one-line reason. Order by unblocking value and risk: unknowns first, cosmetic last. Cut scope before stretching time; cuts become residuals. Product-scope changes go through `product-owner` `gate`; the rest is the Brain's call.

## Brain Ledger

Scratch file by default; `<repo>/.agents/brain-ledger.md` when the user wants it kept. Rewrite it after every verdict; it is the only state re-read on resume.

```markdown
Goal: <one line>
Repos: <root> · <default> · <baseline> · <gate>
| Tranche | Repo | Status | SHA | Residual |
Backlog: <ordered ids + one-line reason for last re-plan>
Decisions: <date — decision — why>
```
