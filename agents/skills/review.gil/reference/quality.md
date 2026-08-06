# Quality

Merge-prep execution: audit touched files and neighbors for duplication, boundary violations, and test gaps; plan stacked commits; execute behavior-preserving boy-scout refactors and targeted tests; verify merge readiness via repo-native gates.

Every pass answers: **what got worse or duplicated while shipping, and what tests prove it still works?**

This execution is **merge-prep**, not feature delivery: post-shipping hardening plus final verification on the current git branch.

**Phase 0 supersedes scope prep** (`SKILL.md`) — do not run `scripts/compare_default_branch.sh` before Phase 0.

## Phase 0 — Repo bootstrap (read-only)

Run before Phase 1. Output a one-line **gate recipe** for Phase 4.

1. Read `AGENTS.md`, `CONTRIBUTING.md`, `.cursor/rules`, and CI workflow files if present.
2. **Discover quality gates** (first match wins):
   - `Makefile` targets (`lint`, `lintfix`, `test`, `ready`, `check`, `ci`)
   - Package manifests: `package.json`, `Cargo.toml`, `pyproject.toml`, `Rakefile`, `go.mod` scripts
   - CI job commands (`.github/workflows/`, etc.)
3. **Discover test stack**: Jest, Vitest, pytest, `cargo test`, `go test`, etc. — and whether coverage is configured.
4. **Diff base**: `git merge-base HEAD main` (fallback: `master`, then `origin/HEAD`).

Example gate recipes: `pnpm lintfix && pnpm test`, `make lintfix && make ready`, `cargo clippy && cargo test`.

Resolve `<srcRoot>`, `<testRoot>`, and globs from repo layout during this bootstrap.

### Gate discovery examples

| Repo signal                            | Typical gate recipe                         |
| -------------------------------------- | ------------------------------------------- |
| `Makefile` with `ready`                | `make lintfix && make ready`                |
| `package.json` `scripts.lint` + `test` | `pnpm lint && pnpm test`                    |
| Rust + clippy in CI                    | `cargo clippy -- -D warnings && cargo test` |
| Python + ruff                          | `ruff check . && pytest`                    |

Prefer version-manager wrappers (`mise exec`, `nix develop`, `direnv`) only when the project documents them.

## Phase 1 — Audit (read-only)

Always load [`legacy.md`](legacy.md) for this execution. Apply its Find table to the diff (and auto-neighbors).

1. **Establish diff scope**: `git diff --stat <base>..HEAD`.
2. **Inventory touched modules** — group by area (feature folder, package, crate, module).
3. **Verify with grep/read** — no speculation. Check project rules from bootstrap, plus generic smells:
   - **SRP**: files exceeding project threshold (from `AGENTS.md` or default 400 LOC)
   - **DRY**: duplicate handlers, hooks, factories, or cache helpers in the same area
   - **Stability**: callback deps on unstable inline config objects; per-item factories in hot paths
   - **Boundaries**: presentation layer importing service/data layer directly (pattern varies by repo)
   - **Correctness hotspots**: project-documented invariants (auth, money, offline sync, etc.)
4. **Test coverage** (only if tooling exists): list 0%-coverage touched files; note test-file ratio in touched areas.
5. **Prioritize findings**: P0 (correctness/sync), P1 (large untested logic), P2 (DRY/KISS).

**Output**: findings table + recommended commit themes (not implementation yet).

Scope expansion follows the **neighbor escalation gate** below.

### Audit commands

```bash
# Diff base (try main, then master, then origin/HEAD)
BASE="$(git merge-base HEAD main 2>/dev/null || git merge-base HEAD master 2>/dev/null || git merge-base HEAD origin/HEAD)"
git diff --stat "${BASE}"..HEAD

# Largest touched source files (adjust globs to stack)
git diff --name-only "${BASE}"..HEAD -- '<srcRoot>/**/*.ts' '<srcRoot>/**/*.tsx' \
  | xargs wc -l 2>/dev/null | sort -rn | head -20

# Boundary violations (adjust import pattern to repo conventions)
rg "from ['\"].*\\.(service|repository|dao)['\"]" <presentationGlob> --glob '*.{ts,tsx,py,rb}'

# Suppression drift
rg "eslint-disable|# noqa|allow\\(" <srcRoot> --glob '!**/__tests__/**' '!**/test/**'

# Dead compat markers (see reference/legacy.md)
rg "@deprecated|DEPRECATED|Obsolete|obsolete|backward compat|during refactor" <srcRoot>

# Coverage (only when configured — use discovered test command)
# npm/pnpm: npm run test:coverage
# cargo: cargo llvm-cov or tarpaulin per project docs
```

### Generic smell categories

| Category             | What to look for                                                                     |
| -------------------- | ------------------------------------------------------------------------------------ |
| God file             | Single module > project LOC threshold doing orchestration + logic + I/O              |
| DRY                  | Third+ copy of same mutation/queue/cache pattern in one area                         |
| Stability            | Inline config objects in hook/callback dependency arrays                             |
| Layer breach         | UI/views importing service or persistence layer directly                             |
| Hot path             | Per-row data fetch, inline object creation in list renderers                         |
| Untested pure logic  | Helpers with branching and no unit tests                                             |
| Legacy / dead compat | Dual public names, superseded hydrate, deprecated markers — [`legacy.md`](legacy.md) |

Honor additional invariants documented in `AGENTS.md` (money parsing, auth, offline sync, etc.).

### Neighbor escalation gate

**Default in-scope**: files in `git diff --name-only <base>..HEAD`.

**Auto-neighbor** (no ask): include without escalation when a file:

- Directly imports a touched module
- Duplicates the same pattern in the same area (e.g. third queue cache, fourth mutation hook)
- Is one import hop away as orchestrator (sync coordinator ↔ queue applier)

**Escalate before including**: use AskQuestion or explicit user confirm before expanding scope to:

- Cross-module service decomposition (large facade or god service)
- Files more than two import hops from the diff
- New abstractions not listed in audit findings

Do not expand into unrelated areas.

## Phase 2 — Plan

Use CreatePlan unless user says "just do it".

Plan must include:

- **Commit stack** (dependency order; single commit when diff is small or user says "just do it")
- **Per commit**: files, boy-scout items, targeted tests (name test files)
- **Explicit out of scope** (defer list to prevent creep)
- **Success criteria**: gate recipe green; coverage threshold changes only in a separate final `chore(test)` commit

KISS rules for plans:

- Prefer **extract pure utils → unit test → thin consumer** over new abstractions
- One factory per repeated pattern (mutations, queues, cache helpers)
- Follow [`legacy.md`](legacy.md): under `quality`, delete dead compat; invent no shims (stop only if user required backward compatibility)
- Apply project agent rules and stack-specific skills when bootstrap detects them

### Commit stack ordering

1. Extract pure utils + tests
2. Refactor consumers to use utils
3. Unify factories (mutations, queues, caches)
4. Slim UI/models
5. Test hygiene + gate recipe
6. **`chore(test): raise coverage thresholds + verify`** — last, separate from refactors (skip if no coverage tooling)

### Commit message template

```
refactor(scope): one-line why

Optional body: what test locks the behavior.
```

Types: `refactor`, `test`, `chore` — avoid `feat` in quality loops.

### Test targeting rules

| Layer                                       | Test type                                           |
| ------------------------------------------- | --------------------------------------------------- |
| Pure utils (`buildX`, `applyY`, `resolveZ`) | Unit, no mocks                                      |
| Stateful hooks / use-cases                  | Framework test utils + mocked dependencies          |
| Read/API paths                              | Integration tests with HTTP/DB fixtures per project |
| Screens / pages                             | Mock providers; honor project bans on heavy forms   |

Read `AGENTS.md` and existing test patterns before adding screen or integration tests. Do not mount surfaces the project explicitly bans from golden-path tests.

## Phase 3 — Execute

Default: **stacked commits** on current feature branch when audit yields ≥2 independent themes.

Per commit:

1. Smallest behavior-preserving refactor first (extract utils)
2. Tests that lock behavior before deleting duplication
3. Run lintfix equivalent on touched paths before commit
4. HEREDOC commit message: `type(scope): why` (one sentence why)

**Failure policy**: if gates fail on commit _k_ of _N_, fix forward on the branch. When the fix belongs to an earlier stack commit, use `git commit --fixup=<target-sha>` (user may `git rebase -i --autosquash <base>` later).

**Fixup commits** (mid-stack failure):

```bash
git commit --fixup=<earlier-commit-sha>
# later: git rebase -i --autosquash <base>
```

Otherwise fix forward with a normal commit on the branch.

**Delegation**: for stacks of ≥3 commits, prefer a background `Task` subagent with the full commit list and branch name; parent verifies final gates.

**Coverage thresholds**: raise or adjust coverage config only in a dedicated final `chore(test): …` commit after all refactor commits are green — never bundled with refactor commits. Skip if repo has no coverage tooling.

**Do not**:

- Expand into unrelated areas without escalation gate
- Lower coverage thresholds without user approval
- Mount heavy integration surfaces in tests when project docs ban it (read from `AGENTS.md`)
- Add coverage for dev/static screens unless asked

## Phase 4 — Verify

Run the discovered **gate recipe** from Phase 0.

If coverage thresholds fail: add **targeted** tests on the failing path in a separate `chore(test)` commit — do not lower thresholds without user approval.

## After verify

If P0/P1 findings remain, **re-invoke** this skill on the branch with branch **`quality`**. Do not run a baked-in second pass in the same session.

## Related skills

- `architecture` **`refactor-types`** / **`deep-modules`** / **`refactor-boundaries`** — dual type homes or layer inversion after [`legacy.md`](legacy.md) handoff; quality may _follow_ that craft
- `css-cleaner` — CSS/token DRY only; defer CSS-wide cleanup there
- Stack-specific skills (e.g. React Native perf) — consult when bootstrap detects that stack
