# Features Spec

> **When to use**: Understanding what litesaas-admin provides out of the box.
> **Purpose**: Help the AI agent know what's already built vs what needs to be added.

## Feature Matrix

### ✅ Fully Functional (LS Backend)

| Feature | Frontend Page | API Route | Backend |
|---------|--------------|-----------|---------|
| Email login | `/` (login page) | `POST /api/auth/login` | LS Auth |
| Email signup | `/` (register tab) | `POST /api/auth/signup` | LS Auth |
| Verification code | Login flow | `POST /api/auth/verify-code` | LS Auth |
| Password reset | Reset page | `POST /api/auth/forgot-password` | LS Auth |
| Google OAuth | Login page button | `GET /api/auth/oauth/google` | LS Proxy Mode A |
| GitHub OAuth | Login page button | `GET /api/auth/oauth/github` | LS Proxy Mode A |
| AI Chat | `/ai-chat` | `POST /api/ai/chat` | LS LLM Router |
| Profile | `/settings` area | `GET/PUT /api/profile` | LS Auth |
| Token refresh | Automatic | `POST /api/auth/refresh` | LS Auth |
| OAuth config | Auto-detect | `GET /api/auth/oauth-config` | LS Auth |

### 📋 Display Only (Mock Data)

| Feature | Frontend Page | API Route | Future Backend |
|---------|--------------|-----------|----------------|
| Dashboard stats | `/dashboard` | `GET /api/dashboard/stats` | Local PostgreSQL |
| User management | `/admin/users` | `GET /api/users` | Local PostgreSQL |
| Notifications | Notification panel | `GET /api/notifications` | Local PostgreSQL |
| Billing / Plans | `/billing` | `GET /api/billing/current-plan` | LS Billing or Stripe |
| Credits | `/settings` | `GET /api/credits/*` | Local PostgreSQL |

### 🎨 Frontend-Only Features

| Feature | Description |
|---------|-------------|
| Dark mode | Theme toggle, persisted in localStorage |
| Multi-language | i18n (en, zh-CN) via translation files |
| Responsive | Mobile-first, Tailwind CSS |
| Component library | shadcn/ui components |

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Next.js 14 (App Router) |
| Language | TypeScript |
| Styling | Tailwind CSS |
| Components | shadcn/ui |
| State | Zustand |
| Forms | React Hook Form + Zod |
| Charts | Recharts |
| Icons | Lucide React |
| Package Manager | npm |

## Architecture Notes

- `lib/ls-client.ts` — Server-side LS API client (handles all LS communication)
- `lib/api-auth.ts` — JWT verification middleware for API routes
- `app/api/` — All backend logic lives here as Next.js route handlers
- No direct database connection in current version (Phase 2 will add Drizzle + PostgreSQL)
