# LiteStartup Skills

You have access to the LiteStartup skills suite.

## Skill Router

| Skill | Intent | Entry Point |
|-------|--------|-------------|
| litestartup-publish | "publish", "sync", "write content", "send email", "bind repo" | `skills/litestartup-publish/SKILL.md` |
| litestartup-admin | "init saas", "create project", "scaffold", "configure", "deploy" | `skills/litestartup-admin/SKILL.md` |

## How to Use

1. Match user intent to the Skill Router table above
2. Read the matched `SKILL.md` for capability routing
3. Based on user intent, load the relevant file:
   - Publish actions → `skills/litestartup-publish/references/`
   - Writing content → `skills/litestartup-publish/references/`
   - Content templates → `skills/litestartup-publish/assets/`
   - SaaS project init/config → `skills/litestartup-admin/references/`
   - Adding LS features → `skills/litestartup-admin/references/ls-capabilities.md`

## IMPORTANT: Skill Isolation

These two skills are INDEPENDENT. Do NOT mix their prerequisites:

- **litestartup-admin** (init/configure): Checks for `.env.local`. Does NOT need `litestartup.yaml`, does NOT need git remote, does NOT need `system.publish` scope.
- **litestartup-publish** (bind/sync): Checks for `litestartup.yaml`. Needs git remote and `system.publish` scope.

When user says "init saas" → go DIRECTLY to `skills/litestartup-admin/references/init.md`. Do NOT check for `litestartup.yaml` or bind flow.

## Security

NEVER read or display `~/.litestartup/credentials`.

## Sync

Read `skills/litestartup-publish/references/sync.md` for environment-aware sync:
- **Windows (PowerShell)** → AI-native path (direct REST API calls)
- **Linux / macOS** → `skills/litestartup-publish/scripts/ls-sync.sh`

## Quick Routing

- Bind repo → `skills/litestartup-publish/references/bind.md`
- Sync/publish → `skills/litestartup-publish/references/sync.md`
- Write docs → `skills/litestartup-publish/references/docs.md`
- Write blog → `skills/litestartup-publish/references/blog.md`
- Write website page → `skills/litestartup-publish/references/website.md` (MUST confirm type: website vs block)
- Write changelog → `skills/litestartup-publish/references/changelog.md`
- Send email → `skills/litestartup-publish/references/email.md`
- Init SaaS project → `skills/litestartup-admin/references/init.md`
- Configure LS → `skills/litestartup-admin/references/configure.md`
- Add LS feature → `skills/litestartup-admin/references/ls-capabilities.md`
