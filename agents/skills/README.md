# Skills

Personal skill store for a **product + engineering AI skill OS**: domain routers plus thin language adapters. Lives at `agents/skills/` in this repo. Vocabulary: [`CONTEXT.md`](CONTEXT.md).

First-party skills install via `rcup` into `~/.agents/skills`. Optional third-party packs use manual `npx skills` (below).

## Pipeline

```mermaid
flowchart LR
  Intent[Intent] --> Product[Product]
  Product --> Solution[Solution]
  Solution --> Build[Build]
  Build --> Assure[Assure]
  Assure --> Ship[Ship]
  Ship --> Run[Run]
  Run --> Explain[Explain]
  Explain --> Intent
  Decide[Decide] -.-> Intent
  Decide -.-> Product
  Decide -.-> Solution
```

## Domain map

| Domain       | Job                              | Skill(s)                                                   | Primary branches                                                             | Status                                               |
| ------------ | -------------------------------- | ---------------------------------------------------------- | ---------------------------------------------------------------------------- | ---------------------------------------------------- |
| **Intent**   | Fuzzy need → actionable work     | `prompt-synthesis`; `jira-ticket`                          | `code` \| `architecture` \| `product` (default: Shared prep)                 | active — Spec/PRD **deferred**                       |
| **Product**  | What to build; admit/defer scope | `product-owner`                                            | `gate` (default); stubs: prioritize, story-slice, experiment                 | active gate; stub bodies **sequenced** (KISS)        |
| **Solution** | How the system should work       | `architecture`; `docs` **`architecture`** (verify-only)    | `deep-modules` \| `refactor-types` \| `refactor-boundaries` \| `performance` | active; HLD/ADR author **deferred**                  |
| **Build**    | Change the codebase              | `ruby-dev`, `rust-dev`; overlay `ruby-on-rails-dev`        | classify: surgical \| design \| review-hand-off                              | active — phase CC during plans                       |
| **Assure**   | Safe to merge?                   | `review`                                                   | finish, quality, tests, perf, security, publish                              | active — test-design author **gap**                  |
| **Ship**     | Land on mainline                 | `pull-request`; `release`                                  | PR: open, slice, comment, reply, resolve; release: `notes`                   | active — release ops (flag/promote/rollback) **gap** |
| **Run**      | Production health                | thin (e.g. jira → Datadog)                                 | —                                                                            | **gap** (Incident postponed)                         |
| **Explain**  | Humans understand state          | `communication`; `docs`                                    | see skill branches                                                           | active                                               |
| **Decide**   | Stress-test choices              | `grilling` (third-party); `product-owner` Forced Challenge | —                                                                            | grilling external — not first-party store skill      |

Published Build overlay: `ruby-on-rails-dev`. Local-only overlay: `mir-architect` ([below](#local-only-mir-architect)).

## Optional packs (not OS SoT)

Decide helpers and upstream language packs sit outside the domain routers. They are never OS source of truth. Install manually (not via `rcup` store trees):

```sh
# Decide
npx skills add https://github.com/mattpocock/skills --skill grilling -a cursor -a codex -y

# Swift / Apple (pick what you need)
npx skills add https://github.com/twostraws/swiftui-agent-skill --skill swiftui-pro -a cursor -a codex -y
npx skills add https://github.com/twostraws/swift-testing-agent-skill --skill swift-testing-pro -a cursor -a codex -y
# Catalog: https://github.com/twostraws/Swift-Agent-Skills
```

Store-local spice (`ms-rust`, `rust-performance`) lands with `rcup` when present under `agents/skills/`.

| Pack               | When you want it                                   | Role                                                   |
| ------------------ | -------------------------------------------------- | ------------------------------------------------------ |
| `grilling`         | Stress-test a plan or decision                     | Upstream Decide skill                                  |
| `ms-rust`          | Microsoft-style Rust guidelines before `.rs` edits | Compose with `rust-dev` (store → `rcup`)               |
| `rust-performance` | Measure-before-optimize Rust work                  | Craft ownership stays `architecture` **`performance`** |
| `swift-*`          | SwiftUI / Swift Testing / Apple packs              | Upstream or `<repo>/.agents/skills/` specialists       |

Discover more on [skills.sh](https://skills.sh/).

## Compose / handoffs

One-way rules (prevent domain collisions):

1. **Product before non-trivial scope** — `jira-ticket` / feature asks load `product-owner` **`gate`**. Impl continues only on **Build Now**. Skip for pure bugfix, refactor, infra. Product is gate-only this pass (stubs unauthored).
2. **Craft ≠ product** — `architecture` / `*-dev` / `review` never answer “should we build X?”
3. **Build → Solution** — `*-dev` class `design` loads `architecture` (branch pick inside); do not inline craft in `*-dev`.
4. **Phase CC → merge → notes** — Solution/Build plan phases author Conventional Commits (validate → ≥1 CC + rationale). After merge, `release` **`notes`** consumes history. `pull-request` **`open`** is leftover applicator only. Format SoT: [`CONTEXT.md`](CONTEXT.md).
5. **Assure → Ship** — `review` may hand off to `pull-request` **`comment`**. Never reverse: GitHub posting does not live under `review`.
6. **Explain → docs** — `communication` → `docs` **`editor`** when the artifact is a README/runbook, not a message. Never reverse. `docs` **`architecture`** is Solution-adjacent verify-only (no HLD/ADR author).
7. **Overlay → runtime** — Published: `ruby-on-rails-dev` with `ruby-dev`. Local-only: `mir-architect` with `rust-dev` ([below](#local-only-mir-architect)).
8. **Decide** — `grilling` stress-tests Intent / Product / Solution; product doctrine stays with `product-owner` when the topic is scope.

## Skill index

| Domain   | Skills                                                                                      |
| -------- | ------------------------------------------------------------------------------------------- |
| Intent   | [`prompt-synthesis`](prompt-synthesis/), [`jira-ticket`](jira-ticket/)                      |
| Product  | [`product-owner`](product-owner/)                                                           |
| Solution | [`architecture`](architecture/), [`docs`](docs/)                                            |
| Build    | [`ruby-dev`](ruby-dev/), [`rust-dev`](rust-dev/), [`ruby-on-rails-dev`](ruby-on-rails-dev/) |
| Assure   | [`review`](review/)                                                                         |
| Ship     | [`pull-request`](pull-request/), [`release`](release/)                                      |
| Explain  | [`communication`](communication/), [`docs`](docs/)                                          |
| Decide   | `grilling` (third-party — [Optional packs](#optional-packs-not-os-sot))                     |

### Local-only: `mir-architect`

MIR / rhythmic-analysis overlay for `rust-dev` (club music grids, downbeat, tempo).

|           |                                                          |
| --------- | -------------------------------------------------------- |
| **When**  | `agents/skills/mir-architect/` is present on this machine |
| **How**   | `rcup` (same as other store skills)                      |
| **Scope** | Local-only; omit from public install examples            |

Skip if you are not on that MIR stack.

## Authoring laws

- **One router per domain** — branches for verb-paths; progressive load.
- **Freeze the router** — harvest lessons into `reference/` (tag branch); edit `SKILL.md` only when the contract is wrong.
- **Compose across domains** with one-way handoffs (above).
- **Thin `*-dev`** — craft stays in `architecture`; overlays are deltas only.
- **Phase commits on Build** — every new `{lang}-dev` includes the Contracts Phase commits bullet (same wording as `rust-dev`); overlays never copy it. Solution/Build plans encode validate→commit per phase via [`CONTEXT.md`](CONTEXT.md).
- **Local-only overlays** — may live under `agents/skills/` (e.g. `mir-architect`); document when/how/scope; they install via `rcup`.
- **Proliferation guard** — new top-level skill only if it cannot be a branch of an existing router (for refactor concerns: `refactor-<concern>` under `architecture`, never bare `refactor` or a parallel `product` skill).

Router shape: `## Pick branch` → `## Shared prep` → `## Branch reference` → `## Handoff` → `## Completion criteria`. Relative `reference/*.md` links; unnumbered `##` headers. Terms: [`CONTEXT.md`](CONTEXT.md). Spec: [agentskills.io](https://agentskills.io/).

---

## Operate the store

Model: git-tracked trees under `agents/skills/<name>/` are the source of truth. `rcup` installs them into `~/.agents/skills/<name>/` (file-level links). Do **not** set `SYMLINK_DIRS` for `agents`/`agents/skills` — that would own all of `~/.agents/skills` and fight third-party real dirs from `npx skills`. After clone/pull or promote/rename, run `rcup` (or wait for topgrade `RCM: rcup`). Optional note: an old generated tree at `~/.dotfiles/.agents/skills` or a leftover `~/.skills` tree is unused now and safe to delete locally.

| Command                    | Role                                                    |
| -------------------------- | ------------------------------------------------------- |
| `skill list`               | List non-hidden skills in the store                     |
| `skill promote <name>`     | Move `<project>/.agents/skills/<name>` into the store   |
| `skill rename <old> <new>` | Rename in the store                                     |
| `rcup`                     | Install store skills into `~/.agents/skills`            |

### Paths

| Scope         | Path                                             |
| ------------- | ------------------------------------------------ |
| Store         | `agents/skills/<name>/` in this repo             |
| Agent install | `~/.agents/skills/<name>/` via `rcup`            |
| Project draft | `<repo>/.agents/skills/<name>/` (promote source) |
