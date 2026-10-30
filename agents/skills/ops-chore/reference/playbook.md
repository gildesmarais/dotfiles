# Playbook

Evidence labels Strong / Worth / Speculative. Every Strong finding admits per `ledger.md`; none edits code.

| Preset | Bands |
| --- | --- |
| `quick` | 1, 2, 3, 4; 5–6 only if integrity shows a WARN/ERROR spike; 7 only if requested or a panel query is Strongly wrong |
| `post-deploy` | 1 (streams, exporter sent/failed/refused, accessories), 2 (heartbeat/ready, new exception classes, 5xx excluding probes); 5 only if a tick falls in-window; 7 only if the deploy touched monitoring JSON |
| `full` | 1–6; 7 if live board differs from generator output for an admitted fix, or requested |

## 1. Observability integrity

Streams/indexes, exporter sent/failed/refused counters, severity histogram (empty/`0` severity). Post-deploy: a missing series is a Strong host/accessory issue, not app code.

## 2. Reliability & queues

Repo-exported queue/job gauges; exceptions by type and frame; unresolved or regressed error-tracker issues for this service; scheduled jobs against repo schedule definitions; notification/mailer failures. Admit service fixes (health-check text, discardable failed jobs with guards, broken schedules) or host seeds.

## 3. APM

Rank server spans by p95 on routes the repo declares; slow SQL where the backend exposes it. For each Strong slow route name the bottleneck class (placement, N+1, cache-key cost, outbound I/O), target files, and a one-line rejected alternative. External latency: defer, or admit timeouts/circuit breakers.

## 4. Capacity & cost

Disk % and trend toward 85%; span/log volume and export noise. Host paths become seeds; collector filter/sampling changes are admitted items.

## 5. Product golden paths

Repo-defined product events, notification outcomes, late scheduled jobs; none defined → N/A. Missing events: admit instrumentation only with Strong code evidence, else `product-owner`.

## 6. Security skim

Throttle hits, framework-protection events, scanner fingerprints. Admit matcher updates for new public endpoints.

## 7. Dashboard apply

Triggers: user asked; a live panel query differs from generator output; an admitted panel fix landed on the named branch and apply was requested. List the repo-owned folder, read the board's id and hash (re-list on 404). Generator must change → admit it, never hand-edit. Repo JSON current and live stale → update with the full body; record id and hash.
