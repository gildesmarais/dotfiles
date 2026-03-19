# Skill CLI

This directory contains the implementation and tests for the `skill` command.

## Layout

```text
skill/
  README.md
  src/
    cli.rb
    skill/
      doctor.rb
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
- `src/skill/paths.rb`: canonical store and project path resolution
- `src/skill/filesystem.rb`: shared symlink and skill-name safety helpers
- `src/skill/error.rb`: shared CLI exit/error object used below the entrypoint
- `src/skill/operations.rb`: skill list/status/link/unlink/clean/adopt/promote/rename behavior
- `src/skill/doctor.rb`: doctor scan and reporting behavior
- `src/skill/ui.rb`: CLI output and fatal error helpers
- `test/cli_test.rb`: characterization tests for command parsing and filesystem behavior
- `test/unit_test.rb`: direct object tests for operation and doctor edge cases
- `../scripts/skill`: thin executable entrypoint

## Useful Commands

Run the CLI entrypoint:

```sh
./scripts/skill help
./scripts/skill list
./scripts/skill status
./scripts/skill doctor
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
