# swift-dev reference

Swift/Apple-only lessons; craft → `architecture`. ≤~10 bullets per harvest.

## Measured perf (Swift / Apple Silicon)

Only after `architecture` `performance` stop rules hand off. Measure first; not defaults.

- **UMA / shared storage.** `MTLResourceStorageModeShared` or page-aligned VM buffers when CPU and GPU/ANE share one buffer; prove no bounce copy in Metal System Trace.
- **Numeric dispatch by workload.** Accelerate / `vDSP` for contiguous BLAS-like work; custom `MTLComputePipelineState` when Accelerate lacks the kernel; Core ML `.cpuAndNeuralEngine` / `.all` only for graphs fitting ANE constraints.
- **Codegen is a build contract.** `@inlinable` and whole-/cross-module optimization are build settings, not sprinkles.
- **Unsafe scope.** `withUnsafeBytes` / `UnsafeMutableBufferPointer` only on proven hot loops; tiny and tested.
- **Concurrency & QoS.** Task groups on the cooperative pool; no thread explosion. Explicit QoS: `.userInitiated` / `.userInteractive` for heavy compute, `.utility` / `.background` for I/O.
- **MainActor protection.** Coalesce high-frequency background progress callbacks.
- **Verification.** Time Profiler, Allocations, Metal System Trace — expect less ARC retain/release and dynamic dispatch on the hot path.

Shapes (when the measured path matches): Multi-channel distance → `SIMD3`/`SIMD4` or `vDSP`. Monotonic coordinate maps → sort on ingestion; binary search per tick. Equatable / table diffing → compare contiguous storage; never allocate inside `==`.

## Concurrency, TLS & foreign-exception hardening

Swift Concurrency keeps thread-local task state. ObjC/foreign exceptions unwind frames without running its exit handlers, corrupting TLS when host runloops swallow them.

- **No `Thread.isMainThread` sniffing** to branch between `MainActor.assumeIsolated` and `Task`: on poisoned TLS `assumeIsolated` crashes later. Declare isolation natively or dispatch `Task { @MainActor [weak self] in ... }`.
- **Clamp text-storage ranges.** Storage mutates across runloop ticks; guard attribute removals with validated clamps.
- **Detach the storage delegate during bulk edits & undo.** `textStorage.delegate = nil` (restored via `defer`) around programmatic replaces so `didProcessEditing` cannot re-enter.
- **Fail fast on swallowed exceptions.** `"NSApplicationCrashOnExceptions": true` in `UserDefaults` + `NSSetUncaughtExceptionHandler` in the app delegate.
