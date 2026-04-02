# Skill CLI

This directory contains the implementation and tests for the `skill` command.

## Layout

```text
skill/
  README.md
  src/
    cli.rb
    skill/
      config.rb
      doctor.rb
      error.rb
      filesystem.rb
      operations.rb
      paths.rb
      state.rb
      ui.rb
  config/
    default-config.yml
  test/
    cli_test.rb
    unit_test.rb
```

- `src/cli.rb`: command parsing, dispatch, and help output
- `src/skill/config.rb`: central and project-local config loading and normalization
- `src/skill/paths.rb`: canonical store and project path resolution
- `src/skill/state.rb`: shared destination state inspection used by status, doctor, and mutating commands
- `src/skill/filesystem.rb`: shared symlink and skill-name safety helpers
- `src/skill/error.rb`: shared CLI exit/error object used below the entrypoint
- `src/skill/operations.rb`: skill list/status/link/unlink/clean/adopt/promote/rename behavior
- `src/skill/doctor.rb`: doctor scan and reporting behavior
- `src/skill/ui.rb`: CLI output and fatal error helpers
- `config/default-config.yml`: documented template for `~/.config/skill/config.yml`
- `test/cli_test.rb`: characterization tests for command parsing and filesystem behavior
- `test/unit_test.rb`: direct object tests for operation and doctor edge cases
- `../scripts/skill`: thin executable entrypoint

## Configuration

The CLI reads configuration from:

- central config: `~/.config/skill/config.yml`
- project-local config: `<project>/.skill.yml`

Config precedence is:

1. built-in defaults
2. central config
3. project-local config

The central config defines known tool profiles and their preferred skill destinations.
The project config selects active tools for a specific repository and can add extra destinations.

### Default behavior

Out of the box, the CLI behaves exactly like the original version:

- canonical store: `skills/` at the dotfiles root
- active tool set: `codex`
- authoring destination: `.codex/skills`

### Authoring vs mirror destinations

Exactly one destination is the authoring destination for a project.
That is where a local skill is expected to be created before `skill promote <name>`.
Any other configured destinations are mirrors that receive symlinks to the canonical store.

### Central config example

Copy `skill/config/default-config.yml` to `~/.config/skill/config.yml` and adjust as needed.

Example:

```yaml
store_dir: skills

tools:
  codex:
    destinations:
      - .codex/skills
    authoring: true

  generic:
    destinations:
      - .skills

  github:
    destinations:
      - .github/skills

defaults:
  tools:
    - codex
  authoring_tool: codex
```

### Project config example

```yaml
tools:
  - codex
  - github

extra_destinations:
  - .skills
```

### Promotion workflow

Recommended workflow:

1. Create a skill in the authoring destination.
2. Run `skill promote <name>`.
3. The CLI moves the directory into the canonical store.
4. The CLI links the stored version back into all configured destinations.

If the authoring destination is missing but exactly one mirror destination contains the local skill directory, `promote` uses that mirror as a fallback and emits a note.
If multiple destinations contain local directories with the same skill name, `promote` fails closed.

### First-run setup

Initialize the central config with:

```sh
skill config init
```

That writes `~/.config/skill/config.yml` from `skill/config/default-config.yml` and refuses to overwrite an existing config.

The usual first checks after setup are:

```sh
skill status
skill doctor
```

### Symlink behavior

Linked skills use relative symlinks where possible so project links remain portable when inspected or moved with the project directory structure intact.

## Useful Commands

Run the CLI entrypoint:

```sh
skill help
skill list
skill status
skill doctor
```

Run the implementation directly:

```sh
ruby skill/src/cli.rb help
ruby skill/src/cli.rb list
```

Lint:

```sh
make lint
```

Tests:

```sh
make test
```

Syntax check:

```sh
ruby -c scripts/skill
ruby -c skill/src/cli.rb
ruby -c skill/src/skill/doctor.rb
ruby -c skill/src/skill/error.rb
ruby -c skill/src/skill/filesystem.rb
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
- When changing command behavior, update or add tests in `skill/test/cli_test.rb` first when practical.
- Preserve Ruby 2.6 compatibility.
- Prefer stdlib-only dependencies unless there is a strong reason not to.
- Keep config and destination policy understandable from CLI output and README examples.
