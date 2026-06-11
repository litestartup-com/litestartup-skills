# Capability: Send Email

> **Trigger**: User says "send email", "send notification", "email someone".
> **Script**: `scripts/ls-send-email.sh`

## Two Endpoints

| Endpoint | When to Use | API Key Scope | From |
|----------|-------------|---------------|------|
| `POST /client/v2/emails/notification` | **Default**. No custom domain needed. | `notification` | System default (xxx@litestartup.net) |
| `POST /client/v2/emails` | User has custom domain and specifies `--from`. | `email` | User's domain email (e.g., hi@yourdomain.com) |

**Rule: Always use notification endpoint unless user explicitly specifies a from address.**

---

## Flow (Notification — Default)

1. Ask user for:
   - **To**: recipient email (optional — defaults to user's own registered email)
   - **Subject**: email subject line
   - **Body**: compose content (HTML supported)
2. Show preview and ask for confirmation
3. Call `POST /client/v2/emails/notification`
4. Report: "Email sent successfully" or error

### Request Body

```json
{
  "to": "recipient@example.com",
  "subject": "Email Subject",
  "content": "<p>HTML content here</p>"
}
```

- `to` is optional (omit → sends to user's registered email)
- `content` supports HTML
- `from` is auto-assigned by server (user's system address)

---

## Flow (Custom Domain Email)

Only when user says "send from my domain" or specifies `--from`:

1. Ask user for:
   - **From**: sender email (must be configured in user's domain)
   - **To**: array of recipient emails
   - **Subject**: email subject line
   - **Body**: compose content (HTML)
2. Show preview and ask for confirmation
3. Call `POST /client/v2/emails`
4. Report result

### Request Body

```json
{
  "from": "hi@yourdomain.com",
  "to": ["recipient@example.com"],
  "subject": "Email Subject",
  "content": "<p>HTML content</p>"
}
```

---

## Campaign Emails (Bulk / Marketing)

This capability is for **single, direct emails only** (1-to-1 or small batch).

For **bulk marketing campaigns** (send to all contacts with a tag), use the campaign workflow instead:
→ See `specs/campaign.md` — write a campaign `.md` file in `campaign/` and sync.

**How to decide:**
- "Send an email to john@example.com" → **this capability** (direct email)
- "Send a newsletter to all subscribers" → **campaign** (specs/campaign.md)
- "Email our product launch to everyone tagged 'beta-users'" → **campaign** (specs/campaign.md)

---

## Important Notes

- Email content is NOT saved to git (it's a direct API call)
- Always confirm with user before sending (irreversible action)
- New accounts without custom domain can ONLY use the notification endpoint
- API key must have the correct scope (`notification` or `email`)
- Content supports HTML — if user writes markdown, convert to HTML before sending

## Error Scenarios

| Error | Cause | Resolution |
|-------|-------|-----------|
| 401 | Invalid API key | Re-run `ls-bind.sh` |
| 403 | Missing scope | Add `notification` or `email` scope to API key |
| 403 | From email not allowed | Use a domain email configured in user's account |
| 422 | Invalid recipient or empty body | Fix input and retry |
| 429 | Rate limited | Wait (do NOT auto-retry) |
| 500 | Context missing | From email not in user's configured domains |
