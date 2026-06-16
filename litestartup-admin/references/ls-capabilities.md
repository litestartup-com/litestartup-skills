# LS Backend Capabilities for SaaS Development

> **When to use**: When the user asks to add a feature that can be fulfilled by the LiteStartup backend.
> **Architecture**: Browser → Next.js API Route → LS Backend (via API Key)

All integration code goes in `app/api/` as Next.js route handlers.
The LS API Key is read from `process.env.LS_API_KEY` (server-side only).

## Already Integrated (via lib/ls-client.ts)

These are working out of the box — no extra code needed:

- ✅ User register/login/logout
- ✅ OAuth (Google/GitHub) — LS proxy mode, zero config
- ✅ Password reset / verification code
- ✅ User profile CRUD
- ✅ AI chat completion
- ✅ Token refresh

## Available Capabilities (Extend as needed)

### 1. Send Transactional Email

**When to use**: Welcome email, password reset, order confirmation, system alerts

**Endpoint**: `POST /client/v2/emails`

**Integration pattern**:
```typescript
// app/api/email/send/route.ts
import { NextResponse } from "next/server"
import { authenticateRequest } from "@/lib/api-auth"

const LS_API_URL = process.env.LS_API_URL
const LS_API_KEY = process.env.LS_API_KEY

export async function POST(request: Request) {
  const auth = authenticateRequest(request)
  if (!auth.authenticated) return auth.response!

  const { to, subject, html } = await request.json()

  const res = await fetch(`${LS_API_URL}/client/v2/emails`, {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${LS_API_KEY}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      to,
      subject,
      html,
      from: "Your App <noreply@yourdomain.com>",
    }),
  })

  const data = await res.json()
  return NextResponse.json({ success: true, data })
}
```

### 2. Send Notification Email (No domain needed)

**When to use**: Simple system notifications — uses LS shared sender, no custom domain required

**Endpoint**: `POST /client/v2/emails/notification`

**Body**: `{ "to": "user@example.com", "subject": "...", "html": "..." }`

No `from` field needed — LS uses its own sender.

### 3. File Upload / Storage

**When to use**: Avatar upload, document attachments, image hosting

**Endpoint**: `POST /client/v2/storage/upload`

**Integration pattern**:
```typescript
// app/api/upload/route.ts
import { NextResponse } from "next/server"

export async function POST(request: Request) {
  const formData = await request.formData()

  const res = await fetch(`${process.env.LS_API_URL}/client/v2/storage/upload`, {
    method: "POST",
    headers: { "Authorization": `Bearer ${process.env.LS_API_KEY}` },
    body: formData,
  })

  const data = await res.json()
  return NextResponse.json({ success: true, url: data.data.url })
}
```

**List files**: `GET /client/v2/storage/files`
**Delete file**: `DELETE /client/v2/storage/files/{id}`

### 4. AI HTML Generation

**When to use**: AI-generated landing page, email template, marketing content

**Endpoint**: `POST /client/v2/ai/html/generate`

**Integration pattern**:
```typescript
const res = await fetch(`${process.env.LS_API_URL}/client/v2/ai/html/generate`, {
  method: "POST",
  headers: {
    "Authorization": `Bearer ${process.env.LS_API_KEY}`,
    "Content-Type": "application/json",
  },
  body: JSON.stringify({ prompt: "A pricing page with 3 tiers" }),
})
```

### 5. AI Template Generation

**When to use**: Generate email templates, blog post drafts

**Endpoint**: `POST /client/v2/ai/template/generate`

### 6. Contact Management (CRM)

**When to use**: Track app users as contacts, segment by tags, export

**Endpoints**:
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/client/v2/contacts/add` | Add contact |
| GET | `/client/v2/contacts/search` | Search/filter contacts |
| GET | `/client/v2/contacts/get` | Get single contact |
| PUT | `/client/v2/contacts/update` | Update contact |
| DELETE | `/client/v2/contacts/delete` | Delete contact |
| POST | `/client/v2/contacts/import` | Bulk import |
| GET | `/client/v2/contacts/export` | Export contacts |

### 7. Newsletter / Bulk Email

**When to use**: Product updates, marketing campaigns to subscribers

**Endpoint**: `POST /client/v2/newsletters/send`

### 8. Subscription Management

**When to use**: SaaS plan upgrades/downgrades

**Endpoints**:
- `POST /client/v2/subscription/create` — Create/upgrade subscription
- `POST /client/v2/subscription/downgrade` — Downgrade to free

## Security Rules

- All integration code runs **server-side** in Next.js API routes
- API Key comes from `process.env.LS_API_KEY` — NEVER expose to browser
- Protect routes with `authenticateRequest()` from `@/lib/api-auth`
- NEVER display the actual API Key value in conversation or logs
