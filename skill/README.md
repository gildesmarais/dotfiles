# Skill CLI

This directory contains the implementation and tests for the `skill` command.

## Layout

```text
skill/
  README.md
  src/
    cli.rb
    skill/
      classifier.rb
      dropped_identifiers.rb
      error.rb
      filesystem.rb
      linter.rb
      operations.rb
      paths.rb
      ui.rb
  test/
    cli_test.rb
    unit_test.rb
```

- `src/cli.rb`: command parsing, dispatch, and help output
- `src/skill/paths.rb`: canonical store, `claude/skills` entry, home, and project path resolution
- `src/skill/classifier.rb`: closed status set, real-file drift, and orphan-link detection
- `src/skill/linter.rb`: store shape, word ratchet, link graph, and related lint checks
- `src/skill/dropped_identifiers.rb`: `lint --since` identifier extraction and ownership
- `src/skill/filesystem.rb`: shared skill-name safety helpers
- `src/skill/error.rb`: shared CLI exit/error object used below the entrypoint
- `src/skill/operations.rb`: list / doctor / lint / prune / backfill / promote / rename behavior
- `src/skill/ui.rb`: CLI output and fatal error helpers
- `test/cli_test.rb`: characterization tests for command parsing and filesystem behavior
- `test/unit_test.rb`: direct object tests for classifier, linter, and operation edge cases
- `../scripts/skill`: thin executable entrypoint

## Useful Commands

Run the CLI entrypoint:

```sh
./scripts/skill help
./scripts/skill list
./scripts/skill doctor
./scripts/skill lint
./scripts/skill lint --measure
./scripts/skill lint --since HEAD~1
./scripts/skill --project . lint --measure --since main
./scripts/skill prune
./scripts/skill backfill my-skill
./scripts/skill promote my-skill
./scripts/skill rename ruby-dev ruby
```

Expected results:

- `lint` checks store Markdown against `agents/skills/.budgets.yml` (word ratchet, description budget, 100-line hard cap), router/pinned headers, link resolve, link graph (acyclic, ≤2 hops from each `SKILL.md`, no router-to-router links), duplicate lines, and `claude/skills/` entries (every store skill and shared `CONTEXT.md` needs a relative symlink into the store; wrong or stale entries fail); exits `0` with `lint ok`, else `1` with one finding per line
- `--project PATH lint` lints the project stores `PATH/.agents/skills` and `PATH/.claude/skills` (neither exits `1` with one finding), each resolved with `realpath` so a symlinked store root is walked. When both exist and are distinct real paths, both are linted and every store-scoped finding (shape, budget, link, duplicate-line and `--since` store drops) is prefixed with its store (`.agents/skills: ...`); with one store nothing is prefixed. Findings that belong to no store stay unprefixed: the no-store error and root-doc drops (`dropped: <id> (AGENTS.md)`). Two names for one real path count once. Structural checks only: description cap, 100-line cap, link resolve, link graph, duplicate lines. A relative link whose `realpath` lands inside a store is resolved as an in-store link, even when it leaves the store and re-enters it (`../../skills/b/SKILL.md`), so the link graph, cycle, hop and router-to-router checks see it. A link that leaves every store is valid when it resolves to an existing file inside the project root (for example `../../../AGENTS.md`); a missing file or one outside the root is broken. Once a store has its own `.budgets.yml`, the word ratchet and the whole router-header shape (`Pick branch`, optional `Shared prep`, `Branch reference`, `Handoff`, `Completion criteria`, in that order) are enforced for that store, not only headers listed under `pinned_headers`; without one, neither applies. `claude/skills/` entry checks are skipped. Without `--project`, `lint` audits the dotfiles store as before
- `lint --measure` prints `<surface> files=N words=N lines=N` for `catalog` (frontmatter `description`), `router` (`SKILL.md` body), and `branch` (all other Markdown) before the result; works for the store and `--project`. With two project stores each line is prefixed with its store. In project mode a final `context files=N words=N lines=N` line counts the project-root `AGENTS.md` / `CONTEXT.md` / `CLAUDE.md` that exist (symlinked duplicates count once; `files=0` when none exist)
- `lint --since REF` collects identifiers (backticked spans, Markdown link targets, `$skill` refs) from Markdown at git `REF` and the working tree; each one gone from the working tree and not owned anywhere else is a `dropped: <id> (<file at REF>)` finding (exit `1`). Ownership is a token match (`dev` is not owned by `devops`, `$dev`, or `dev-tools`; a boundary applies only where the identifier's edge is a word character, `$`, or `-`, so `agents/skills/` is owned by `agents/skills/x.md` and `.md` by `SKILL.md`) in the text of every working-tree store plus the root docs; the root docs are the project root's with `--project`, the dotfiles repo's without it. With `--project`, both store locations at `REF` are diffed whether or not they still exist (a deleted store, or one replaced by a symlink, cannot hide its drops), and identifiers dropped from the root docs are reported too. Text is read as UTF-8 regardless of `LC_ALL`. A `REF` that predates the store lints ok
- `doctor` prints aligned columns (padded name, then status: `ok`, `drift`, `home-only`, `broken`, `orphan`); exits `0` when no `drift` or `orphan`, else `1`
- An **orphan** is a symlink under `~/.agents/skills/<name>/` or `~/.claude/skills/<name>/` whose target is inside the dotfiles store (`agents/skills` or `claude/skills`) and no longer exists; real files, hidden paths, and links pointing elsewhere are never orphans
- `prune` covers both install roots: it deletes orphan links (and emptied directories), prints each path as `name/relative` (`~/.agents/skills`) or `claude:name/relative` (`~/.claude/skills`), and notes the total count; a second run notes `no orphans to prune`
- Agent install listing includes skill directories (and broken skill symlinks for `broken` status); excludes vocabulary file symlinks such as `CONTEXT.md`
- `promote` / `rename` also create, move, or remove `claude/skills/<name>` inside the repo (never under `$HOME`); run `rcup` to install
- `backfill <name>` prints each copied relative path, notes an `rcup` hint, and refuses home-only / broken / no-drift / missing store skills
- After `backfill`, run `rcup` (or wait for topgrade) so `~/.agents/skills` matches the store again

Run the implementation directly:

```sh
ruby skill/src/cli.rb help
ruby skill/src/cli.rb list
ruby skill/src/cli.rb doctor
ruby skill/src/cli.rb lint
```

Lint and tests (quality gate):

```sh
make check
```

Pre-PR gate (includes `skill lint` on the real store):

```sh
make ready
```

Syntax check:

```sh
ruby -c scripts/skill
ruby -c skill/src/cli.rb
ruby -c skill/src/skill/classifier.rb
ruby -c skill/src/skill/error.rb
ruby -c skill/src/skill/filesystem.rb
ruby -c skill/src/skill/linter.rb
ruby -c skill/src/skill/operations.rb
ruby -c skill/src/skill/paths.rb
ruby -c skill/src/skill/ui.rb
ruby -c skill/test/cli_test.rb
ruby -c skill/test/unit_test.rb
```

Run tests:

```sh
ruby -Iskill/test -e 'Dir["skill/test/*_test.rb"].sort.each { |file| require File.expand_path(file) }'
```

Run tests with the macOS system Ruby 2.6:

```sh
/System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/bin/ruby -Iskill/test -e 'Dir["skill/test/*_test.rb"].sort.each { |file| require File.expand_path(file) }'
```

## Notes For AI Agents

- Prefer changing `skill/src/cli.rb` and keeping `scripts/skill` as a tiny entrypoint.
- Keep `skill/src/cli.rb` as the CLI shell and put reusable behavior in `skill/src/skill/*.rb`.
- Keep process exits in the CLI layer; lower-level classes should raise `Skill::ExitError`.
- Status, drift, and orphan detection live only in `Skill::Classifier`; doctor/backfill/prune must not re-derive them.
- Store Markdown cost checks live only in `Skill::Linter`; budgets live in `agents/skills/.budgets.yml`.
- When changing command behavior, update or add tests in `skill/test/cli_test.rb` first when practical.
- Preserve Ruby 2.6 compatibility.
- Prefer stdlib-only dependencies unless there is a strong reason not to.
- First-party agent install is via `rcup` from `agents/skills/<name>/` into `~/.agents/skills/<name>/`, and from `claude/skills/<name>` (symlink into the store, maintained by `promote` / `rename`, checked by `lint`) into `~/.claude/skills/<name>/` for Claude Code. After `promote` / `rename` / `backfill`, run `rcup` (or wait for topgrade).
