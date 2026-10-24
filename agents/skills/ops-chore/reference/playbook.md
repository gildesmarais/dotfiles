# Playbook

Execution bands for closed-loop ops chores. Query telemetry (APM, metrics, logs) via available Datadog or OpenObserve MCP tools / CLIs.
Evidence labels: Strong / Worth / Speculative.
Trace duration: microseconds (`SearchSQL`) or Datadog span duration. Never select `body` or `message` in board SQL.

## 1. Observability Integrity

- Streams/indexes, `otelcol_*` sent/failed/refused, severity histogram, empty/`0` severity.
- Post-deploy: missing series indicates a Strong host/accessory issue (not app code).

## 2. Reliability & Queue Triage

- Repo-exported queue/job gauges; exceptions grouped by type and frame (ignore expected health-check errors).
- Sentry or Datadog unresolved/regressed issues for this service.
- Scheduled jobs checked against repo schedule definitions; notification/mailer failures.
- Strong findings admit service fixes (health check failure text, discardable failed jobs with code guards, broken scheduled jobs) or host seeds.

## 3. APM Scoring

- Rank server spans by p95 on routes declared in repo router/dashboards; slow SQL via `o2_db_query_norm` or Datadog resource breakdown when present.
- For each Strong slow route: identify bottleneck class (placement, N+1, cache key cost, outbound I/O), admit fix with target files and 1-line rejected alternative.
- Defer external HTTP latency or admit client timeouts/circuit breakers.

## 4. Capacity & Cost

- Disk % and trend toward 85%; span/log volume; export noise.
- Host paths recorded as ledger seeds.
- Collector filter / sampling adjustments admitted as `$dev` plan items (monitoring config).

## 5. Product Golden Paths

- Product events and notification outcomes defined in repo; late scheduled jobs. If repo defines no product events, mark N/A.
- Missing events: admit instrumentation fix via `$dev` plan only if Strong code evidence exists; otherwise route to `product-owner`.

## 6. Security Skim

- Throttle hits, `Rack::Protection`, and scanner fingerprints.
- Admit matcher updates for new public endpoints. Never raise rate limits.

## 7. Dashboard Apply (Conditional)

- **Triggers**:
  - User requested "apply dashboard" / "update live board".
  - Strong evidence that live `GetDashboard` query differs from repo generator output for an active panel.
  - Admitted panel fix landed on named branch and user requested apply.
- **Procedure**:
  1. `ListDashboards` in folder `default` → `GetDashboard` for id and hash (re-list on 404).
  2. If generator must change: admit `$dev` plan item (never hand-edit live SQL).
  3. If repo JSON is current and live board is stale: execute `UpdateDashboard` with full body for repo-owned board; record id and hash on ledger.

## 8. Ops Ledger

- Emit completed Ops Ledger per [`ledger.md`](ledger.md).
