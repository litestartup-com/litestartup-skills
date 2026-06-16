---
name: litestartup-publish
description: >
  Publish blog posts, documentation, website pages, changelogs, and send emails
  via LiteStartup. Use when the user asks to publish content, sync a repo,
  write a blog post, send an email, or bind a content repository.
metadata:
  author: litestartup-com
  version: "1.0.0"
---

# LiteStartup Publish Skill

Publish content to [LiteStartup](https://litestartup.com) from your editor.
Git repo is the source of truth → sync to production in one command.

## Security

- API keys stored at `~/.litestartup/credentials` — scripts read internally
- **NEVER** read, display, or echo the key in conversation
- If auth fails → tell user to re-run bind flow (see `references/bind.md`)

## Prerequisites

Check for `litestartup.yaml` in workspace.
- Found → this is the content repo, proceed with requested action
- Missing → guide user to bind first (see `references/bind.md`)

## Capability Router

When the user makes a request, determine intent and load the relevant file:

| User Intent | Load | Script (Linux/macOS fallback) |
|-------------|------|------|
| "bind", "connect repo", "unbind", "list domains" | `references/bind.md` | `scripts/ls-bind.sh` |
| "publish", "sync", "deploy" | `references/sync.md` | `scripts/ls-sync.sh` |
| "send email", "send notification", "email someone" | `references/email.md` | `scripts/ls-send-email.sh` |
| "send campaign", "email campaign", "bulk email", "newsletter" | `references/campaign.md` | (uses sync) |
| "status", "what's synced" | `references/status.md` | `scripts/ls-status.sh` |

When the user wants to **write content**, load the relevant reference:

| Content Type | Load | File Extension |
|-------------|------|----------------|
| Documentation | `references/docs.md` | `.md` (in `docs/{lang}/`) |
| Blog post | `references/blog.md` | `.md` (in `blog/`) |
| Changelog | `references/changelog.md` | `.md` (in `changelog/`) |
| Website page | `references/website.md` | `.html` (in `website/`) |
| Campaign email | `references/campaign.md` | `.md` (in `campaign/`) |

After writing → run sync (`references/sync.md`).

## Content Repo Layout

```
<content-repo>/
├── litestartup.yaml          ← Binding config (auto-created during bind)
├── blog/*.md                 ← Blog posts (markdown → HTML by server)
├── campaign/*.md             ← Email campaigns (markdown → HTML, sent to tag contacts)
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
| 401 | Key expired/invalid | Re-run bind flow |
| 403 | Missing scope | Key needs `system.publish` |
| 404 | No binding | Run bind first |
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
