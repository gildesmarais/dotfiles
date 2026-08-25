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
      error.rb
      filesystem.rb
      operations.rb
      paths.rb
      ui.rb
  test/
    cli_test.rb
    unit_test.rb
```

- `src/cli.rb`: command parsing, dispatch, and help output
- `src/skill/paths.rb`: canonical store, home, and project path resolution
- `src/skill/classifier.rb`: closed status set and real-file drift detection
- `src/skill/filesystem.rb`: shared skill-name safety helpers
- `src/skill/error.rb`: shared CLI exit/error object used below the entrypoint
- `src/skill/operations.rb`: list / doctor / backfill / promote / rename behavior
- `src/skill/ui.rb`: CLI output and fatal error helpers
- `test/cli_test.rb`: characterization tests for command parsing and filesystem behavior
- `test/unit_test.rb`: direct object tests for classifier and operation edge cases
- `../scripts/skill`: thin executable entrypoint

## Useful Commands

Run the CLI entrypoint:

```sh
./scripts/skill help
./scripts/skill list
./scripts/skill doctor
./scripts/skill backfill my-skill
./scripts/skill promote my-skill
./scripts/skill rename ruby-dev ruby
```

Expected results:

- `doctor` prints aligned columns (padded name, then status: `ok`, `drift`, `home-only`, `broken`); exits `0` when no `drift`, else `1`
- Agent install listing includes skill directories (and broken skill symlinks for `broken` status); excludes vocabulary file symlinks such as `CONTEXT.md`
- `backfill <name>` prints each copied relative path, notes an `rcup` hint, and refuses home-only / broken / no-drift / missing store skills
- After `backfill`, run `rcup` (or wait for topgrade) so `~/.agents/skills` matches the store again

Run the implementation directly:

```sh
ruby skill/src/cli.rb help
ruby skill/src/cli.rb list
ruby skill/src/cli.rb doctor
```

Lint and tests (quality gate):

```sh
make lint test
```

Syntax check:

```sh
ruby -c scripts/skill
ruby -c skill/src/cli.rb
ruby -c skill/src/skill/classifier.rb
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
- Status and drift live only in `Skill::Classifier`; doctor/backfill must not re-derive them.
- When changing command behavior, update or add tests in `skill/test/cli_test.rb` first when practical.
- Preserve Ruby 2.6 compatibility.
- Prefer stdlib-only dependencies unless there is a strong reason not to.
- First-party agent install is via `rcup` from `agents/skills/<name>/` into `~/.agents/skills/<name>/`. After `promote` / `rename` / `backfill`, run `rcup` (or wait for topgrade).
