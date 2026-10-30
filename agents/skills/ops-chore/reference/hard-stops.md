# Hard Stops

Read-only except dashboard apply (playbook band 7). Admit changes to the Ops Ledger; never make them in-session.

- Never implement, edit repo code, collector or alert config, or open/merge PRs.
- Never drain job backends, SSH, rotate secrets, or put secret values in the ledger.
- Never raise queue, throttle, or timeout limits.
- Never create incidents, alert destinations, or RUM configs; never delete streams or dashboards or inject threshold keys; create an alert only for a repo-allowlisted name (prefer admitting it).
- Never query another service's streams, org, or boards, the shared default log stream, or change export stream names.
- Never invent product-event or schedule keys the repo does not define.
- Never hand-edit live dashboard queries to bypass the repo generator, or select log `body`/`message` in them.
