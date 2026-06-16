# LiteStartup Skills

You have access to the LiteStartup skills suite.

## Skill Router

| Skill | Intent | Entry Point |
|-------|--------|-------------|
| litestartup-publish | "publish", "sync", "write content", "send email", "bind repo" | `litestartup-publish/SKILL.md` |
| litestartup-admin | "init saas", "create project", "scaffold", "configure", "deploy" | `litestartup-admin/SKILL.md` |

## How to Use

1. Match user intent to the Skill Router table above
2. Read the matched `SKILL.md` for capability routing
3. Based on user intent, load the relevant file:
   - Publish actions → `litestartup-publish/references/`
   - Writing content → `litestartup-publish/references/`
   - Content templates → `litestartup-publish/assets/`
   - SaaS project init/config → `litestartup-admin/references/`
   - Adding LS features → `litestartup-admin/references/ls-capabilities.md`

## Security

NEVER read or display `~/.litestartup/credentials`.

## Sync

Read `litestartup-publish/references/sync.md` for environment-aware sync:
- **Windows (PowerShell)** → AI-native path (direct REST API calls)
- **Linux / macOS** → `litestartup-publish/scripts/ls-sync.sh`

## Quick Routing

- Bind repo → `litestartup-publish/references/bind.md`
- Sync/publish → `litestartup-publish/references/sync.md`
- Write docs → `litestartup-publish/references/docs.md`
- Write blog → `litestartup-publish/references/blog.md`
- Write website page → `litestartup-publish/references/website.md` (MUST confirm type: website vs block)
- Write changelog → `litestartup-publish/references/changelog.md`
- Send email → `litestartup-publish/references/email.md`
- Init SaaS project → `litestartup-admin/references/init.md`
- Configure LS → `litestartup-admin/references/configure.md`
- Add LS feature → `litestartup-admin/references/ls-capabilities.md`
