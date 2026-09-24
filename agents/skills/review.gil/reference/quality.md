# Quality

Merge-prep on the current branch (not feature delivery): what got worse or duplicated while shipping, and what tests prove it still works? Phase 0 supersedes `SKILL.md` Shared prep.

## Phase 0 — Bootstrap (read-only)

- Read `AGENTS.md`, `CONTRIBUTING.md`, `.cursor/rules`, CI workflows.
- Gate recipe (one line, first match wins): `Makefile` (`lint`/`lintfix`/`test`/`ready`/`check`/`ci`) → manifest scripts → CI job commands. E.g. `make lintfix && make ready`, `pnpm lint && pnpm test`, `cargo clippy -- -D warnings && cargo test`. Version-manager wrappers only when documented.
- Test stack + whether coverage is configured; resolve `<srcRoot>`, `<testRoot>`, globs.
- Base: `BASE="$(git merge-base HEAD main 2>/dev/null || git merge-base HEAD master 2>/dev/null || git merge-base HEAD origin/HEAD)"`.

## Phase 1 — Audit (read-only)

Apply [`legacy.md`](legacy.md) Find table to the diff + auto-neighbors (always). Verify every smell by grep/read:

| Smell          | Look for                                                                                 |
| -------------- | ---------------------------------------------------------------------------------------- |
| God file       | Over project LOC threshold (`AGENTS.md`, else 400) mixing orchestration + logic + I/O    |
| DRY            | Third+ copy of a handler/hook/factory/queue/cache pattern in one area                    |
| Stability      | Unstable inline config in callback deps; per-item factories in hot paths                 |
| Layer breach   | Presentation importing service/data layer                                                |
| Hot path       | Per-row fetch, inline object creation in list renderers                                  |
| Untested logic | Branching helpers with no unit tests; 0%-coverage touched files (only if tooling exists) |
| Legacy         | Per [`legacy.md`](legacy.md)                                                             |
| Invariants     | Project-documented ones (auth, money, offline sync…)                                     |

Recipes: `git diff --stat "$BASE"..HEAD`; `rg "eslint-disable|# noqa|allow\\(" <srcRoot>`; `rg "@deprecated|DEPRECATED|Obsolete|obsolete|backward compat|during refactor" <srcRoot>`.

Output: findings table prioritized **P0** correctness/sync, **P1** large untested logic, **P2** DRY/KISS + recommended commit themes.

**Scope gate:** in-scope = `git diff --name-only "$BASE"..HEAD`. Auto-include files that import a touched module, duplicate the same pattern in the area, or are one hop away as orchestrator. Ask before cross-module service decomposition, files >2 import hops away, or abstractions not in the audit. Nothing unrelated.

## Phase 2 — Plan

CreatePlan unless the user says "just do it". Include: commit stack in dependency order (single commit if small), per-commit files + boy-scout items + named test files, explicit out-of-scope list, success = gate recipe green.

- Order: extract pure utils + tests → refactor consumers → unify factories → slim UI/models → test hygiene → last, separate `chore(test): raise coverage thresholds + verify` (skip without coverage tooling).
- Prefer extract pure util → unit test → thin consumer over new abstractions; one factory per repeated pattern.
- Dead compat: delete, no shims (stop only if the user required backward compatibility).
- Tests: pure utils → unit, no mocks; stateful hooks/use-cases → framework utils + mocked deps; read/API → integration with project fixtures; screens → mock providers, honor `AGENTS.md` bans on heavy surfaces.
- Commits: `refactor` / `test` / `chore` only (no `feat`); `type(scope): why`, body names the test locking behavior.

## Phase 3 — Execute

Stacked commits when ≥2 independent themes. Per commit: smallest behavior-preserving refactor → tests lock behavior before removing duplication → lintfix touched paths → commit (HEREDOC message).

- Gate failure mid-stack: fix forward; if it belongs to an earlier commit, `git commit --fixup=<sha>` (user may `git rebase -i --autosquash <base>` later).
- ≥3 commits: prefer a background `Task` subagent with the commit list + branch; parent verifies final gates.
- Never lower coverage thresholds without approval; threshold changes only in the final `chore(test)` commit; no coverage for dev/static screens unless asked.

## Phase 4 — Verify

Run the gate recipe. Coverage failure → targeted tests in a separate `chore(test)` commit. P0/P1 remaining → list for re-invoking `review.gil` `quality`; no second pass in-session.

## Related

- Dual type homes / layer inversion: name `architecture` `refactor-types` / `deep-modules` / `refactor-boundaries`; quality may follow that craft.
- CSS/token DRY → `css-cleaner`. Stack-specific skills when bootstrap detects the stack.
