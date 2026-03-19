# Skill CLI

This directory contains the implementation and tests for the `skill` command.

## Layout

```text
skill/
  README.md
  src/
    cli.rb
  test/
    cli_test.rb
```

- `src/cli.rb`: main Ruby implementation for the skill manager CLI
- `test/cli_test.rb`: characterization tests for command parsing and filesystem behavior
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
ruby -c skill/test/cli_test.rb
```

Run tests:

```sh
ruby -Iskill/test skill/test/cli_test.rb
```

Run tests with the macOS system Ruby 2.6:

```sh
/System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/bin/ruby -Iskill/test skill/test/cli_test.rb
```

## Notes For AI Agents

- Prefer changing `skill/src/cli.rb` and keeping `scripts/skill` as a tiny entrypoint.
- When changing command behavior, update or add tests in `skill/test/cli_test.rb` first when practical.
- Preserve Ruby 2.6 compatibility.
- Prefer stdlib-only dependencies unless there is a strong reason not to.
