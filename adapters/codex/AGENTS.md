# LiteStartup Skills Agent

This workspace is connected to [LiteStartup](https://litestartup.com) via the LiteStartup Skills suite.

## Skill Router

| Skill | Intent | Entry Point |
|-------|--------|-------------|
| litestartup-publish | publish, sync, write content, send email, bind repo | `skills/litestartup-publish/SKILL.md` |
| litestartup-admin | init saas, create project, scaffold, configure, deploy | `skills/litestartup-admin/SKILL.md` |

## Skill Location

- Publish Skill: `skills/litestartup-publish/SKILL.md`
  - References: `skills/litestartup-publish/references/` (capabilities + content specs)
  - Assets: `skills/litestartup-publish/assets/` (starter templates)
  - Scripts: `skills/litestartup-publish/scripts/` (Linux/macOS fallback)
- Admin Skill: `skills/litestartup-admin/SKILL.md`
  - References: `skills/litestartup-admin/references/` (init, configure, status, specs)
  - Assets: `skills/litestartup-admin/assets/` (env template)

## Quick Reference

| User wants to... | Read |
|-----------------|------|
| Bind/connect repo | `skills/litestartup-publish/references/bind.md` |
| Publish/sync content | `skills/litestartup-publish/references/sync.md` |
| Write docs | `skills/litestartup-publish/references/docs.md` |
| Write blog post | `skills/litestartup-publish/references/blog.md` |
| Write website page | `skills/litestartup-publish/references/website.md` |
| Write changelog | `skills/litestartup-publish/references/changelog.md` |
| Send email | `skills/litestartup-publish/references/email.md` |
| Check publish status | `skills/litestartup-publish/references/status.md` |
| Init SaaS project | `skills/litestartup-admin/references/init.md` |
| Configure LS connection | `skills/litestartup-admin/references/configure.md` |
| Add LS feature (email/AI/storage) | `skills/litestartup-admin/references/ls-capabilities.md` |

## IMPORTANT: Skill Isolation

These two skills are INDEPENDENT. Do NOT mix their prerequisites:

- **litestartup-admin** (init/configure): Checks for `.env.local`. Does NOT need `litestartup.yaml`, does NOT need git remote, does NOT need `system.publish` scope.
- **litestartup-publish** (bind/sync): Checks for `litestartup.yaml`. Needs git remote and `system.publish` scope.

When user says "init saas" → go DIRECTLY to `skills/litestartup-admin/references/init.md`. Do NOT check for `litestartup.yaml` or bind flow.

## Sync

Environment-aware (see `skills/litestartup-publish/references/sync.md`):
- **Windows (PowerShell)** → AI-native path (direct REST API calls)
- **Linux / macOS** → `skills/litestartup-publish/scripts/ls-sync.sh`

## Security

- NEVER read or display `~/.litestartup/credentials`
- NEVER display API keys in conversation
