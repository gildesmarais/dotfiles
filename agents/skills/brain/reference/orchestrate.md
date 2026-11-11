# Orchestrate

`brain` `orchestrate`: brief, tiers, verify loop, re-plan, ledger. Optimize wall-clock to shippable without lowering the Definition of Done.

## Hand brief

Fixed part first, task fields last, so spawns reuse the cached prefix. Worktrees do not start on the target branch, hence Setup; parallel Hands get disjoint whitelists.

```text
Read ~/.agents/skills/dev/SKILL.md, follow branch `implement`. You are a Hand:
one task, then return. Time matters: narrowest check per iteration, full gate
once at the end; smallest correct change; improvements → Discoveries.
At the timebox or a wrong assumption, return `blocked` or `partial` with
evidence. Run Setup; edit only whitelisted paths; commit on your branch per the
commit law; no push, merge, or rebase. Full logs to scratch. Return the Delivery
Ledger (<=25 lines) with branch + head SHA; unevidenced claims count as undone.

Task: <id> — <imperative intent>
Repo: <root>
Base: <target branch>@<sha> — Setup: `git switch -c brain/<id> <sha>`
Whitelist: <paths>
Read-only context: <paths or none>
Acceptance: <observable check; behavior change → test failing before, passing after>
Gate: <repo-native command>
Timebox: <turns or minutes>
```

Update variant (smallest tier; replaces task fields):

```text
Task: <PR | brain/<id>> — bring onto <branch>@<sha>. PR: merge origin/main, no
rebase/force; you MAY commit the merge. Unpushed Hand branch: rebase onto <sha>.
Resolve keeping both sides; generated swagger → take main's copy, regenerate.
Semantic conflict → abort, return blocked with hunks.
Return: new head SHA, conflicted files + resolution, narrow check exit codes.
```

## Tiers

`model` + `effort` per spawn: mechanical (rename, lint, format, config) → smallest, low; one-module change → mid, medium; design, cross-boundary, reviewer → strongest, high. Choice rule: `plan.md` Token hygiene.

## Verify loop

**Expected HEAD** per repo: last landed SHA, else Base. Re-check it (`git rev-parse`) before each land and wave (independent tranches in one message; brief the next while one verifies).

1. **Bounds:** branch descends from Base, worktree clean, `git diff --name-only <base> <branch>` ⊆ whitelist; `git log <base>..<branch>` holds only the Hand's commits, each message matching its diff, no conflict markers.
2. **Gate:** the Brain runs gate + acceptance on that branch; exit 0 observed.
3. **Land:** target tree clean and HEAD == expected → `git merge --ff-only <branch>`; update expected. Else land nothing; never patch, stage, commit, or resolve conflicts:
   - dirty tree or moved HEAD = another writer → stop, ask the user (wait, or target an integration branch). On resume, re-plan tranches whose whitelist overlaps `git diff --name-only <old> <new>`.
   - non-ff → Update variant to that Hand; re-verify from 1.
4. **Reject:** discard worktree; diagnose (failure, cause, brief change); retry once revised or a tier higher.

## Re-plan

After every verdict, fold `Discoveries` into Backlog; merge, split, reorder, drop, or add tranches, one-line reason each. Unknowns first, cosmetic last; cut scope before stretching time (cuts become residuals). Product scope → `product-owner` `gate`.

## Brain Ledger

`~/.local/state/brain/<goal-slug>.md` (outside git), or `<repo>/.agents/brain-ledger.md` on request. Dated; rewrite after every verdict.

```markdown
Goal: <one line>
Repos: <root> · <target branch> · <expected HEAD> · <gate>
| Tranche | Repo | Status | SHA | Date | Residual |
Backlog: <ordered ids; last re-plan reason>
Decisions: <date: decision, why>
```
