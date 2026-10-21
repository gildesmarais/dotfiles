# Skills

Personal product + engineering skill store: domain routers (Build entry: `dev`), Solution craft (`architecture`), thin language adapters/overlays. Vocabulary: [`CONTEXT.md`](CONTEXT.md).

## Install

```sh
npx skills add gildesmarais/dotfiles/agents/skills -g -a cursor -a codex -y
```

Requires Node.js and GitHub access. Verify: `npx skills list -g`. Browse: `--list`. Project-level: omit `-g`. Specific skills: `--skill <name>` (repeatable). This machine: `rcup` — see [Operate the store](#operate-the-store). CLI: [vercel-labs/skills](https://github.com/vercel-labs/skills).

## Domain map

| Domain       | Job                     | Skill(s)                                                                                                                                                                                                                    | Primary branches                                                                                                                              |
| ------------ | ----------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------- |
| **Intent**   | Fuzzy need → work       | [`triage`](triage/), [`jira-ticket`](jira-ticket/), [`pr-sweep`](pr-sweep/)                                                                                                                                                  | `triage` `intake` (+ playbooks); `pr-sweep` `report`                                                                                          |
| **Product**  | Admit/defer scope       | [`product-owner`](product-owner/)                                                                                                                                                                                           | `gate` (default); `story-slice`; `rebaseline`; `groom`; stubs: `prioritize`, `experiment`                                                     |
| **Solution** | How the system works    | [`architecture`](architecture/); [`docs`](docs/) `architecture` (verify-only) · `evidence`; `dev` `plan`                                                                                                                    | `philosophy` \| `deep-modules` \| `refactor-types` \| `refactor-boundaries` \| `performance` \| `design-patterns`; survey: `structure-survey` |
| **Build**    | Change the codebase     | [`dev`](dev/); adapters [`ruby-dev`](ruby-dev/), [`rust-dev`](rust-dev/), [`swift-dev`](swift-dev/), [`typescript-dev`](typescript-dev/); overlays [`ruby-on-rails-dev`](ruby-on-rails-dev/), [`swiftui-dev`](swiftui-dev/) | `plan` \| `implement`; classify: surgical \| design \| review-hand-off                                                                        |
| **Assure**   | Safe to merge?          | [`review.gil`](review.gil/)                                                                                                                                                                                                 | `findings`, `publish`, `quality` (lenses: tests, perf, security, legacy)                                                                      |
| **Ship**     | Land on mainline        | [`pull-request`](pull-request/), [`dependabot`](dependabot/), [`release`](release/)                                                                                                                                         | PR: open, slice, retitle, comment, reply, resolve, fix-ci, conflicts (+ unblock); Dependabot: configure \| triage; release: `notes`           |
| **Explain**  | Humans understand state | [`communication`](communication/), [`docs`](docs/)                                                                                                                                                                          | see skill branches                                                                                                                            |
| **Decide**   | Stress-test choices     | `grilling` (third-party); `product-owner` Forced Challenge                                                                                                                                                                  | —                                                                                                                                             |
| **Harvest**  | Learning & debt loop    | [`harvest`](harvest/)                                                                                                                                                                                                       | `distill` (default); `debt`                                                                                                                   |
| **Personal** | Tool operators          | [`omnifocus`](omnifocus/)                                                                                                                                                                                                   | —                                                                                                                                             |

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

Build path: `$dev` ⇄ `architecture` → `review.gil` → `pull-request`. `$dev` is the only Build entry. `README.md` is not installed by `rcup` — runtime contracts live in skills and [`CONTEXT.md`](CONTEXT.md).

1. **Product before non-trivial scope** — feature / `jira-ticket` → `product-owner` `gate` → `$dev plan`. Multi-slice / UX-mandated AC → `story-slice` → `$dev plan`. Skip gate for bug fix / refactor / infra. Incident without Jira → `triage` first.
2. **Craft ≠ product** — `architecture` / `dev` / `*-dev` / `review.gil` never answer "should we build X?".
3. **Build entry is `$dev`** — classify / route there; axioms on every `implement`; `{lang}-dev` from touched-file evidence.
4. **Plans → `$dev` `plan`** — each todo names files, one gate, Conventional Commit message; execute via [`dev/reference/phase-commits.md`](dev/reference/phase-commits.md).
5. **Assure → Ship** — `findings` never posts; `publish` in `review.gil`; verified ledger → `pull-request` `comment`. Delivery Ledger: `dev/SKILL.md` Handoff.
6. **Explain → docs** — `communication` → `docs` `editor`; never reverse.
7. **Overlays via `$dev`** — `ruby-on-rails-dev` with `ruby-dev`; `swiftui-dev` with `swift-dev`.
8. **Decide** — `grilling` stress-tests; scope doctrine with `product-owner`.
9. **Sweep never fixes** — `pr-sweep` rows → `pull-request` / `dependabot` / `review.gil`.
10. **Unblock chain** — `pull-request`: conflicts → resolve → fix-ci; never approve/merge.
11. **Harvest loop** — `review.gil` / `pull-request` → `harvest` → rules or `.agents/debt-ledger.md` → `product-owner` Health Capacity Budget.

## Authoring laws

- **One router per domain**; branches are verb-paths with progressive load.
- **Freeze the router** — harvest via staging → sparse-promote into `reference/<branch>.md`; edit `SKILL.md` only when the contract is wrong.
- **Thin `*-dev`** — craft in `architecture`; classify / validation / phase commits in `$dev`; overlays are deltas only.
- **Proliferation guard** — new top-level skill only if it cannot be a branch of an existing router. Runtime route table stays in `dev/SKILL.md`.
- **Zero backward compat** — delete superseded aliases, old execution names, and dual shims on cutover.
- **Tokens are the currency** — single ownership, bounded Markdown DTOs for handoffs, no intermediate prompt layers.
- **Invocation** — new skills default to `disable-model-invocation: true` unless they are an ambient router.

Router shape: `## Pick branch` → `## Shared prep` (omit when empty) → `## Branch reference` → `## Handoff` → `## Completion criteria`; relative `reference/*.md` links; unnumbered `##` headers. Spec: [agentskills.io](https://agentskills.io/). Repo-only notes: [`skill/authoring/`](../../skill/authoring/) — never cite from installed skill routers.

## Operate the store

Git-tracked `agents/skills/<name>/` is SoT. `rcup` installs file-level links into `~/.agents/skills/<name>/`. Keep `SYMLINK_DIRS` unset for `agents` / `agents/skills`. After clone/pull, promote/rename, or `backfill`, run `rcup` (or topgrade `RCM: rcup`).

`rcup` installs `CONTEXT.md` so `../CONTEXT.md` citations resolve; keep `README.md` in `rcrc` `EXCLUDES`; never exclude `CONTEXT.md`. External `npx skills` installs may lack `CONTEXT.md` — fall back to [conventionalcommits.org](https://www.conventionalcommits.org/) v1.0.0 plus the `$dev` phase-commit law.

| Command                    | Role                                                                  |
| -------------------------- | --------------------------------------------------------------------- |
| `skill list`               | List non-hidden store skills                                          |
| `skill doctor`             | Report `ok` / `drift` / `home-only` / `broken` / `orphan`             |
| `skill lint`               | Word ratchet, 100-line cap, router shape, link graph, duplicates      |
| `skill prune`              | Remove orphan rcup links whose store source is gone                   |
| `skill backfill <name>`    | Copy drifted real files from `~/.agents/skills/<name>` into the store |
| `skill promote <name>`     | Move `<project>/.agents/skills/<name>` into the store                 |
| `skill rename <old> <new>` | Rename in the store                                                   |
| `rcup`                     | Install store skills into `~/.agents/skills`                          |

`drift` → `skill backfill <name>` → `rcup`. `orphan` → `skill prune`. Project drafts: `<repo>/.agents/skills/<name>/`.
