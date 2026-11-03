# Skills Store Vocabulary

Cross-skill terms only; skill-local vocabulary lives in the owning skill. Handoffs live in each skill's `## Handoff`.

**Branch** (skill-internal): verb-path through a skill from the prompt. Not a git branch.
**AGENTS.md load**: hosts load `AGENTS.md` / `CLAUDE.md` from workspace root upward; nearest wins; cite a line only — never re-read or paste.
**Handoff load**: load the named skill; if `disable-model-invocation` blocks, read its `SKILL.md` or name its command to the user, then continue.
**Outward text**: published prose (PR, commit, comment, release, chat) — hygiene in `dev/reference/outward-text.md`, always-on.
**Security cue** / **Observability cue**: sensitive surfaces → `review.gil` `security` lens; APM/trace/error/log links → matching observability tool. No vendor recipes in routers.
**Ops Ledger**: service-ops evidence DTO from `ops-chore`; admitted items seed `$dev` `plan`.
**Phase commit**: `$dev` procedure — `dev/reference/plan.md`.
**Rollout Skew**: own plans; skip single-clock. Skews: deploy, client, cohort. Phases: Bridge → Adopt → Cutover. Trigger: min version or metric ≈0; else Residual.
**Delivery Ledger**: handoff DTO from `$dev` → `review.gil` → `pull-request` / `harvest`. Fields:
- `Classification / Branches`: `surgical` | `design` + active branches
- `Target Files`: paths matchable to `git diff --name-only <task_baseline>`
- `Verification`: command + exit 0 observed
- `Phase Commits`: hashes & rationale (or deferral on default branch)
- `Active Lenses`: `security`, `tests`, `perf`, `legacy`
- `Readiness`: `Yes` | `No` | `Conditional` | `Skipped (reason)`
- `Residuals / Debt`: deferred items or N/A
- `Rollout` (optional): what ships now vs removal owed
- `Discoveries` (optional): follow-ups / reorder / invalidated assumptions; `brain` folds in
