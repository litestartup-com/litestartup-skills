# LiteStartup Skills Agent

This workspace is connected to [LiteStartup](https://litestartup.com) via the LiteStartup Skills suite.

## Skill Router

| Skill | Intent | Entry Point |
|-------|--------|-------------|
| publish | publish, sync, write content, send email, bind repo | `litestartup-skills/publish/SKILL.md` |
| admin | init saas, create project, scaffold, configure, deploy | `litestartup-skills/admin/SKILL.md` |

## Skill Location

- Skills root: `litestartup-skills/`
- Publish Skill entry: `litestartup-skills/publish/SKILL.md` (read this first for routing)
  - Capabilities: `litestartup-skills/publish/capabilities/` (how to perform actions)
  - Content specs: `litestartup-skills/publish/specs/` (how to write content)
  - Templates: `litestartup-skills/publish/templates/` (starter files)
  - Scripts: `litestartup-skills/publish/scripts/` (bash scripts for API calls)
- Admin Skill entry: `litestartup-skills/admin/SKILL.md`
  - Capabilities: `litestartup-skills/admin/capabilities/` (init, configure, status)
  - Specs: `litestartup-skills/admin/specs/` (env-config, ls-capabilities, features)
  - Templates: `litestartup-skills/admin/templates/`
  - Scripts: `litestartup-skills/admin/scripts/`
- Shared scripts: `litestartup-skills/shared/`

## Quick Reference

| User wants to... | Read |
|-----------------|------|
| Bind/connect repo | `publish/capabilities/bind.md` |
| Publish/sync content | `publish/capabilities/sync.md` |
| Write docs | `publish/specs/docs.md` |
| Write blog post | `publish/specs/blog.md` |
| Write website page | `publish/specs/website.md` |
| Write changelog | `publish/specs/changelog.md` |
| Send email | `publish/capabilities/email.md` |
| Check status | `publish/capabilities/status.md` |
| Init SaaS project | `admin/capabilities/init.md` |
| Configure LS connection | `admin/capabilities/configure.md` |
| Add LS feature (email/AI/storage) | `admin/specs/ls-capabilities.md` |

## Sync

Environment-aware (see `publish/capabilities/sync.md`):
- **Windows (PowerShell)** → AI-native path (direct REST API calls)
- **Linux / macOS** → `publish/scripts/ls-sync.sh`

## Security

- NEVER read or display `~/.litestartup/credentials`
- NEVER display API keys in conversation
