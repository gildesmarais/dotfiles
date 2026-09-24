---
name: ruby-on-rails-dev
description: >-
  Rails overlay loaded by $dev with ruby-dev (deltas only): controllers, routes,
  services, policies, serializers, workers, migrations, tenancy, authz, and API
  contracts.
---

# Ruby on Rails Dev

**Stop:** read `$dev` Shared prep before any delta. Loaded with `ruby-dev`; design or private-seam cases → `$dev` → `architecture`.

Scope: controllers, routes, models, services, policies, serializers, workers/mailers/jobs, migrations, framework config loaders, cache-key composition, encryption cutovers. Require `review.gil` `security` when authn/authz, tenancy, PII/PHI, secrets, exports, webhooks, raw SQL, or privileged ops are in scope.

## Implementation deltas

- Controllers thin: validate params, authorize, delegate, render. Business logic in `app/services` with explicit entrypoints.
- Strong params explicit; serializer output contract-driven.
- Authorization deny-by-default; workers idempotent and retry-safe.
- No interpolated SQL; bind parameters / Arel.
- Structured logging changes → verify redaction.
- Name invisible lifecycle contracts (config variants, reload dependencies, cache identity) instead of silent skip.
- Complete cutovers: replacement seam before removal.
- Closed-set access and audience-split payloads over presence checks and one-bag disclosure.
- Validation, execution, and the published API contract see the same normalized input and accepted closed set.

## Rails testing

- Service → service specs. Endpoint/controller → request specs (+ policy coverage when authz changes). Serializer → serializer specs. Worker → worker specs asserting idempotency and retry.
- Skipped broader coverage → state the gap and risk.

## API docs (`rswag`)

One `response` per status code: rswag keys responses by status, so a second same-code `response` overwrites the first. Put every variant inside that one block — each a uniquely named example (the examples-map key; duplicate names overwrite) with its own nested context, `let`s, and `run_test!`. Declare the schema once; widen it (`additionalProperties` or `oneOf`) so every example validates.

```ruby
response '422', 'Unprocessable Entity' do
  schema type: :object, additionalProperties: true, properties: { ... }
  example 'application/json', 'case a', { error: '...' }
  example 'application/json', 'case b', { error: '...', detail: '...' }
  context 'when case a' do
    # lets / setup
    run_test!
  end
  context 'when case b' do
    # different lets / setup
    run_test!
  end
end
```

A second same-code `response` only for a case kept out of the document (`document: false`). Regenerate OpenAPI from request specs; never hand-edit the generated file. Document format/defaults/example payloads for enums or constrained fields at schema level.

## Handoff deltas

Rails-layer impact, authz/tenancy impact, API contract impact, security-skill invocation status, validation gaps.
