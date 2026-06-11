---
name: litestartup-publish
description: Publish blog, docs, website, changelog and send emails via LiteStartup.
version: 1.0.0
---

# LiteStartup Publish Skill

Publish content to [LiteStartup](https://litestartup.com) from your editor.
Git repo is the source of truth → sync to production in one command.

## Security

- API keys stored at `~/.litestartup/credentials` — scripts read internally
- **NEVER** read, display, or echo the key in conversation
- If auth fails → tell user to re-run `scripts/ls-bind.sh`

## Prerequisites

Check for `litestartup.yaml` in workspace.
- Found → this is the content repo, proceed with requested action
- Missing → guide user to bind first (see capabilities/bind.md)

## Capability Router

When the user makes a request, determine intent and load the relevant file:

| User Intent | Load | Script |
|-------------|------|--------|
| "bind", "connect repo", "unbind", "list domains" | `capabilities/bind.md` | `ls-bind.sh` |
| "publish", "sync", "deploy" | `capabilities/sync.md` | `ls-sync.sh` |
| "send email", "send notification", "email someone" | `capabilities/email.md` | `ls-send-email.sh` |
| "status", "what's synced" | `capabilities/status.md` | `ls-status.sh` |

When the user wants to **write content**, load the relevant spec:

| Content Type | Load | File Extension |
|-------------|------|----------------|
| Documentation | `specs/docs.md` | `.md` (in `docs/{lang}/`) |
| Blog post | `specs/blog.md` | `.md` (in `blog/`) |
| Changelog | `specs/changelog.md` | `.md` (in `changelog/`) |
| Website page | `specs/website.md` | `.html` (in `website/`) |

After writing → run sync (capabilities/sync.md).

## Content Repo Layout

```
<content-repo>/
├── litestartup.yaml          ← Binding config (auto-created by ls-bind.sh)
├── blog/*.md                 ← Blog posts (markdown → HTML by server)
├── website/                  ← Website pages (raw HTML, Tailwind CSS)
│   ├── index.html            ← Homepage (type: website, full HTML)
│   ├── *.html                ← Root block pages (/pricing, /about, etc.)
│   ├── products/*.html       ← Product pages (/products/workmail, etc.)
│   └── solutions/*.html      ← Solution pages (/solutions/agencies, etc.)
├── changelog/*.md            ← Release changelogs (markdown → HTML)
└── docs/                     ← Documentation (Litestartup Docs format)
    ├── config.json           ← Docs site config
    └── {lang}/               ← Language dirs (en/, zh/, etc.)
        ├── _nav.md           ← Top nav tabs
        ├── _sidebar.md       ← Left sidebar
        └── **/*.md           ← Doc pages
```

## Error Codes

| Code | Meaning | Action |
|------|---------|--------|
| 401 | Key expired/invalid | Re-run `ls-bind.sh` |
| 403 | Missing scope | Key needs `system.publish` |
| 404 | No binding | Run `ls-bind.sh` first |
| 409 | Already bound | Informational, not an error |
| 422 | Sync/parse failed | Check file structure against spec |
| 429 | Rate limited | Wait. Do NOT auto-retry |

## DO NOT

- Read or display API keys
- Modify files outside the content repo
- Auto-publish without `git push`
- Auto-retry failed operations
- Write website pages as markdown (they are HTML)
- Write docs without `_sidebar.md` (required for navigation)
- Use query params for language URLs (use path: `/docs/en/...`)
- Choose website page type without asking user (website vs block)
