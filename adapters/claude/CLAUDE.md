# LiteStartup Skills

You have access to the LiteStartup skills suite.

## Skill Router

| Skill | Intent | Entry Point |
|-------|--------|-------------|
| publish | "publish", "sync", "write content", "send email", "bind repo" | `litestartup-skills/publish/SKILL.md` |
| admin | "init saas", "create project", "scaffold", "configure", "deploy" | `litestartup-skills/admin/SKILL.md` |

## How to Use

1. Match user intent to the Skill Router table above
2. Read the matched `SKILL.md` for capability routing
3. Based on user intent, load the relevant file:
   - Publish actions → `publish/capabilities/` directory
   - Writing content → `publish/specs/` directory
   - Starting from scratch → `publish/templates/` directory
   - SaaS project init/config → `admin/capabilities/` directory
   - Adding LS features → `admin/specs/ls-capabilities.md`

## Security

NEVER read or display `~/.litestartup/credentials`.

## Sync

Read `publish/capabilities/sync.md` for environment-aware sync:
- **Windows (PowerShell)** → AI-native path (direct REST API calls)
- **Linux / macOS** → `publish/scripts/ls-sync.sh`

## Quick Routing

- Bind repo → `publish/capabilities/bind.md`
- Sync/publish → `publish/capabilities/sync.md`
- Write docs → `publish/specs/docs.md`
- Write blog → `publish/specs/blog.md`
- Write website page → `publish/specs/website.md` (MUST confirm type: website vs block)
- Write changelog → `publish/specs/changelog.md`
- Send email → `publish/capabilities/email.md`
- Init SaaS project → `admin/capabilities/init.md`
- Configure LS → `admin/capabilities/configure.md`
- Add LS feature → `admin/specs/ls-capabilities.md`
