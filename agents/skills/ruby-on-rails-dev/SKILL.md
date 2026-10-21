---
name: ruby-on-rails-dev
description: >-
  Rails overlay: controllers, routes, services, policies, serializers, workers,
  migrations, tenancy, authz, and API contracts.
disable-model-invocation: true
---

# Ruby on Rails Dev

**Stop:** read `$dev` Shared prep before any delta. Loaded with `ruby-dev`; design or private-seam cases → `$dev` → `architecture`.

Scope: controllers, routes, models, services, policies, serializers, workers/mailers/jobs, migrations, framework config loaders, cache-key composition, encryption cutovers. Require the `security` lens on Assure when authn/authz, tenancy, PII/PHI, secrets, exports, webhooks, raw SQL, or privileged ops are in scope.

## Implementation deltas

- Name invisible lifecycle contracts (config variants, reload dependencies, cache identity) instead of silent skip.
- Complete cutovers: replacement seam before removal.
- Closed-set access and audience-split payloads over presence checks and one-bag disclosure.
- Validation, execution, and the published API contract see the same normalized input and accepted closed set.
- Structured logging changes → verify redaction.

## Rails testing

- Service → service specs. Endpoint/controller → request specs (+ policy coverage when authz changes). Serializer → serializer specs. Worker → worker specs asserting idempotency and retry.
- Skipped broader coverage → state the gap and risk.

## API docs (`rswag`)

One `response` per status code — rswag keys by status, so a second same-code `response` overwrites. Put every variant inside that one block: uniquely named examples (duplicate names overwrite) each with nested context, `let`s, and `run_test!`. Declare the schema once; widen it (`additionalProperties` or `oneOf`) so every example validates. A second same-code `response` only for `document: false`. Regenerate OpenAPI from request specs; never hand-edit. Document format/defaults/example payloads for enums at schema level.

## Handoff deltas

Rails-layer impact, authz/tenancy impact, API contract impact, security-skill invocation status, validation gaps.
