# swift-dev reference

Swift/Apple-only lessons; craft → `architecture`.

## Measured perf (Swift / Apple Silicon)

Only after `architecture` `performance` stop rules hand off. Measure first; not defaults.

- **UMA / shared storage.** `MTLResourceStorageModeShared` or page-aligned VM buffers when CPU and GPU/ANE share one buffer; prove no bounce copy in Metal System Trace.
- **Numeric dispatch by workload.** Accelerate / `vDSP` for contiguous BLAS-like work; custom `MTLComputePipelineState` when Accelerate lacks the kernel; Core ML `.cpuAndNeuralEngine` / `.all` only for graphs fitting ANE constraints.
- **Codegen is a build contract.** `@inlinable` and whole-/cross-module optimization are build settings, not sprinkles.
- **Unsafe scope.** `withUnsafeBytes` / `UnsafeMutableBufferPointer` only on proven hot loops; tiny and tested.
- **Concurrency & QoS.** Task groups on the cooperative pool; no thread explosion. `.userInitiated` / `.userInteractive` for heavy compute, `.utility` / `.background` for I/O.
- **MainActor protection.** Coalesce high-frequency background progress callbacks.
- **Verification.** Time Profiler, Allocations, Metal System Trace; expect less ARC traffic and dynamic dispatch on the hot path.

Shapes: multi-channel distance → `SIMD3`/`SIMD4` or `vDSP`; monotonic coordinate maps → sort on ingestion, binary search per tick; table diffing → compare contiguous storage, never allocate inside `==`.

## Concurrency, TLS & foreign-exception hardening

ObjC/foreign exceptions unwind frames without running Swift Concurrency's exit handlers, corrupting thread-local task state when host runloops swallow them.

- **No `Thread.isMainThread` sniffing** to branch between `MainActor.assumeIsolated` and `Task`: on poisoned TLS `assumeIsolated` crashes later. Declare isolation natively or `Task { @MainActor [weak self] in ... }`.
- **Clamp text-storage ranges.** Storage mutates across runloop ticks; guard attribute removals with validated clamps.
- **Detach the storage delegate during bulk edits & undo.** `textStorage.delegate = nil` (restored via `defer`) so `didProcessEditing` cannot re-enter.
- **Fail fast on swallowed exceptions.** `"NSApplicationCrashOnExceptions": true` in `UserDefaults` + `NSSetUncaughtExceptionHandler` in the app delegate.
