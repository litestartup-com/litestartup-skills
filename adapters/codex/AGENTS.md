# LiteStartup Skills Agent

This workspace is connected to [LiteStartup](https://litestartup.com) via the LiteStartup Skills suite.

## Skill Router

| Skill | Intent | Entry Point |
|-------|--------|-------------|
| publish | publish, sync, write content, send email, bind repo | `litestartup-skills/publish/SKILL.md` |

## Skill Location

- Skills root: `litestartup-skills/`
- Publish Skill entry: `litestartup-skills/publish/SKILL.md` (read this first for routing)
  - Capabilities: `litestartup-skills/publish/capabilities/` (how to perform actions)
  - Content specs: `litestartup-skills/publish/specs/` (how to write content)
  - Templates: `litestartup-skills/publish/templates/` (starter files)
  - Scripts: `litestartup-skills/publish/scripts/` (bash scripts for API calls)
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

## Sync

Environment-aware (see `publish/capabilities/sync.md`):
- **Windows (PowerShell)** → AI-native path (direct REST API calls)
- **Linux / macOS** → `publish/scripts/ls-sync.sh`

## Security

- NEVER read or display `~/.litestartup/credentials`
- NEVER display API keys in conversation
