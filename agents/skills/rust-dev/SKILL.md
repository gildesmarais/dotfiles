---
name: rust-dev
description: >-
  Language-runtime adapter loaded by $dev. Not the Build entry. Use when $dev
  routed here or the user names this skill with $dev already loaded. Rust
  deltas: compat ask, cargo validation, crate docset cues.
---

# Rust Dev

Follow `$dev` for classify, shared stance, API truth / Dash recipe, workflow/plan, validation law, phase commits, and handoff skeleton. This pack adds Rust deltas only. Craft (modules, types, measured perf) lives in `architecture` — do not inline it here.

## When to use

- Loaded by `$dev` for Rust implementation work.
- Explicit `@rust-dev` / `$rust-dev` compose when `$dev` is already loaded.
- Compose sibling guideline or domain skills when they apply; never paste their contents into this workflow.

## Docsets

- Prefer Dash docsets: **Rust** / installed crate docs. Secondary: `cargo doc` and local usage.

## Stance deltas

- Compatibility is context-gated. Detect whether the change surface is internal-only or a stable public contract. If unsure whether a break is allowed, **ask** before shipping. No silent shim theater; no silent breaks on surfaces treated as stable.
- Evidence: touched modules, public contracts, real call sites, existing tests, compat posture (ask if unclear).

## Surgical posture

- Preserve behavior unless the ask is an intentional break and compat allows it.
- Add or tighten a focused test when the failure can be expressed cheaply.
- Validate with the narrowest repo-native command that covers the change.

## Tooling

- Use repo-native entrypoints (`cargo test`, `cargo clippy`, project wrappers, `mise exec --`, Make targets). Prefer a ready, documented target over inventing one-off commands.
- Start narrow (touched crate/module/tests), then broaden when the change crosses seams.

## Contracts

- Preserve existing repo conventions for contracts and docs.
- Do not invent a new global docs regime.
- If a touched public API already has docs or contract comments, keep them accurate in scope.

## Handoff deltas

Before handoff (on top of `$dev` skeleton), confirm:

- Compat decision stated, or that the user was asked.
- Residual risk, unverified paths, and intentional out-of-scope work called out.
