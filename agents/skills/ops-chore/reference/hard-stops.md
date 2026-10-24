# Hard Stops

Mutation boundaries and fail-closed prohibitions for `ops-chore`.

## Prohibited Actions

- Never `$dev` `implement`, edit repo code/collector/alert YAML, or open/merge PRs.
- Never drain job backends, SSH, rotate secrets, or put secret values into the ledger.
- Never raise queue, throttle, or timeout limits.
- Never create incidents, new alert destinations, RUM configurations, or delete streams.
- Never query log stream `default`, change OTLP `stream-name`, or query another service's streams/org/boards.
- Never invent product-event or schedule keys not defined in the repo.
- Never hand-edit live board SQL to bypass the repo dashboard generator.
- Never `DeleteDashboard` or inject threshold keys.
- Never call `CreateAlert` except for names already allowlisted by the repo (prefer admitting via `$dev` plan).

## Allowed Writes

- `UpdateDashboard` strictly for a board this repo owns in folder `default`, matching `GetDashboard` hash, when band 7 fires.
- Read-only queries to Datadog, OpenObserve, and Sentry otherwise.

## Admission Boundary

- Strongly evidenced service improvements (controllers, jobs, mailer guards, collector filters, health-check messages, cache keys, query budgets) admit to the Ops Ledger for `$dev` `plan`. Zero direct in-session edits.
