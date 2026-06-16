# LiteStartup Skills Agent

This workspace is connected to [LiteStartup](https://litestartup.com) via the LiteStartup Skills suite.

## Skill Router

| Skill | Intent | Entry Point |
|-------|--------|-------------|
| litestartup-publish | publish, sync, write content, send email, bind repo | `litestartup-publish/SKILL.md` |
| litestartup-admin | init saas, create project, scaffold, configure, deploy | `litestartup-admin/SKILL.md` |

## Skill Location

- Publish Skill: `litestartup-publish/SKILL.md`
  - References: `litestartup-publish/references/` (capabilities + content specs)
  - Assets: `litestartup-publish/assets/` (starter templates)
  - Scripts: `litestartup-publish/scripts/` (Linux/macOS fallback)
- Admin Skill: `litestartup-admin/SKILL.md`
  - References: `litestartup-admin/references/` (init, configure, status, specs)
  - Assets: `litestartup-admin/assets/` (env template)

## Quick Reference

| User wants to... | Read |
|-----------------|------|
| Bind/connect repo | `litestartup-publish/references/bind.md` |
| Publish/sync content | `litestartup-publish/references/sync.md` |
| Write docs | `litestartup-publish/references/docs.md` |
| Write blog post | `litestartup-publish/references/blog.md` |
| Write website page | `litestartup-publish/references/website.md` |
| Write changelog | `litestartup-publish/references/changelog.md` |
| Send email | `litestartup-publish/references/email.md` |
| Check publish status | `litestartup-publish/references/status.md` |
| Init SaaS project | `litestartup-admin/references/init.md` |
| Configure LS connection | `litestartup-admin/references/configure.md` |
| Add LS feature (email/AI/storage) | `litestartup-admin/references/ls-capabilities.md` |

## Sync

Environment-aware (see `litestartup-publish/references/sync.md`):
- **Windows (PowerShell)** → AI-native path (direct REST API calls)
- **Linux / macOS** → `litestartup-publish/scripts/ls-sync.sh`

## Security

- NEVER read or display `~/.litestartup/credentials`
- NEVER display API keys in conversation
