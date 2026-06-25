# Skills

`~/.dotfiles/skills/` is the git-tracked store for **personal and custom** skills. External skills come from registries like [skills.sh](https://skills.sh/) and upstream repos such as [vercel-labs/agent-skills](https://github.com/vercel-labs/agent-skills).

Install and manage agent skills with the official [vercel-labs/skills](https://github.com/vercel-labs/skills) CLI (`npx skills`). Use `./scripts/skill` only for dotfiles store hygiene (`promote`, `rename`, `list`).

## Lock file (`skills-lock.json`)

Dotfiles-managed agent installs are tracked in [`skills-lock.json`](../skills-lock.json) at the repo root. Run `npx skills add` / `remove` **from `~/.dotfiles`** (project scope, no `-g`) so the CLI updates the lock and wires `.agents/skills/`.

| Command                           | What it does                                                                                            |
| --------------------------------- | ------------------------------------------------------------------------------------------------------- |
| `skills-restore`                  | Restore installs from the lock (`npx skills experimental_install -y`); runs via `topgrade` after `rcup` |
| `npx skills experimental_install` | Same as restore when run from `~/.dotfiles`                                                             |
| `npx skills add …`                | Add a skill and update the lock — **commit the lock** afterward                                         |

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

| Retired skill            | Successor                       |
| ------------------------ | ------------------------------- |
| gh-review-resolve        | gh-pr                           |
| gh-address-comments      | gh-pr (assess + reply sub-path) |
| gh-pr-review             | gh-review-specific-pr           |
| findings-to-gh-pr-review | gh-review-specific-pr           |
| pr-opener                | open-pr                         |
| pr-slicer                | slice-pr                        |

## Paths reference

| Scope             | Path                                 | Notes                                                      |
| ----------------- | ------------------------------------ | ---------------------------------------------------------- |
| Dotfiles store    | `~/.dotfiles/skills/<name>/`         | Canonical git-tracked source                               |
| Dotfiles installs | `~/.dotfiles/.agents/skills/<name>/` | Restored from `skills-lock.json`                           |
| Project (shared)  | `<repo>/.agents/skills/<name>/`      | Per-repo skills (optional `skills-lock.json` in that repo) |
| Global Codex      | `~/.codex/skills/<name>/`            | Managed by `npx skills add -g`                             |
| Global Cursor     | `~/.cursor/skills/<name>/`           | Managed by `npx skills add -g`                             |

**Deprecated:** `<repo>/.codex/skills/`, `<repo>/.cursor/skills/`, and other per-agent project directories. Delete legacy installs and reinstall with `npx skills`.
