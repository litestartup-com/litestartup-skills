# Capability: Connect to LiteStartup (Terminal Onboarding)

> **Trigger**: There is no key at `~/.litestartup/credentials` and the user wants to do
> anything with LiteStartup (create a site, register a domain, publish, send email).
> **Mode**: Agent-native. Runs entirely in the terminal — no browser, no dashboard.
> **Endpoints are public** (the user has no key yet); they are rate-limited by email.

This gets a brand-new user an API key from the terminal using an emailed **claim code**.
The real key travels **server → your shell → file**; it is never shown to the user and
never enters this conversation.

## API base

Onboarding has no `litestartup.yaml` yet, so use the default base unless the user gives
another: `https://api.litestartup.com`

## Flow

1. **Check first.** If `~/.litestartup/credentials` exists and is non-empty, you are already
   connected — skip onboarding and proceed with the user's actual request.
2. **Ask the user for their email.**
3. **Request a code.** `POST /client/v2/onboard/request-code` with `{ "email": "<their email>" }`.
   The response contains `data.request_id` — **keep it for step 5** (it is the second factor;
   it is not the key and not secret, but do not lose it). Tell the user: *"I've emailed a code
   to `<email>` — paste it back here."* Do **not** invent or guess the code.
4. **Ask the user for the code** they received by email.
5. **Claim the key WITHOUT printing it.** Call `POST /client/v2/onboard/claim` with
   `{ "email", "code", "request_id" }`, capture the response into a variable, extract
   `data.api_key`, and write **only the raw key** to `~/.litestartup/credentials` (mode 600).
   **Never echo the response, the key, or the file contents.**
6. **Verify connectivity.** `GET /client/v2/verify` with the key read from the file. Report
   "Connected ✅" (never print the key).

### Linux / macOS (bash / Git Bash)

```bash
BASE=https://api.litestartup.com

# Step 3 — request a code (note the request_id in the response)
curl -s -X POST "$BASE/client/v2/onboard/request-code" \
  -H "Content-Type: application/json" -d '{"email":"USER_EMAIL"}'

# Step 5 — after the user gives you the code, exchange it. Nothing is printed.
umask 077; mkdir -p ~/.litestartup
resp=$(curl -s -X POST "$BASE/client/v2/onboard/claim" \
  -H "Content-Type: application/json" \
  -d '{"email":"USER_EMAIL","code":"USER_CODE","request_id":"REQUEST_ID"}')
# Prefer jq; fall back to sed. Writes ONLY the key, no newline.
printf '%s' "$resp" | jq -r '.data.api_key' 2>/dev/null > ~/.litestartup/credentials \
  || printf '%s' "$resp" | sed -n 's/.*"api_key":"\([^"]*\)".*/\1/p' > ~/.litestartup/credentials
chmod 600 ~/.litestartup/credentials
unset resp   # do NOT echo it

# Step 6 — verify (key is read on demand, never shown)
curl -s -H "Authorization: Bearer $(cat ~/.litestartup/credentials)" "$BASE/client/v2/verify"
```

### Windows (PowerShell)

```powershell
$Base = "https://api.litestartup.com"

# Step 3 — request a code (note $r.data.request_id)
$r = Invoke-RestMethod -Method Post -Uri "$Base/client/v2/onboard/request-code" `
  -ContentType "application/json" -Body '{"email":"USER_EMAIL"}'

# Step 5 — exchange the code; write only the key, print nothing
$resp = Invoke-RestMethod -Method Post -Uri "$Base/client/v2/onboard/claim" `
  -ContentType "application/json" `
  -Body '{"email":"USER_EMAIL","code":"USER_CODE","request_id":"REQUEST_ID"}'
$dir = Join-Path $HOME ".litestartup"
New-Item -ItemType Directory -Force -Path $dir | Out-Null
[System.IO.File]::WriteAllText((Join-Path $dir "credentials"), $resp.data.api_key)
Remove-Variable resp   # do NOT print it

# Step 6 — verify
$key = (Get-Content (Join-Path $HOME ".litestartup/credentials") -Raw)
Invoke-RestMethod -Uri "$Base/client/v2/verify" -Headers @{ Authorization = "Bearer $key" }
```

## After connecting

You now have a key with scopes `system.publish` + `ai`. Continue with what the user asked:
register a domain (`domain.md`), create the site (`create.md`), take it live and add an inbox
(`go-live.md`).

## Error Scenarios

| Code | Cause | Resolution |
|------|-------|-----------|
| 400 | Invalid email, or missing code/request_id | Re-check inputs; ask the user again |
| 400 | Wrong code | Ask the user to re-read the code; a few attempts are allowed |
| 410 | Code expired or already used | Start over at step 3 (request a new code) |
| 429 | Too many requests / attempts | Wait a few minutes; do NOT auto-retry |
| 500 | Provisioning/email failed | Report it; try again shortly |

## DO NOT

- Print, echo, `cat`, or otherwise reveal the API key or the claim response.
- Repeat the claim code back to the user in your final answer.
- Write the key anywhere except `~/.litestartup/credentials` (never into the repo).
- Auto-retry a failed request-code/claim without the user.
