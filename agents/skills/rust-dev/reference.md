# rust-dev reference

Optional language-only harvest companion. Architecture craft lives on `architecture` branch refs via the harvest protocol (stage → sparse-promote → drop) — never duplicate it here as a parallel doctrine log.

Grow this file only for Rust-specific lessons that cannot be stated language-free (e.g. crate/API pitfalls, cargo/toolchain conventions). Abstract product nouns out. Cap ~10 new bullets per harvest unless the user asks for more.

Routine surgical fixes do not grow this file.

## Measured perf (Rust runtime)

Apply only after `$dev` → `architecture` **`performance`** stop rules hand off for language recipes. Measure first; these are not defaults.

- **Portable default, native opt-in.** `target-cpu = "native"` / host CPU flags are for local or explicitly tuned builds. Shipped and CI artifacts use explicit triples or runtime feature detection — never make “native” the silent crate default.
- **Autovec before intrinsics.** Prefer contiguous slices, `chunks_exact` / exact splits, and iterator shapes that remove bounds checks. Prove with `cargo-asm` or Compiler Explorer that LLVM failed before reaching for `core::arch` or portable SIMD.
- **Allocations off the hot path by ownership.** Pre-size and reuse buffers at the seam that owns the stage; do not sprinkle object pools without a measured alloc profile.
- **mmap is a read-mostly tool.** Map large cold datasets when page-fault + OS cache economics win; do not treat mmap as free RAM or a substitute for a measured streaming design.
- **Linux I/O amplification ≠ automatic `io_uring`.** Reach for uring when syscall/completion cost dominates; treat SQPOLL as privileged/expensive and non-default. Non-Linux keeps the portable async or blocking path.
- **GPU compute after CPU SIMD ceiling.** `wgpu` / native compute only when the profiled stage is data-parallel and transfer cost is paid for; keep a CPU reference path.
- **Verification ladder.** Criterion baseline → optimized; `cargo-asm` for hot loops; `perf` / `samply` / Instruments for stalls and cache — stop when the measured budget is met.
