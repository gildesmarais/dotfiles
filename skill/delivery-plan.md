# Skill CLI Delivery Plan

## Goal

Evolve the `skill` CLI from a single hardcoded project destination (`.codex/skills`) into a small, dependable utility that:

- keeps the dotfiles `skills/` directory as the canonical store
- supports configurable project-local skill destinations
- supports multiple linked destinations to cover tool mismatch
- introduces a centralized config for known AI agent/tool preferences
- preserves safe filesystem behavior and Ruby 2.6 compatibility

This plan is intentionally implementation-oriented and avoids unnecessary abstraction.

## Current Intent

The intended workflow is:

1. A user or agent creates a skill locally in a project.
2. The CLI promotes that skill into the central store.
3. The CLI links the stored version back into one or more project-local destinations.
4. Different tools can find skills where they expect them.

Canonical store remains:

- `~/.dotfiles/skills`

Project destinations should become configurable instead of hardcoded to:

- `.codex/skills`

Examples of additional destinations to support:

- `.skills`
- `.github/skills`

## Constraints

- Ruby must remain compatible with macOS system Ruby 2.6.
- Prefer stdlib only.
- `scripts/skill` must remain a thin launcher.
- Hidden store directories remain excluded from listing and bulk linking.
- The CLI should fail closed on ambiguous or unsafe filesystem states.
- CLI behavior should stay understandable from output alone.
- Prefer direct Ruby code over indirection-heavy design.

## Review Summary Of Current Draft

The current draft moves in the right direction, but it is incomplete and not yet a stable architecture.

### What is good

- Introduces configurable destinations instead of hardcoding only `.codex/skills`.
- Starts moving path resolution through config.
- Starts scanning multiple destinations in `status`, `doctor`, `clean`, `link`, and `promote`.

### Main gaps

1. Config is project-local only.
   It loads `.skill.yml` from the project root, but there is no central registry of known tool preferences.

2. There is no authoritative authoring destination.
   `promote` scans all configured destinations and picks the first local directory it finds, which is ambiguous.

3. Name mapping is only partially wired.
   `doctor` knows about mapping, but mutating operations still assume store name == project link name.

4. Multi-destination failure behavior is not fully defined.
   Some operations now log-and-continue instead of failing closed.

5. Tests and README were not updated with the new contract.

## Target Architecture

Keep the architecture small and direct. Use a few focused Ruby files with concrete responsibilities.

### Proposed files

- `src/skill/config.rb`
  Loads and merges built-in defaults, central config, and project-local overrides.

- `src/skill/layout.rb`
  Resolves active tool profiles into concrete destination paths for the current project.

- `src/skill/state.rb`
  Inspects filesystem state for a skill across configured destinations.

- `src/skill/paths.rb`
  Keeps simple path helpers and project/store root detection.

- `src/skill/operations.rb`
  Performs filesystem mutations using resolved layout/state results.

- `src/skill/doctor.rb`
  Reports health using the same state classification logic.

This is still a direct Ruby design. It avoids service-object sprawl and keeps policy from leaking into every command.

## Configuration Model

Use a two-layer model.

### 1. Central config

Lives in dotfiles and defines known tool preferences.

Responsibilities:

- canonical store location
- known tool profiles
- destination preferences per tool
- default tool selection
- optional authoring tool default
- optional ignore / required defaults

Example shape:

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
```

### 2. Project-local config

Lives in the project root as `.skill.yml`.

Responsibilities:

- select active tools for this project
- add extra destinations if needed
- override authoring tool
- define ignore / required skill names

Example shape:

```yaml
tools:
  - codex
  - github

authoring_tool: codex

extra_destinations:
  - .skills

ignore:
  - secret-skill

required:
  - ruby-expert
```

### Notes

- Defer `name_mappings` unless a real tool requires it.
  It adds complexity across every mutating command.
- Keep keys and values simple and explicit.
- Normalize all config data once after load.

## Resolved Layout

Add one resolved layout step per CLI invocation.

The resolved layout should answer:

- what is the canonical store directory
- which tool profiles are active
- which project destination is the authoring destination
- which destinations are mirrors
- which destinations are all active destinations
- which skills are ignored
- which skills are required

Example normalized result:

```ruby
{
  "store_dir" => "/Users/gil/.dotfiles/skills",
  "authoring_destination" => "/repo/.codex/skills",
  "mirror_destinations" => [
    "/repo/.skills",
    "/repo/.github/skills"
  ],
  "all_destinations" => [
    "/repo/.codex/skills",
    "/repo/.skills",
    "/repo/.github/skills"
  ],
  "required_skills" => ["ruby-expert"],
  "ignored_skills" => ["secret-skill"]
}
```

This should be plain Ruby data, not a deep object graph.

## Destination State Classification

Add one shared state scan helper used by `promote`, `link`, `unlink`, `status`, `clean`, `rename`, and `doctor`.

For each destination and skill name, classify the path as one of:

- `:missing`
- `:local_directory`
- `:symlink_to_store`
- `:symlink_elsewhere`
- `:broken_symlink`
- `:foreign_file`

Example result:

```ruby
[
  { path: "/repo/.codex/skills/my-skill", kind: :local_directory },
  { path: "/repo/.skills/my-skill", kind: :missing },
  { path: "/repo/.github/skills/my-skill", kind: :symlink_to_store }
]
```

This avoids repeating path classification logic across commands and keeps behavior aligned.

## Authoring Model

Introduce one clear rule:

- exactly one destination is the authoring destination
- all other configured destinations are mirrors

This removes ambiguity in the common workflow where an agent creates a skill locally before promotion.

### Recommended workflow

1. Agent creates the skill in the authoring destination.
2. User runs `skill promote <name>`.
3. CLI moves the directory into the central store.
4. CLI creates symlinks in all configured destinations.

### Why this matters

Without an authoring destination, `promote` must guess among several locations, which is unsafe and hard to reason about.

## Command Semantics

### `link <name>`

- Link the stored skill into all active destinations.
- Create missing destination directories as needed.
- Exit non-zero if any destination could not be linked.
- Do not overwrite foreign paths or foreign symlinks.

### `link --all`

- Link all non-hidden, non-ignored store skills into all active destinations.
- Report per-destination failures.
- Exit non-zero if any requested link failed.

### `unlink <name>`

- Remove matching symlinks from all active destinations.
- Refuse to remove non-symlink paths.
- Exit non-zero if any destination is in a conflicting state.

### `promote <name>`

Default behavior:

1. Inspect the authoring destination first.
2. If `<authoring_destination>/<name>` is a local directory, promote it.
3. If it is already linked to store, report already promoted.
4. If it is missing, optionally inspect mirrors for legacy fallback behavior.
5. If more than one destination contains a local directory, fail closed.
6. After moving to store, link back into all active destinations.
7. Exit non-zero if any destination could not be linked.

### `rename <old> <new>`

- Rename the skill in the store.
- Update matching symlinks in all active destinations.
- Refuse if the new project path already exists in any destination.
- Exit non-zero if any destination conflicts.

### `doctor`

- Validate every active destination.
- Report missing destination directories as warnings unless the authoring destination is required.
- Report local directories, foreign files, broken symlinks, and symlinks outside store.
- Report required skills not linked where expected.

### `status`

- Show one grouped section per destination.
- Display linked, broken, local, and file states.

## Failure Policy

Prefer explicit, safe behavior.

Recommended policy:

- refuse to overwrite existing files or directories
- refuse to replace symlinks that point somewhere unexpected
- refuse ambiguous promotion cases
- process all destinations where reasonable
- exit non-zero if any required destination operation failed

This keeps the CLI safe while still giving complete reporting for multi-destination operations.

## Delivery Stages

Implement in small stages.

### Stage 1: Config and layout

Deliverables:

- central config file location and format
- project-local config format
- config merge logic
- resolved layout logic
- tests for config precedence and destination resolution

Success criteria:

- current hardcoded `.codex/skills` behavior still works by default
- project can opt into multiple destinations through config
- one authoring destination is always resolved

### Stage 2: Shared destination state scanning

Deliverables:

- one helper for classifying destination state
- refactor `status` and `doctor` to use it
- tests for all destination state kinds

Success criteria:

- `status` and `doctor` report consistent state
- no duplicated state-classification logic across commands

### Stage 3: Mutating commands on top of resolved state

Deliverables:

- refactor `link`, `unlink`, `clean`, `promote`, and `rename`
- define and enforce multi-destination failure semantics
- make `promote` authoring-destination-first
- tests for ambiguous promote and partial destination conflicts

Success criteria:

- `promote` no longer picks arbitrary local directories
- all mutating commands behave consistently across destinations
- CLI exits non-zero on real conflicts

### Stage 4: Documentation and compatibility cleanup

Deliverables:

- update `README.md`
- update CLI help text where needed
- add usage examples for central config and multi-destination projects
- run full quality gate

Success criteria:

- docs match behavior
- `make lint test` passes

## Maintainability Guidelines

- Keep command logic direct.
- Prefer small helper methods over new abstraction layers.
- Keep YAML parsing and normalization in one place.
- Keep destination-state inspection in one place.
- Keep file mutation logic in `operations.rb`.
- Avoid name remapping until it is actually needed.
- Avoid meta-programming and clever Enumerable chains.
- Prefer explicit loops and early returns.

## Ruby 2.6 Style Guidelines

- stdlib only
- plain hashes / arrays for normalized config and state
- explicit string-key handling for YAML data
- simple helper methods with narrow responsibilities
- avoid newer Ruby features not available in 2.6

Prefer:

- `each`
- `each_with_object`
- `next`
- early return
- direct conditional branches

Avoid:

- indirection-heavy service layers
- clever DSLs
- unnecessary `Struct` or class proliferation
- symbol/string key mixing from YAML

## Test Matrix

Add or update tests for:

- default config resolves to `.codex/skills`
- central config adds known tool destinations
- project config selects multiple active tools
- exactly one authoring destination is resolved
- `link` links into all active destinations
- `link` refuses foreign paths in one destination and exits non-zero
- `promote` succeeds from the authoring destination
- `promote` fails when two destinations contain local directories of the same name
- `promote` relinks all destinations after moving to store
- `doctor` reports missing / broken / local / foreign states per destination
- `rename` updates matching symlinks across all destinations
- hidden store entries remain ignored

## Open Decisions

These decisions should be made before implementation starts:

1. Where should the central config live exactly?
   Likely under dotfiles, but choose one stable path.

2. Should mirror destination failures be fatal?
   Recommended: yes, for mutating commands.

3. Should missing mirror directories be auto-created?
   Recommended: yes, when linking or promoting.

4. Do any tools actually require different skill names?
   If not, defer name mapping.

5. Should `promote` support `--from <tool|path>` in v1?
   Recommended: no, unless a real use case already exists.

## Accepted Decisions

The following decisions are now fixed for implementation unless explicitly changed later.

### Config locations

- Central config path: `~/.config/skill/config.yml`
- Project-local config path: `<project>/.skill.yml`

### Config precedence

Merge in this order:

1. built-in defaults
2. central config
3. project-local config

Project-local config may:

- override selected tools
- override the authoring tool
- extend destinations where supported by the schema
- set project-local `ignore` and `required`

### Tool selection

- Default active tool set is `codex` only.
- Exactly one `authoring_tool` must be resolved per project.
- If not explicitly set by the project, the resolved authoring tool should come from central config defaults.

### Promote behavior

- `promote` fails hard if more than one destination contains a local directory for the same skill.
- If the authoring destination is missing but exactly one mirror destination contains the local skill directory, `promote` may use it as a compatibility fallback and must emit a warning.
- `promote` should not guess among multiple local directories.

### Mutating command failure behavior

- `link`, `link --all`, `unlink`, `promote`, `rename`, and similar mutating commands should attempt all relevant destinations where practical.
- If any destination operation fails, the command exits non-zero after reporting all results.
- The CLI must not overwrite foreign files, directories, or unexpected symlinks.

### Destination directory creation

- Missing destination directories should be auto-created for `link` and `promote`.

### Name mapping

- Defer `name_mappings` from v1 unless a real tool requires it.

### Doctor behavior

- Missing mirror destinations are warnings.
- Problems in the authoring destination are issues when they block the expected workflow.

### Symlink policy

- Prefer relative symlinks if implemented safely.
- If relative symlinks materially complicate correctness, keep absolute symlinks in v1 and revisit later.

### Documentation

- Proper documentation is part of delivery, not follow-up work.
- The out-of-the-box central config template must be documented with inline comments.
- `README.md` must explain the final config model and workflow.

## Final Implementation Checklist

This is the concrete execution order for autonomous delivery.

### 1. Add config files and schema support

- Add support for reading `~/.config/skill/config.yml`
- Keep support for `<project>/.skill.yml`
- Normalize config after load:
  - expand `~`
  - resolve store path
  - normalize tool names and destination arrays
  - validate that one authoring tool can be resolved
- Add a documented default central config template in the repo

Suggested repository addition:

- `config/default-config.yml`
  or
- `templates/config.yml`

The template should be heavily commented and safe as the documented OOTB example.

### 2. Implement resolved layout logic

- Compute active tools from defaults + central config + project overrides
- Resolve exactly one authoring destination
- Resolve mirror destinations
- Resolve full destination list without duplicates
- Resolve ignored and required skill lists

Keep this logic explicit and Ruby 2.6-friendly.

### 3. Implement shared destination-state inspection

- Add one helper that classifies each destination path for a given skill
- Reuse it across `status`, `doctor`, `link`, `unlink`, `promote`, `clean`, and `rename`
- Keep the returned state as plain hashes or simple Ruby objects

### 4. Refactor non-mutating commands first

- Update `status` to render grouped output per destination
- Update `doctor` to use the shared state scan
- Make `doctor` distinguish warnings vs issues using the accepted policy

This stage should stabilize reporting before changing mutating behavior.

### 5. Refactor mutating commands

- `link`
- `link --all`
- `unlink`
- `clean`
- `promote`
- `rename`

For `promote` specifically:

1. inspect authoring destination first
2. use single-mirror fallback only when unambiguous
3. fail hard on multiple local directories
4. move to store
5. relink to all configured destinations
6. exit non-zero if any relink step fails

### 6. Update CLI help and README

- Explain central config path
- Explain project config path
- Explain authoring vs mirror destinations
- Explain default tool behavior
- Explain promotion workflow
- Explain failure semantics for multi-destination operations
- Include example configs

### 7. Add tests before final handoff

At minimum:

- central config discovery at `~/.config/skill/config.yml`
- config precedence between defaults, central config, and project config
- default `codex` destination behavior
- one authoring destination resolution
- multi-destination linking
- partial multi-destination conflict causing non-zero exit
- unambiguous mirror fallback in `promote`
- ambiguous `promote` failure on multiple local directories
- `doctor` warnings for missing mirror destinations
- `doctor` issues for authoring-destination problems
- documentation-sensitive behavior reflected in CLI help text where appropriate

### 8. Final validation

Run the required quality gate:

```sh
make lint test
```

Do not hand off until it passes.

## Recommended First Implementation Order

When work resumes, take this order:

1. Define central config file path and schema.
2. Implement config merge and resolved layout.
3. Add destination-state classification helper.
4. Refactor `status` and `doctor` first.
5. Refactor `link` and `unlink`.
6. Refactor `promote`.
7. Refactor `rename` and `clean`.
8. Update README and tests.
9. Run `make lint test`.

## Handoff Summary

The core design decision is:

- one canonical store
- one explicit authoring destination
- zero or more mirror destinations
- centralized tool preference config
- project-level tool selection and overrides
- one shared destination-state classifier

Keep the implementation small, direct, and idiomatic Ruby 2.6.
