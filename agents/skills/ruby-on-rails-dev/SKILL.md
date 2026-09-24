---
name: ruby-on-rails-dev
description: >-
  Always load $dev first (with $ruby-dev); this overlay is deltas only. Rails
  overlay for API/controller/service/policy/serializer/worker changes — Rails
  architecture, tenancy, authz, and API contracts.
---

# Ruby on Rails Dev

**Stop:** read `$dev` Shared prep before any delta.

## Purpose and Routing

- Overlay loaded via `$dev` with `$ruby-dev`; keep Ruby-general workflow in `$ruby-dev` and shared classify / one-surface / design / API truth / compat / git safety in `$dev`.
- Apply to controllers, routes, models, services, policies, serializers, workers/mailers/jobs, migrations, framework config loaders, cache-key composition, and encryption cutovers.
- Follow `AGENTS.md` routing and precedence.
- Require `$review.gil` **`security`** when authn/authz, tenancy, PII/PHI, secrets, exports, webhooks, raw SQL, or privileged ops are in scope.
- Design or private-seam cases → `$dev` → `$ruby-dev` → `architecture`. Do not invent adapter or regex craft here.

## Implementation Deltas

- Keep controllers thin: validate params, authorize, delegate, render.
- Keep business logic in `app/services` with explicit entrypoints.
- Keep strong params explicit and serializer output contract-driven.
- Keep authorization deny-by-default; keep workers idempotent and retry-safe.
- Avoid interpolated SQL; use parameter binding/Arel.
- If structured logging changes, verify redaction behavior.
- Name invisible lifecycle contracts (config variants, reload dependencies, cache identity) instead of silent skip.
- Complete cutovers: replacement seam before removal.
- Prefer closed-set access and audience-split payloads over presence and one-bag disclosure.
- Validation, execution, and the published API contract must see the same normalized input and accepted closed set.

## Rails Testing

- Service changes: service specs.
- Endpoint/controller changes: request specs; add policy coverage when authz changes.
- Serializer changes: serializer specs.
- Worker changes: worker specs with idempotency and retry assertions.
- If broader coverage is skipped, state the gap and risk explicitly.

## API Docs (`rswag`)

One `response` per status code. Rswag stores responses in a map keyed by status, so a second `response` with the same code in that operation overwrites the first. Put every variant of that status inside the one block — each as a uniquely named example plus its own nested context, `let`s, and `run_test!`. The example name is the examples-map key; a duplicate name overwrites the earlier example.

Declare the schema once on that shared response. If bodies differ, widen it (`additionalProperties` or `oneOf`) so every example still validates.

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

A second `response` with the same code is only for a case that must stay out of the document (`document: false`). Different status codes stay as separate blocks. Regenerate generated OpenAPI from the request specs; do not hand-edit the generated file. For enums or constrained fields, document format/defaults/example payloads at schema level.

## Tooling and Completion

- Prefer the repository's established validation entrypoints (same stance as `$ruby-dev`).
- In handoff, include: Rails-layer impact, authz/tenancy impact, API contract impact, security-skill invocation status, and any validation gaps.
