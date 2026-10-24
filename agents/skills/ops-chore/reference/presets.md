# Presets

Scope and band coverage for irregular ops runs.

## Lookback Resolution

1. User window.
2. Prior Ops Ledger `Window.end` → now (same service only).
3. Defaults: **14d** (`full` / unadorned), **2h** (`post-deploy`).
4. Ask at most once if window is ambiguous and no deploy cue exists.

## Trigger Mapping

| Trigger | Preset |
| --- | --- |
| `/ops-chore`, "ops chore", "run ops" | Smart default (≤3d lookback → `quick`, else `full`) |
| "weekly ops", "full ops", "deep APM", "datadog" | `full` |
| "quick ops", "APM chores", "integrity" | `quick` |
| "post-deploy", "after deploy", "collector check" | `post-deploy` |
| "apply dashboard" alone | `full` (14d or prior ledger; forces band 7) |

## Bands by Preset

- **`quick`**: Bands 1 (Integrity), 2 (Queue & exceptions), 4 (Disk %), 3 (API p95; admit Strong). Bands 5 (Product) and 6 (Security) N/A unless integrity shows WARN/ERROR spike. Dashboard apply only if requested or panel query is Strongly wrong.
- **`full`**: Bands 1–6 required. APM golden paths; admit all Strong fixes. Late recurring jobs and security fingerprints required. Dashboard apply if live board differs from generator output for admitted fix, or user requested.
- **`post-deploy`**: Lookback 2h. Band 1 (streams, `otelcol_*`, accessory), Band 2 (heartbeat/ready, new exception classes, 5xx smoke excluding probes). Band 5 only if tick in-window. Dashboard apply N/A unless deploy touched monitoring JSON.
