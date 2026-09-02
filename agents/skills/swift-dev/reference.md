# swift-dev reference

Optional language-only harvest companion. Architecture craft lives on `architecture` branch refs via the harvest protocol (stage → sparse-promote → drop) — never duplicate it here as a parallel doctrine log.

Grow this file only for Swift/Apple-specific lessons that cannot be stated language-free. Abstract product nouns out. Cap ~10 new bullets per harvest unless the user asks for more.

Routine surgical fixes do not grow this file.

## Measured perf (Swift / Apple Silicon)

Apply only after `$dev` → `architecture` **`performance`** stop rules hand off for language recipes. Measure first; these are not defaults.

- **UMA / shared storage.** Prefer `MTLResourceStorageModeShared` or page-aligned VM buffers when CPU and GPU/ANE must see one physical buffer; prove no bounce copy in Metal System Trace.
- **Numeric dispatch by workload shape.** Contiguous Accelerate / `vDSP` (AMX-backed where applicable) for BLAS-like work; custom `MTLComputePipelineState` when the kernel is not in Accelerate; Core ML `.cpuAndNeuralEngine` / `.all` only for model/tensor graphs that fit ANE constraints.
- **Codegen as build contract.** `@inlinable` and whole-module / cross-module optimization are build settings — do not sprinkle `@inlinable` as cargo cult.
- **Unsafe scope.** `withUnsafeBytes` / `UnsafeMutableBufferPointer` only on proven hot loops to enable LLVM autovec; keep unsafe regions tiny and tested.
- **Concurrency & QoS.** Task groups on the cooperative pool; avoid thread explosion. Set QoS explicitly for P-core vs E-core intent (`.userInitiated` / `.userInteractive` for heavy compute; `.utility` / `.background` for background I/O).
- **MainActor protection.** Coalesce high-frequency progress callbacks from background work so the main event loop is not saturated.
- **Verification.** Instruments Time Profiler, Allocations, Metal System Trace — flame graphs should show reduced ARC retain/release and dynamic dispatch on the hot path.

## Optional shapes (examples, not law)

When the measured hot path looks like these patterns, prefer the matching posture — do not apply as blanket defaults:

- **Multi-channel distance / embeddings:** `SIMD3`/`SIMD4` or Accelerate `vDSP` over contiguous buffers rather than scalar loops with formatting.
- **Monotonic coordinate maps (scrubbing):** sort on ingestion; binary search on tick rather than re-sort or linear scan each frame.
- **Equatable / table diffing:** compare contiguous underlying storage; never allocate or flatten inside `==`.
