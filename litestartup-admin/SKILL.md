---
name: litestartup-admin
description: Initialize, configure and deploy SaaS applications using litesaas-admin boilerplate with LiteStartup backend.
version: 0.1.0
---

# LiteStartup Admin Skill

Scaffold and manage SaaS applications powered by [litesaas-admin](https://github.com/litestartup-com/litesaas-admin) + LiteStartup backend.

## Security

- API keys stored at `~/.litestartup/credentials` — scripts read internally
- **NEVER** read, display, or echo the key in conversation
- If auth fails → tell user to re-run `scripts/ls-admin-init.sh` or check key scope

## Prerequisites

Check for `.env.local` containing `LS_API_KEY` in the project directory.
- Found → project is configured, proceed with requested action
- Missing → guide user through init (see `capabilities/init.md`)

## Capability Router

When the user makes a request, determine intent and load the relevant file:

| User Intent | Load | Script |
|-------------|------|--------|
| "init saas", "create project", "scaffold", "initialize" | `capabilities/init.md` | `ls-admin-init.sh` |
| "configure", "set up env", "connect to LS" | `capabilities/configure.md` | — |
| "status", "check project" | `capabilities/status.md` | — |

When the user wants to **add features**, load the capability spec:

| Feature Request | Load |
|----------------|------|
| "send email", "welcome email", "notification" | `specs/ls-capabilities.md` § Email |
| "file upload", "avatar", "storage" | `specs/ls-capabilities.md` § Storage |
| "ai generate", "ai html", "ai chat" | `specs/ls-capabilities.md` § AI |
| "contacts", "crm", "user tags" | `specs/ls-capabilities.md` § Contacts |
| "newsletter", "bulk email" | `specs/ls-capabilities.md` § Newsletter |

## Project Layout (after init)

```
<project-dir>/
├── .env.local             ← LS credentials (gitignored)
├── app/api/               ← Next.js API routes (server-side proxy to LS)
├── lib/ls-client.ts       ← LS backend client (auth, AI, profile)
├── docker-compose.yml     ← Production deployment
└── ...                    ← Standard Next.js structure
```

## Error Codes

| Code | Meaning | Action |
|------|---------|--------|
| 401 | Key expired/invalid | Re-run init or update `~/.litestartup/credentials` |
| 403 | Missing scope | Key needs `auth` scope (add at LS dashboard) |
| 404 | LS endpoint unreachable | Check `LS_API_URL` in `.env.local` |
| 422 | Configuration error | Verify `.env.local` against `specs/env-config.md` |

## DO NOT

- Read or display API keys
- Modify files outside the project directory
- Auto-start `npm run dev` without user confirmation
- Skip scope verification during init
- Hard-code API keys in source files (use `.env.local` only)
- Install global npm packages without asking
