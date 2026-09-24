# Skills

Personal product + engineering skill store: domain routers (Build entry: `dev`), Solution craft (`architecture`), thin language adapters/overlays. Vocabulary: [`CONTEXT.md`](CONTEXT.md).

## Install

```sh
npx skills add gildesmarais/dotfiles/agents/skills -g -a cursor -a codex -y
```

Requires Node.js and GitHub access. Verify: `npx skills list -g`. Browse: `--list`. Project-level: omit `-g` in the target repo. Specific skills: `--skill <name>` (repeatable). This machine: `rcup` — see [Operate the store](#operate-the-store). CLI: [vercel-labs/skills](https://github.com/vercel-labs/skills).

## Domain map

| Domain       | Job                             | Skill(s)                                                                                                                                                                                                                  | Primary branches                                                                                                                                      |
| ------------ | ------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Intent**   | Fuzzy need → actionable work    | [`triage`](triage/), [`prompt-compiler`](prompt-compiler/), [`jira-ticket`](jira-ticket/), [`orchestrator`](orchestrator/), [`pr-sweep`](pr-sweep/)                                                                       | `triage` `intake` (+ playbooks); `prompt-compiler` `compile`; `orchestrator` `run`; `pr-sweep` `report`                                               |
| **Product**  | Admit/defer scope               | [`product-owner`](product-owner/)                                                                                                                                                                                         | `gate` (default); `story-slice`; `rebaseline`; `groom`; stubs: `prioritize`, `experiment`                                                             |
| **Solution** | How the system should work      | [`architecture`](architecture/); [`docs`](docs/) `architecture` (verify-only) · `evidence`; `dev` `plan`                                                                                                                  | `philosophy` \| `deep-modules` \| `refactor-types` \| `refactor-boundaries` \| `performance` \| `design-patterns`; survey: `structure-survey`         |
| **Build**    | Change the codebase             | [`dev`](dev/); adapters [`ruby-dev`](ruby-dev/), [`rust-dev`](rust-dev/), [`swift-dev`](swift-dev/), [`typescript-dev`](typescript-dev/); overlays [`ruby-on-rails-dev`](ruby-on-rails-dev/), [`swiftui-dev`](swiftui-dev/) | `plan` \| `implement`; classify: surgical \| design \| review-hand-off                                                                                |
| **Assure**   | Safe to merge?                  | [`review.gil`](review.gil/)                                                                                                                                                                                               | `findings`, `publish`, `quality` (lenses: tests, perf, security, legacy)                                                                              |
| **Ship**     | Land on mainline                | [`pull-request`](pull-request/), [`dependabot`](dependabot/), [`release`](release/)                                                                                                                                       | PR: open, slice, retitle, comment, reply, resolve, fix-ci, conflicts (+ unblock chain); Dependabot: configure \| triage; release: `notes`             |
| **Explain**  | Humans understand state         | [`communication`](communication/), [`docs`](docs/)                                                                                                                                                                        | see skill branches                                                                                                                                    |
| **Decide**   | Stress-test choices             | `grilling` (third-party); `product-owner` Forced Challenge                                                                                                                                                                | —                                                                                                                                                     |
| **Harvest**  | Learning & debt loop            | [`harvest`](harvest/)                                                                                                                                                                                                     | `distill` (default); `debt`                                                                                                                           |
| **Personal** | Tool operators                  | [`omnifocus`](omnifocus/)                                                                                                                                                                                                 | —                                                                                                                                                     |

## Optional packs (not OS SoT)

Third-party; not in the store install.

```sh
npx skills add https://github.com/mattpocock/skills --skill grilling -g -a cursor -a codex -y && \
npx skills add https://github.com/twostraws/swiftui-agent-skill --skill swiftui-pro -g -a cursor -a codex -y && \
npx skills add https://github.com/twostraws/swift-testing-agent-skill --skill swift-testing-pro -g -a cursor -a codex -y && \
npx skills add https://github.com/arjitj2/swiftui-design-principles --skill swiftui-design-principles -g -a cursor -a codex -y
```

| Pack                        | Role                                                      |
| --------------------------- | --------------------------------------------------------- |
| `grilling`                  | Decide stress-test                                        |
| `docs-sync`                 | Clean Arch domain doc sync                                |
| `swiftui-pro`               | SwiftUI review depth — compose via `$dev` + `swiftui-dev` |
| `swift-testing-pro`         | Swift Testing depth — compose via `$dev` + `swift-dev`    |
| `swiftui-design-principles` | Spacing/typography/materials — via `$dev` + `swiftui-dev` |

More: [skills.sh](https://skills.sh/), [Swift-Agent-Skills](https://github.com/twostraws/Swift-Agent-Skills).

## Compose / handoffs

Build path: `$dev` ⇄ `architecture` → `review.gil` → `pull-request`. `$dev` is the only Build entry; `architecture` is craft inside Build. `README.md` is not installed by `rcup` — runtime handoff contracts live in skills and [`CONTEXT.md`](CONTEXT.md); these rules are the authoring index.

One-way rules:

1. **Product before non-trivial scope** — feature / `jira-ticket` asks → `product-owner` `gate`; continue only on **Build Now**. Multi-slice / UX-mandated AC → `story-slice` → `$dev` `plan`; one-slice asks → `$dev`. Skip for pure bug fix, refactor, infra. Incident/observability without Jira or Intent DTO → `triage` first.
2. **Craft ≠ product** — `architecture` / `dev` / `*-dev` / `review.gil` never answer "should we build X?".
3. **Build entry is `$dev`** — classify / route / phase commits live there; [`architecture/reference/axioms.md`](architecture/reference/axioms.md) rides along on every `implement`; `architecture` branches load when `design` is earned. Multi-load `{lang}-dev` from touched-file evidence.
4. **Plans → `$dev` `plan`** ([`dev/reference/plan-pipeline.md`](dev/reference/plan-pipeline.md)), including Cursor plan mode. `prompt-compiler` `compile` emits only `.agents/compile/<slug>.yaml`; `$dev` `plan` writes `.agents/plan/<slug>.md`; `orchestrator` `run` alone dispatches phases to `$dev` `implement`.
5. **Phase CC → merge → notes** — phases commit via `$dev` (Build) / `architecture` (Solution) Shared prep; `release` `notes` consumes merged history; `pull-request` `open` applies the format only to a still-dirty tree. Format: [`CONTEXT.md`](CONTEXT.md) § Phase commit.
6. **Assure → Ship** — `findings` never posts; `publish` lives in `review.gil`; verified-ledger posting lives in `pull-request` `comment` — never reverse. Every Build delivery emits the Delivery Ledger and runs `review.gil` `findings` (procedure: `dev/SKILL.md` Handoff). Land ask + readiness Yes/Conditional → `pull-request` `open`.
7. **Explain → docs** — `communication` → `docs` `editor` for README/runbook artifacts; never reverse.
8. **Overlays via `$dev`** — `ruby-on-rails-dev` with `ruby-dev`; `swiftui-dev` with `swift-dev`; depth packs stay on pack Compose routes.
9. **Decide** — `grilling` stress-tests; scope doctrine stays with `product-owner`.
10. **API truth** — Dash and/or Context7 soft deps; ladder and warn-once live in `$dev` Shared prep.
11. **Observability cue** — matching MCP when APM/error/log links appear; no vendor SoT.
12. **Sweep never fixes** — `pr-sweep` rows route to `pull-request` / `dependabot` / `review.gil`.
13. **Unblock chain** — `pull-request`: conflicts → resolve → fix-ci, live state each pass; never approve/merge.
14. **Harvest loop** — `review.gil` / `pull-request` → `harvest` (`distill` → project rules or store references; `debt` → `<project>/.agents/debt-ledger.md` → `product-owner` Health Capacity Budget → `orchestrator` / `$dev`).

## Authoring laws

- **One router per domain**; branches are verb-paths with progressive load.
- **Freeze the router** — harvest via staging → sparse-promote into `reference/<branch>.md`; edit `SKILL.md` only when the contract is wrong.
- **Thin `*-dev`** — craft stays in `architecture`; classify / validation / phase commits stay in `$dev`; overlays are deltas only.
- **Proliferation guard** — new top-level skill only if it cannot be a branch of an existing router (`refactor-<concern>` under `architecture`, never bare `refactor` or a parallel product skill). Runtime route table stays in `dev/SKILL.md`.
- **Zero backward compat** — delete superseded aliases, old execution names, and dual shims on cutover.
- **Tokens are the currency** — single ownership, bounded Markdown DTOs for handoffs, no intermediate prompt layers.

Router shape: `## Pick branch` → `## Shared prep` → `## Branch reference` → `## Handoff` → `## Completion criteria`; relative `reference/*.md` links; unnumbered `##` headers. Spec: [agentskills.io](https://agentskills.io/).

## Operate the store

Git-tracked `agents/skills/<name>/` is the source of truth. `rcup` installs file-level links into `~/.agents/skills/<name>/`. Keep `SYMLINK_DIRS` unset for `agents` / `agents/skills` so `~/.agents/skills` can hold both `rcup` links and third-party `npx skills` dirs. After clone/pull, promote/rename, or `backfill`, run `rcup` (or topgrade `RCM: rcup`).

`rcup` installs `CONTEXT.md` to `~/.agents/skills/CONTEXT.md` so `../CONTEXT.md` citations resolve; keep `README.md` in `rcrc` `EXCLUDES`; never exclude `CONTEXT.md`. External `npx skills` installs may lack `CONTEXT.md` — skills then fall back to [conventionalcommits.org](https://www.conventionalcommits.org/) v1.0.0 plus the `$dev` phase-commit law.

| Command                    | Role                                                                  |
| -------------------------- | --------------------------------------------------------------------- |
| `skill list`               | List non-hidden store skills                                          |
| `skill doctor`             | Report `ok` / `drift` / `home-only` / `broken` for store vs install   |
| `skill backfill <name>`    | Copy drifted real files from `~/.agents/skills/<name>` into the store |
| `skill promote <name>`     | Move `<project>/.agents/skills/<name>` into the store                 |
| `skill rename <old> <new>` | Rename in the store                                                   |
| `rcup`                     | Install store skills into `~/.agents/skills`                          |

`drift` → `skill backfill <name>` → `rcup`. Project drafts live in `<repo>/.agents/skills/<name>/` (promote source).
