---
name: orchestrator
description: >-
  Sequential delivery orchestrator. Discovers next undone admitted tranche
  from repo roadmap, spawns $dev worker, gates on validation, updates
  roadmap, advances. Use for /orchestrator, "run the roadmap",
  "deliver tranches", or autonomous sequential delivery of admitted scope.
---

# Orchestrator

Delivers admitted tranches sequentially from repo docs.
Never mutates application code — workers load `$dev`.

## Pick branch

Single branch. Default: **`run`** — discover → dispatch → gate → commit → advance.

| Signal                                  | Route                    |
| --------------------------------------- | ------------------------ |
| deliver tranches, run roadmap, next one | `run`                    |
| "should we build X?"                    | stop → `product-owner`   |
| compile prompt into tasks               | stop → `prompt-compiler` |
| implement one thing (no roadmap)        | stop → `$dev`            |

## Shared prep

1. **Repo law** — read `AGENTS.md` for roadmap path, plan naming, gate, status vocab, commit branch.
2. **Roadmap** — `AGENTS.md` directive → `docs/roadmap.md` → `ROADMAP.md` → halt. Parse admitted tranches (fallback vocab: `Build Now` = undone, `Have` = done).
3. **Plan doc** — per tranche: `AGENTS.md` → roadmap link → pattern `docs/NNN-*.md` → halt. Never invent.
4. **Gate** — `AGENTS.md` → `Makefile` targets → plan "Verification" section → fallback `make lintfix && make lint && make test`.
5. **Circuit-breaker consent** — `AGENTS.md` `orchestrator.circuit_breaker: approved` → proceed. Otherwise ask once before first dispatch. Halt until approved.
6. **Default-branch law** — on main/master, follow `$dev` phase-commit law: ask user before committing.
7. **Admission** — skip unadmitted tranches (report each). Never run `product-owner` mid-loop.
8. **No destructive git** — no force-push, no hard reset (except circuit break with consent), never push.
9. **Tooling & environment context** — identify runtime requirements (mise/asdf shims, sandbox bypass needs, git signing flags) to propagate to workers.

## Branch reference

- **`run`** → [`reference/run.md`](reference/run.md)

## Handoff

- **Per tranche:** fresh sub-agent loading `$dev` `implement` with plan path and known tooling/env hints. Worker commits per `$dev` phase-commit. Worker skips per-task Assure (orchestrated carve-out). Worker must forward-doc and report back with a concise insight summary.
- **Post-worker:** orchestrator ingests concise summary (commit SHAs, insights, resolved pitfalls; zero raw log bloat) and re-runs gate (zero worker trust). Pass → update roadmap status → conventional commit `docs(roadmap): mark tranche <NNN> done` → advance.
- **Full completion:** all green → `review.gil` **`findings`** (+ **`security`** when cues matched). Report after review returns. Land request → `pull-request` **`open`**.
- **Circuit break:** `max_retries` (default 2) gate failures → `git reset --hard <last_green_commit>` → halt.

## Completion criteria

| Path            | Done when                                                              |
| --------------- | ---------------------------------------------------------------------- |
| tranche N green | Worker returned; orchestrator gate exit 0; roadmap status updated;     |
|                 | roadmap-update conventional commit authored; auto-advance to next      |
| circuit break   | Reset to last green tranche commit; halt; failure reported             |
| full completion | All admitted tranches green; post-delivery `review.gil` **`findings`** |
|                 | completed before delivery report                                       |
