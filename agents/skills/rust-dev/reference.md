# rust-dev reference

Rust-only lessons (crate/API pitfalls, cargo/toolchain conventions); craft → `architecture`. ≤~10 bullets per harvest.

## Measured perf (Rust runtime)

Only after `architecture` `performance` stop rules hand off. Measure first; not defaults.

- **Portable default, native opt-in.** `target-cpu = "native"` only for local/explicitly tuned builds; shipped and CI artifacts use explicit triples or runtime feature detection.
- **Autovec before intrinsics.** Contiguous slices, `chunks_exact`, bounds-check-free iterator shapes; prove LLVM failed (`cargo-asm` / Compiler Explorer) before `core::arch` or portable SIMD.
- **Allocations by ownership.** Pre-size and reuse buffers at the owning stage; no object pools without a measured alloc profile.
- **mmap is read-mostly.** Large cold datasets when page-fault + OS-cache economics win; not free RAM or a streaming substitute.
- **`io_uring` only when syscall/completion cost dominates** on Linux; SQPOLL is privileged and non-default. Non-Linux keeps the portable path.
- **GPU after the CPU SIMD ceiling.** `wgpu` / native compute only for data-parallel profiled stages whose transfer cost pays off; keep a CPU reference path.
- **Verification ladder.** Criterion baseline → optimized; `cargo-asm` for hot loops; `perf` / `samply` / Instruments for stalls and cache — stop at the measured budget.
