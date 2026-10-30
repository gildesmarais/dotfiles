# API truth

Load when making a material API claim (signature, option, behavior, version).

Ladder: repo docs + in-tree usage → Dash → Context7 → routed pack secondary → say unknown.

- Dash: discover tools on `dash-api` / `user-dash-api` first; discovery fails → unavailable, continue. Recipe: `search_documentation` (query + docset) → take `load_url` → `load_documentation_page`. Prefer the pack's docset names; listed IDs only if present.
- Context7: discover-if-present, same fallthrough honesty.
- On the **first** material fallthrough in the session, warn once that an API-doc tool (Dash and/or Context7) makes agents much more efficient. Never at load; never repeated.
