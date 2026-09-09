# compile

The prompt compiler translates raw intent into a deterministic, bounded Intermediate Representation (IR). Do not mutate application code here.

## Core Directives (Less is More)

1. **Strict Mutation Whitelist:** Every task MUST have a `target_files` array. This is the absolute mutation boundary.
2. **Zero-Trust Verification Gate:** Every task MUST include a `verification_gate` containing a repo-native command (e.g., `make test`, `npm run lint`). Do not invent commands.
3. **No Speculative Features:** Reject prompts that introduce unearned complexity or drift from the documented golden paths.

## Grill Gate Ownership

Before emitting the canonical IR schema, the grill gate owns extracting explicit invariants, scoping each task's mutation whitelist, and gating unresolved trade-offs. Do not defer those interviews to `$dev plan` or encode unresolved choices in the IR.

## IR Schema Requirement

You must emit the following YAML structure to `.agents/compile/<slug>.yaml`. Every `target_files` value MUST be a YAML list of exact repository-relative paths; scalars, globs, directories, and prose bounds are invalid:

```yaml
prompt_compiler:
  version: "1.0"
  invariants:
    - "System contracts must remain unmodified."
  circuit_breaker:
    policy: "On repeated gate failure, reset working tree to last green task commit and halt"
    user_approved: false
  tasks:
    - id: "task_01"
      name: "Execute constrained task"
      target_files:
        - "src/domain/module.rb"
      read_context:
        - "src/domain/interface.rb"
      verification_gate: "rspec spec/domain/module_spec.rb"
      max_retries: 2
      status: pending
```
