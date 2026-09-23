# Capability: Go Live (make the site reachable + add an inbox)

> **Trigger**: User says "go live", "launch the site", "make it reachable", "put it online",
> or has just created a managed site/registered a domain and wants it public.
> **Requires**: LS API key with scope `system.publish`, a verified domain, and (for content)
> a managed repo created via `create.md`.
> **Mode**: Agent-native (REST).

Going live wires the domain's **website + blog + docs + changelog** (blog/docs/changelog are
served as sub-paths of the website host — no extra DNS) and creates the Cloudflare CNAME so
`https://<domain>` resolves. Root domain redirects to `www` by default; TLS is handled by
Cloudflare.

Auth every call with the key read on demand (never printed). Base URL from `litestartup.yaml`
`endpoint` if present, else `https://api.litestartup.com`.

## Flow

### 1. Take the site live

**Option A — at create time** (preferred, one call): pass `go_live: true` to create:
```
POST /client/v2/repo-sync/create
Body: { "domain": "acme.com", "go_live": true }
```
The response includes `go_live: { app_url, services, dns }` alongside the repo info.

**Option B — standalone** (repo already exists, or re-run to repair DNS):
```
POST /client/v2/sites/go-live
Body: { "domain": "acme.com" }          # or { "domain_slug": "acme" }
```
Response `data` = `{ domain, domain_slug, app_url, services: ["website","blog","docs","changelog"], dns }`.
Idempotent — safe to call again.

### 2. Create an inbox (optional but common)

Domain must be `verified` first (see `domain.md` status polling).
```
POST /client/v2/domains/{domain_slug}/emails
Body: { "local": "support" }            # → support@acme.com; type/purpose optional
```
List existing inboxes with `GET /client/v2/domains/{domain_slug}/emails`.

### 3. Report to the user

- Website: `https://acme.com`
- Blog: `https://acme.com/blog`
- Docs: `https://acme.com/docs`
- Inbox: `support@acme.com`

Then remind them the update workflow is just: **edit files → `git push`** (managed repos
auto-publish on push; see `create.md` / `sync.md`).

## Notes

- DNS propagation + TLS issuance can take a short while after go-live; if the site 502s
  briefly, wait and retry the URL (do not re-run go-live in a loop).
- `dns.created: false` with `reason: "zone_or_config_missing"` means the managed DNS zone
  isn't ready yet — the domain may still be finishing verification; retry after it's verified.

## Error Scenarios

| Code | Cause | Resolution |
|------|-------|-----------|
| 400 | No domain specified | Pass `domain` or `domain_slug` |
| 403 | Missing scope | Key needs `system.publish` |
| 404 | Domain not found in the account | Register/verify it first (`domain.md`) |
| 409 | Inbox: domain not verified yet | Wait for verification, then create the inbox |
| 409 | Inbox already exists | Informational, not an error |

## DO NOT

- Create inboxes before the domain is `verified`.
- Loop go-live/URL checks; DNS/TLS need time to propagate.
- Print the API key.
