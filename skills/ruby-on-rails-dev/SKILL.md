---
name: ruby-on-rails-dev
description: "Rails overlay for API/controller/service/policy/serializer/worker changes. Use with $ruby-dev for Rails architecture, tenancy, authz, and API contracts."
---

# Ruby on Rails Dev

## Purpose and Routing

- Use as a Rails overlay with `$ruby-dev`; keep Ruby-general workflow in `$ruby-dev`.
- Apply to controllers, routes, models, services, policies, serializers, workers, and migrations.
- Follow `AGENTS.md` routing and precedence.
- Require `$review-security-compliance` when changes match the `AGENTS.md` `Security Trigger Matrix`.

## Implementation Rules

- Keep controllers thin: validate params, authorize, delegate, render.
- Keep business logic in `app/services` with explicit entrypoints.
- Keep strong params explicit and serializer output contract-driven.
- Default new endpoints to `/api/v3` unless compatibility constraints require otherwise.
- Preserve clinic/account scoping end-to-end and block cross-tenant leakage in queries, policies, responses, and logs.
- Keep authorization deny-by-default; keep workers idempotent and retry-safe.
- Avoid interpolated SQL; use parameter binding/Arel.
- Use auditable `after_party` tasks for backfills or behavior-affecting data migrations.
- If structured logging changes, verify redaction behavior and `LOG_LEVEL` semantics.

## Rails Testing

- Service changes: service specs.
- Endpoint/controller changes: request specs; add policy coverage when authz changes.
- Serializer changes: serializer specs.
- Worker changes: worker specs with idempotency and retry assertions.
- Query-heavy changes: at least one `:detect_nplusone` (`prosopite`) spec, or explicitly justify skipping.
- If broader coverage is skipped, state the gap and risk explicitly.
- Combine multiple examples rubocop-friendly using `:aggregate_failures`.
- Use `match_array`, `include`, or `a_collection_including` for partial array matches to avoid brittle expectations.

## API Docs (`rswag`)

- After request-spec changes, run `make rswag`.
- Never edit `swagger/**/*.yaml` by hand; update request specs instead.
- Provide multiple examples per response status; do not duplicate status blocks when examples fit.
- For enums or constrained fields, document format/defaults/example payloads at schema level.

## Tooling and Completion

- Run validation in Docker Compose test container; avoid host-local Ruby tooling unless explicitly approved.
- If auth/integration behavior changes, verify services from `docker-compose.services.yml` or document validation limits.
- In handoff, include:
  Rails-layer impact, authz/tenancy impact, API contract impact, security-skill invocation status, and any validation gaps.
