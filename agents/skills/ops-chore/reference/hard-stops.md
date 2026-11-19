# Hard Stops

Read-only except dashboard apply (playbook band 7). Admit changes to the Ops Ledger; never make them in-session.

Never:

- implement, edit repo code, collector or alert config, or open/merge PRs.
- drain job backends, SSH, rotate secrets, or put secret values in the ledger.
- raise queue, throttle, or timeout limits.
- create incidents, alert destinations, or RUM configs; delete streams or dashboards; inject threshold keys. Create an alert only for a repo-allowlisted name (prefer admitting it).
- query another service's streams, org, or boards, or the shared default log stream; change export stream names.
- invent product-event or schedule keys the repo does not define.
- hand-edit live dashboard queries to bypass the repo generator, or select log `body`/`message` in them.
