# Campaign Email Writing Spec

> **When to use**: User wants to write or send a campaign email (bulk marketing email to a contact tag).
> **File location**: `campaign/` directory in the content repo.
> **Format**: Markdown with YAML frontmatter → server converts to HTML and creates campaign.

## File Convention

```
campaign/
├── june-product-launch.md
├── weekly-newsletter-2026-06-15.md
└── black-friday-sale.md
```

- Filename is used as an internal reference (not shown to recipients)
- One file = one campaign
- After sync, file status is tracked server-side; re-syncing a sent campaign has no effect

---

## Template

```markdown
---
subject: "Introducing Our New Product Line"
from: "hi@yourdomain.com"
from_name: "Your Company"
tag: "newsletter-subscribers"
status: "ready"
scheduled_at: "2026-06-15T10:00:00+08:00"
---

Hi there,

We're excited to announce our brand new product line designed specifically for startups.

## What's New

- **Feature A** — Description of feature A
- **Feature B** — Description of feature B
- **Feature C** — Description of feature C

## Get Started

Visit our website to learn more and try it free:

[Learn More](https://yourdomain.com/products)

---

Thanks for being part of our community!

Best regards,
The Team
```

---

## Frontmatter Fields

| Field | Required | Type | Default | Description |
|-------|----------|------|---------|-------------|
| `subject` | **Yes** | string | — | Email subject line |
| `from` | **Yes** | string | — | Sender email (must be a configured domain email) |
| `tag` | **Yes** | string | — | Contact tag **name** (recipients = all contacts with this tag) |
| `status` | No | `"draft"` / `"ready"` / `"scheduled"` | `"ready"` | Campaign status after sync |
| `from_name` | No | string | local-part of `from` | Sender display name |
| `scheduled_at` | No | ISO 8601 | — | Send time (required when `status: "scheduled"`) |
| `template_id` | No | int | 0 | Use an existing LS email template (0 = no template, use markdown body) |

---

## Content Rules

1. **Write in Markdown** — the server converts to HTML before sending
2. Use `## H2` for major sections
3. Standard Markdown: bold, italic, links, code blocks, images, lists
4. Links are automatically tracked (open/click metrics) by the server
5. An unsubscribe link is automatically appended by the server — do NOT add one manually
6. **Do NOT include** `# Title` as H1 — the subject is the title
7. HTML blocks are supported for complex layouts (e.g., buttons, tables)

---

## Tag Rules

- The `tag` field uses the tag **name** (human-readable), not the tag ID
- The tag must already exist in the user's LS account (Contacts → Tags)
- If the tag does not exist or has 0 contacts, sync will report an error
- Do NOT invent tag names — always verify against the API

### Tag Resolution Flow

1. Query the user's tags via API (see below)
2. **If user already specified a tag name** (e.g., "给 newsletter 发一封 campaign"):
   - Match against the API response (case-insensitive)
   - If matched and `active_contacts > 0` → use it directly
   - If matched but `active_contacts == 0` → warn user: "tag exists but has no active contacts"
   - If NOT matched → show available tags and ask user to pick
3. **If user did NOT specify a tag**: present the tag list and let them choose

### Listing Available Tags

Query tags via:

```
GET {endpoint}/client/v2/repo-sync/tags
Authorization: Bearer {api_key}
```

Response:
```json
{
  "code": 200,
  "data": {
    "tags": [
      { "id": 1, "name": "newsletter", "color": "#3b82f6", "active_contacts": 142 },
      { "id": 2, "name": "beta-users", "color": "#10b981", "active_contacts": 58 }
    ]
  }
}
```

Use the `name` value in frontmatter `tag` field.

---

## Status Lifecycle

| Status in file | Server behavior after sync |
|----------------|---------------------------|
| `draft` | Campaign created but NOT submitted for review |
| `ready` | Campaign created → auto-submitted for review → sent after approval |
| `scheduled` | Campaign created → auto-submitted for review → sent at `scheduled_at` after approval |

### Review Process

All non-draft campaigns go through LS's AI review before sending. This is automatic and transparent to the user. If review rejects the campaign, user is notified via LS dashboard.

---

## Sync Behavior

- Campaign files are processed during normal `sync` (same trigger endpoint)
- **Idempotency**: same file synced multiple times → updates existing campaign (only if still in `draft` status)
- **Sent campaigns are immutable**: re-syncing a file whose campaign is already sent/sending has no effect
- **Deletion**: removing a campaign file does NOT cancel a scheduled campaign (safety measure)

---

## Checklist Before Sync

- [ ] `subject` is present and descriptive
- [ ] `from` is a valid, configured domain email
- [ ] `tag` exists in the user's LS Contacts and has recipients
- [ ] `status` is intentional (`ready` will trigger sending!)
- [ ] If `status: "scheduled"`, `scheduled_at` is set and in the future
- [ ] Content is reviewed by user (no typos, correct links)
- [ ] User has explicitly confirmed they want to send

---

## IMPORTANT: User Confirmation

**ALWAYS ask the user to confirm before syncing a campaign with `status: "ready"` or `status: "scheduled"`.**

A campaign sync triggers real email delivery to real people. Show the user:
1. Subject line
2. Sender address
3. Target tag name
4. Status (ready = send now, scheduled = send at time)
5. Ask: "Ready to sync and send this campaign?"

Only proceed after explicit user confirmation.
