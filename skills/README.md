# Skills

`~/.dotfiles/skills/` is the git-tracked store for **personal and custom** skills. External skills come from registries like [skills.sh](https://skills.sh/) and upstream repos such as [vercel-labs/agent-skills](https://github.com/vercel-labs/agent-skills).

Install and manage agent skills with the official [vercel-labs/skills](https://github.com/vercel-labs/skills) CLI (`npx skills`). Use `./scripts/skill` only for dotfiles store hygiene (`promote`, `rename`, `list`).

## Lock file (`skills-lock.json`)

Dotfiles-managed agent installs are tracked in [`skills-lock.json`](../skills-lock.json) at the repo root. Run `npx skills add` / `remove` **from `~/.dotfiles`** (project scope, no `-g`) so the CLI updates the lock and wires `.agents/skills/`.

| Command                           | What it does                                                        |
| --------------------------------- | ------------------------------------------------------------------- |
| `skills-restore`                  | Install from the lock, then prune; runs via `topgrade` after `rcup` |
| `skills-restore --prune-only`     | Prune without installing                                            |
| `npx skills experimental_install` | Install only — **does not** remove installs the lock dropped        |
| `npx skills add …`                | Add a skill and update the lock — **commit the lock** afterward     |

`npx skills experimental_install` only adds, so retired skills keep being advertised to agents until they are pruned. `skills-restore` converges instead:

| Location                             | Prune rule                                                                  |
| ------------------------------------ | --------------------------------------------------------------------------- |
| `~/.dotfiles/.agents/skills/`        | Remove anything absent from `skills-lock.json` (the tree is generated)      |
| `~/.agents`, `~/.codex`, `~/.cursor` | Remove dangling symlinks only; real directories from other sources are kept |

Run it after retiring or renaming a skill, not just after a clone.

After cloning or pulling lock changes:

```sh
cd ~/.dotfiles && skills-restore
# or: npx skills experimental_install -y
```

**Promote vs install:**

| Command                      | Source                            | Destination                                 |
| ---------------------------- | --------------------------------- | ------------------------------------------- |
| `skill promote <name>`       | `<project>/.agents/skills/<name>` | `~/.dotfiles/skills/` (git)                 |
| `npx skills add` / `install` | lock / remote / dotfiles repo     | `~/.dotfiles/.agents/skills/` + lock update |

The `.agents/skills/` tree is gitignored; regenerate it from the lock. `skills-lock.json` is excluded from RCM (`rcrc`) so it stays at `~/.dotfiles/skills-lock.json` only.

## Install external skills

```sh
npx skills add https://github.com/vercel-labs/agent-skills --skill vercel-react-best-practices
npx skills add vercel-labs/agent-skills --list
npx skills add vercel-labs/agent-skills --skill frontend-design -a cursor -a codex -y   # from ~/.dotfiles to update lock
```

Common flags:

| Flag                 | Purpose                                                                                                         |
| -------------------- | --------------------------------------------------------------------------------------------------------------- |
| `-a cursor -a codex` | Target specific agents                                                                                          |
| `-y`                 | Non-interactive (skip prompts)                                                                                  |
| `-g`                 | Global install (`~/.codex/skills/`, `~/.cursor/skills/`) — optional for edge cases; dotfiles uses project scope |

## Install dotfiles skills

Install from [gildesmarais/dotfiles](https://github.com/gildesmarais/dotfiles) (discovery walks `skills/`):

```sh
cd ~/.dotfiles
npx skills add gildesmarais/dotfiles --skill ruby-dev -a cursor -a codex -y
npx skills add gildesmarais/dotfiles --skill '*' -a cursor -a codex -y   # all custom skills
```

For dotfiles-managed skills, prefer **project scope** (run from `~/.dotfiles`, no `-g`) so installs land in `.agents/skills/` and `skills-lock.json` stays in sync. Use **global** (`-g`) only when you want a skill outside the dotfiles lock workflow.

## Day-to-day commands

```sh
npx skills list              # list installed skills
npx skills find <query>      # search available skills
npx skills update            # update installed skills
npx skills update <name>     # update one skill
npx skills remove <name>     # remove an installed skill
npx skills init              # scaffold a new skill directory
```

## Authoring

Each skill is a directory with a `SKILL.md` file. Frontmatter should include `name` and `description`. Optional subdirectories: `scripts/`, `agents/`, and other supporting files.

### Router skills

A router `SKILL.md` picks one branch and hands off to a reference file. `pull-request`, `review`, `communication`, and `docs` follow this template; keep new routers consistent with it:

| Section                  | Contents                                                                        |
| ------------------------ | ------------------------------------------------------------------------------- |
| `## Pick branch`         | Branch table, plus a routing-signals table when phrasing is ambiguous           |
| `## Shared prep`         | Steps and rules every branch runs (name it `Shared contract` for tooling rules) |
| `## Branch reference`    | One link per branch into `reference/<branch>.md` — load exactly one             |
| `## Handoff`             | Which skill continues the work, and in which direction only                     |
| `## Completion criteria` | One row per branch, stating done-ness observably                                |

Rules:

- Use unnumbered `##` headers (e.g. `## Pick branch`) — no leading numbers.
- Write reference links relative to the skill directory (`reference/open.md`), never repo-rooted, because skills run from their install path.
- Put branch-specific detail in the reference file; keep only what all branches share in the router body.
- Refer to other skills by plain name in `SKILL.md` (`the ruby-dev skill`). Agent-specific invocation syntax such as `$ruby-dev` belongs in `agents/*.yaml`.

`allow_implicit_invocation: true` is only for skills whose output is a report/draft the user reviews before anything ships; skills that directly implement, rewrite, or publish must omit it. The policy is per skill, not per branch, so a router must omit it as soon as **one** branch changes code — that is why `review` omits it (`quality` refactors and runs gates) while `communication` keeps it.

See [agentskills.io](https://agentskills.io/) for the full spec.

## Store hygiene (`./scripts/skill`)

Use the Ruby helper when moving skills into or within the dotfiles store:

| Command                    | When to use                                                            |
| -------------------------- | ---------------------------------------------------------------------- |
| `skill promote <name>`     | Move a project-local skill from `.agents/skills/<name>` into the store |
| `skill rename <old> <new>` | Rename a skill in the store                                            |
| `skill list`               | List skills in the dotfiles store                                      |

On success, `promote` prints a suggested `npx skills add` command. After `rename`, refresh agent installs with `npx skills remove` and `npx skills add`.

## Migration from `skill link`

The old `skill link` workflow symlinked `.codex/skills/` into the dotfiles store. That path is **deprecated** — do not recreate it.

One-time cleanup:

```sh
rm -rf .codex/skills
# remove manual symlinks under ~/.agents/skills or agent-specific dirs if present
cd ~/.dotfiles && skills-restore
```

Use `npx skills list` instead of the removed `skill doctor` and `skill status` commands.

## Retired skills

| Retired skill                | Successor                                                    |
| ---------------------------- | ------------------------------------------------------------ |
| gh-review-resolve            | `pull-request` **`resolve`**                                 |
| gh-address-comments          | `pull-request` **`resolve`** or **`reply`**                  |
| gh-pr-review                 | `pull-request` **`comment`**                                 |
| findings-to-gh-pr-review     | `pull-request` **`comment`**                                 |
| pr-opener                    | `pull-request` **`open`**                                    |
| pr-slicer                    | `pull-request` **`slice`**                                   |
| open-pr                      | `pull-request` **`open`**                                    |
| slice-pr                     | `pull-request` **`slice`**                                   |
| gh-pr                        | `pull-request` (**`comment`** / **`resolve`** / **`reply`**) |
| gh-review-specific-pr        | `pull-request` **`comment`**                                 |
| finish-review                | `review` **`finish`**                                        |
| review-tests                 | `review` **`tests`**                                         |
| review-perf-ruby             | `review` **`perf`**                                          |
| review-security-compliance   | `review` **`security`**                                      |
| quality-loop                 | `review` **`quality`**                                       |
| one-on-one-raw-notes         | `communication` **`one-on-one`**                             |
| message-refinement-tech-orga | `communication` **`slack-message`**                          |
| project-update               | `communication` **`project-update`**                         |
| docs-editor                  | `docs` **`editor`**                                          |
| docs-architecture            | `docs` **`architecture`**                                    |

Never committed to the store, but still found as leftover symlinks from the deprecated `skill link` era: `message-project-update-distiller` (→ `communication` **`project-update`**) and `idea-to-story-in-jira` (no successor). `skills-restore` removes such dangling links.

## Paths reference

| Scope             | Path                                 | Notes                                                      |
| ----------------- | ------------------------------------ | ---------------------------------------------------------- |
| Dotfiles store    | `~/.dotfiles/skills/<name>/`         | Canonical git-tracked source                               |
| Dotfiles installs | `~/.dotfiles/.agents/skills/<name>/` | Restored from `skills-lock.json`                           |
| Project (shared)  | `<repo>/.agents/skills/<name>/`      | Per-repo skills (optional `skills-lock.json` in that repo) |
| Global Codex      | `~/.codex/skills/<name>/`            | Managed by `npx skills add -g`                             |
| Global Cursor     | `~/.cursor/skills/<name>/`           | Managed by `npx skills add -g`                             |

**Deprecated:** `<repo>/.codex/skills/`, `<repo>/.cursor/skills/`, and other per-agent project directories. Delete legacy installs and reinstall with `npx skills`.
