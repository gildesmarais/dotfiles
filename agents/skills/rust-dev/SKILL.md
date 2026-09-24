---
name: rust-dev
description: >-
  Rust deltas loaded by $dev (load $dev first; not a Build entry): cargo
  validation, crate docsets, depth-pack compose; after a measured-perf handoff,
  cargo-asm, Criterion, target-cpu, io_uring recipes.
---

# Rust Dev

**Stop:** read `$dev` Shared prep before any delta. Craft lives in `architecture`; compose sibling skills by name, never paste them.

## Docsets

Dash: **Rust** / installed crate docs. Secondary: `cargo doc`, local usage.

## Stable surfaces

Crate public API / semver-stable surfaces and documented FFI boundaries — unless the ask or `AGENTS.md` says otherwise.

## Deltas

- Entrypoints: `cargo test`, `cargo clippy`, project wrappers, `mise exec --`, Make targets.
- Measured perf / hot path → `$dev` `design` → `architecture` `performance`; then Rust recipes in [`reference.md`](reference.md).
- Third-party Rust guideline packs: compose when installed.
