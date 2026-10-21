# Quality

Merge-prep on the current branch (not feature delivery). Phase 0 supersedes `SKILL.md` Shared prep. Flight-height → `dev/reference/surgical-laws.md`. Legacy Find rows → [`legacy.md`](legacy.md).

## Phase 0 — Bootstrap (read-only)

- Read `AGENTS.md`, `CONTRIBUTING.md`, `.cursor/rules`, CI workflows.
- Gate recipe (first match wins): `Makefile` (`lint`/`lintfix`/`test`/`ready`/`check`/`ci`) → manifest scripts → CI job commands. Version-manager wrappers only when documented.
- Test stack + whether coverage is configured; resolve `<srcRoot>`, `<testRoot>`, globs.
- Base: `BASE="$(git merge-base HEAD main 2>/dev/null || git merge-base HEAD master 2>/dev/null || git merge-base HEAD origin/HEAD)"`.

## Phase 1 — Audit (read-only)

Apply [`legacy.md`](legacy.md) Find table (always). Verify smells by grep/read:

| Smell | Look for |
| ----- | -------- |
| God file | Over LOC threshold (`AGENTS.md`, else 400) mixing orchestration + logic + I/O |
| DRY | Third+ copy of a handler/hook/factory/queue/cache pattern |
| Stability | Unstable inline config in callback deps; per-item factories in hot paths |
| Layer breach | Presentation importing service/data layer |
| Hot path | Per-row fetch, inline object creation in list renderers |
| Untested logic | Branching helpers with no unit tests; 0%-coverage touched files (if tooling exists) |
| Legacy | Per [`legacy.md`](legacy.md) |
| Invariants | Project-documented ones |

Recipes: `git diff --stat "$BASE"..HEAD`; `rg "eslint-disable|# noqa|allow\\(" <srcRoot>`; `rg "@deprecated|DEPRECATED|Obsolete|obsolete|backward compat|during refactor" <srcRoot>`.

Output: findings table **P0** correctness/sync, **P1** large untested logic, **P2** DRY/KISS + commit themes.

**Scope gate:** in-scope = `git diff --name-only "$BASE"..HEAD`. Auto-include importers / same-pattern / one-hop orchestrators. Ask before cross-module decomposition, >2 hops, or abstractions not in the audit.

## Phase 2 — Plan

CreatePlan unless "just do it". Commit stack in dependency order; per-commit files + boy-scout items + named tests; out-of-scope list; success = gate green.

- Order: extract pure utils + tests → refactor consumers → unify factories → slim UI/models → test hygiene → last `chore(test): raise coverage thresholds` (skip without coverage tooling).
- Craft recipes → [`../../dev/reference/surgical-laws.md`](../../dev/reference/surgical-laws.md) (+ lang packs).
- Dead compat: delete, no shims (stop only if user required backward compatibility).
- Commits: `refactor` / `test` / `chore` only (no `feat`); `type(scope): why`, body names the locking test.

## Phase 3 — Execute

Stacked commits when ≥2 independent themes. Per commit: smallest behavior-preserving refactor → tests lock behavior → lintfix touched paths → commit (HEREDOC).

- Gate failure mid-stack: fix forward; earlier-commit belonging → `git commit --fixup=<sha>`.
- ≥3 commits: prefer background `Task` subagent; parent verifies final gates.
- Never lower coverage thresholds without approval; threshold changes only in final `chore(test)`.

## Phase 4 — Verify

Run the gate recipe. Coverage failure → targeted tests in separate `chore(test)`. P0/P1 remaining → list for re-invoke; no second pass in-session.

## Related

Structural dual homes / layer inversion → name `architecture` branches; CSS/token DRY → `css-cleaner`.
