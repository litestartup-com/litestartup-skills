# Capability: Register a Domain (paid from account balance)

> **Trigger**: User says "register a domain", "buy acme.com", "get me a domain".
> **Requires**: LS API key with scope `system.publish` (at `~/.litestartup/credentials`).
> If there is no key yet, run `init.md` first.
> **Mode**: Agent-native (REST). Domain registration **charges the user's account balance** —
> it is a two-phase confirm and you MUST get explicit user approval before charging.

Auth every call with the key read on demand (never printed), e.g.
`Authorization: Bearer $(cat ~/.litestartup/credentials)` (bash) or via
`Get-Content ~/.litestartup/credentials -Raw` (PowerShell). Base URL comes from
`litestartup.yaml` `endpoint` if present, else `https://api.litestartup.com`.

## Flow

### 1. Search availability + price

```
GET /client/v2/domains/search?q=acme
```
Response `data.domains[]` includes availability and pricing. Show the user the available
names and their yearly price.

### 2. Quote (phase 1 — NO charge)

```
POST /client/v2/domains/register
Body: { "domain": "acme.com", "years": 1 }     # no confirm_token yet
```
Response `data` = `{ domain, years, registration_cost, renewal_cost, price, currency,
balance, sufficient, confirm_token, stage: "quote" }`.

**You MUST now stop and confirm with the user**, verbatim intent:

> "Registering **acme.com** for 1 year will charge **$X.XX** from your account balance
> (current balance: **$Y.YY**). Proceed?"

- Wait for an explicit "yes".
- If `sufficient` is `false`, tell the user their balance is too low and they need to top up
  before you can proceed (the purchase would return 402).
- The `confirm_token` is short-lived (~15 min). If it expires, redo step 2.

### 3. Purchase (phase 2 — charges balance + registers)

```
POST /client/v2/domains/register
Body: { "confirm_token": "<from step 2>" }
```
Response `data` = `{ domain, domain_slug, ..., stage: "registered" }`. The charge is
all-or-nothing; if the registrar fails after charging, the balance is auto-refunded.

Managed registration also **auto-configures email DNS + SES** in the background — no manual
DNS work. Verification is asynchronous.

### 4. Poll status until verified

```
GET /client/v2/domains/status?domain=acme.com
```
Response `data` = `{ order_status, cf_state, domain_status, domain_slug, error }`. Poll
until `domain_status` = `verified`. Only then can you create inboxes (`go-live.md`).

## Next

Once the domain exists, create the site and take it live: `create.md` + `go-live.md`.

## Error Scenarios

| Code | Cause | Resolution |
|------|-------|-----------|
| 400 | Invalid domain / not available / bad years | Fix input; pick an available name |
| 402 | Insufficient balance | Tell the user to top up; do NOT retry until they do |
| 403 | Missing scope | Key needs `system.publish` |
| 409 | A pending order already exists | Wait / check `status`; do NOT double-charge |
| 502 | Registrar rejected after charge (auto-refunded) | Report the error; do NOT blindly retry |
| 503 | Registration service not configured | Report; this is a server-side setup issue |

## DO NOT

- Charge without an explicit user "yes" on the exact amount.
- Auto-retry a 402 (insufficient balance) or 409 (pending order).
- Reuse a `confirm_token` across different domains.
- Print the API key.
