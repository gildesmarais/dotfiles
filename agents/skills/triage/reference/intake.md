# Intake

Default branch for `triage`. Gather evidence, classify, emit the Triage Ledger, hand off.

## Evidence checklist

- Symptom + when (user text)
- Observability: issue IDs, `error_category`, `timeout_phase`, host, `warm_hit`, release/environment
- Local: health, control success, failing reproduce (or blocked reason)
- Surface: API only / web create UX / gem CLI / docs
- Blast: one host vs pool starvation (`timeout/queue`)

Label each claim **Strong** / **Worth** / **Speculative**.

## Route table

| Signal                                                              | Class               | Next                                                                             |
| ------------------------------------------------------------------- | ------------------- | -------------------------------------------------------------------------------- |
| User-visible copy, journey chrome, retry false-hope, new concept    | `product` or `both` | `product-owner` `gate`                                                           |
| Wrong classification, hang, worker queue, detector, timeouts as eng | `eng`               | `$dev` `plan` (skip PO if no UX/concept change)                                  |
| Signal fix **and** UX honesty                                       | `both`              | PO gate first; on **Build Now** → `$dev` `plan` with eng+UX phases in one Shot 1 |
| Ambiguous product vs eng                                            | prefer `product`    | PO gate (admit over guessing Build)                                              |
| “Should we build X?” only                                           | `product`           | `product-owner` only                                                             |
| Approved plan / explicit go / Shot 2                                | `stop`              | `$dev` `implement` (leave triage)                                                |

## Triage Ledger (required)

Emit before handoff:

| Field              | Content                                                           |
| ------------------ | ----------------------------------------------------------------- |
| **Class**          | `product` \| `eng` \| `both` \| `stop`                            |
| **Evidence**       | Bullets + issue/URLs/paths; Strong/Worth/Speculative              |
| **Hypothesis**     | One sentence                                                      |
| **Playbook**       | `none` \| `scrape-incident` \| …                                  |
| **Next**           | `product-owner gate` \| `$dev plan` \| `$dev implement` \| `stop` |
| **Product stance** | `pending` \| `skip (why)` \| prior gate result                    |
| **Residuals**      | Unknowns                                                          |

## Efficiency

- **both** → run `product-owner` `gate` in-session; on **Build Now** immediately load `$dev` `plan` with eng+UX phases (one continuous Shot 1).
- Do not re-ask locks already in an active playbook.
- Max 2 clarifying questions if route blocked; otherwise default from tables above.
