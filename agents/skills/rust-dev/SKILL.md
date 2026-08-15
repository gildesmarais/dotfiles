---
name: rust-dev
description: >-
  Always load $dev first; this pack is deltas only. Language-runtime adapter
  loaded by $dev — not the Build entry. Use when $dev routed here or the user
  names this skill with $dev already loaded. Rust deltas: cargo validation,
  crate docset cues, depth-pack compose.
---

# Rust Dev

**Stop:** read `$dev` Shared prep before any delta.

Follow `$dev` for classify, shared stance, API truth / Dash recipe, compat ask, no-destructive git, workflow/plan, validation law, phase commits, and handoff skeleton. This pack adds Rust deltas only. Craft (modules, types, measured perf) lives in `architecture` — do not inline it here.

## When to use

- Loaded by `$dev` for Rust implementation work.
- Explicit `@rust-dev` / `$rust-dev` compose when `$dev` is already loaded.
- Compose sibling guideline or domain skills when they apply; never paste their contents into this workflow.

## Docsets

- Prefer Dash docsets: **Rust** / installed crate docs. Secondary: `cargo doc` and local usage.

## Stable-surface hints

- Treat crate public API / semver-stable surfaces and documented FFI boundaries as stable unless the ask or `AGENTS.md` says otherwise.

## Stance deltas

- Evidence: touched modules, public contracts, real call sites, existing tests, compat posture (ask via `$dev` if unclear).

## Surgical posture

- Preserve behavior unless the ask is an intentional break and compat allows it.
- Add or tighten a focused test when the failure can be expressed cheaply.
- Validate with the narrowest repo-native command that covers the change.
- Load language-specific harvest postures in [`reference.md`](reference.md) when crate/toolchain conventions apply.

## Tooling

- Use repo-native entrypoints (`cargo test`, `cargo clippy`, project wrappers, `mise exec --`, Make targets). Prefer a ready, documented target over inventing one-off commands.
- Start narrow (touched crate/module/tests), then broaden when the change crosses seams.

## Contracts

- Preserve existing repo conventions for contracts and docs.
- Do not invent a new global docs regime.
- If a touched public API already has docs or contract comments, keep them accurate in scope.

## Compose routes

Pointers only — load when present; do not paste their bodies here:

- Store depth → `ms-rust`, `rust-performance` when installed / applicable.

## Handoff deltas

Before handoff (on top of `$dev` skeleton), confirm:

- Residual risk, unverified paths, and intentional out-of-scope work called out.
