---
name: rust-dev
description: >-
  Rust deltas: cargo validation, crate docsets, Criterion. Perf recipes in
  reference.md.
disable-model-invocation: true
---

# Rust Dev

**Stop:** apply `$dev` Shared prep first; skip if already read. Craft lives in `architecture`; compose sibling skills by name, never paste them.

## Docsets

Dash: **Rust** / installed crate docs. Secondary: `cargo doc`, local usage.

## Stable surfaces

Crate public API / semver-stable surfaces and documented FFI boundaries — unless the ask or `AGENTS.md` says otherwise.

## Deltas

- Entrypoints: `cargo test`, `cargo clippy`, project wrappers, `mise exec --`, Make targets.
- Measured perf / hot path → `$dev` `design` → `architecture` `performance`; then [`reference.md`](reference.md).
