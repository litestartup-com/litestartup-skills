# LiteStartup Skills

> Modular AI skill packages for LiteStartup. Install all or pick what you need.

## What Problem Does It Solve?

Your AI editor writes great code — but publishing content still requires dashboards, CLIs, or manual deploys. **LiteStartup Skills bridges that gap:**

- **One prompt to publish** — write content in your editor, say "sync", and it's live
- **No context switching** — blog, docs, website, changelog, email all from the same workspace
- **Spec-driven quality** — AI follows precise format rules, no broken pages or bad frontmatter
- **Git-native** — your content repo is the single source of truth

## Available Skills

| Skill | Description | Directory |
|-------|-------------|-----------|
| **Publish** | Publish blog, docs, website, changelog, and send campaign emails from your AI editor | `publish/` |

More skills coming soon: video-generator, admin.

## Quick Start

```bash
# 1. Clone
git clone https://github.com/litestartup-com/litestartup-skills.git

# 2. Copy adapter to your content repo
cp litestartup-skills/adapters/codex/AGENTS.md  my-content/AGENTS.md

# 3. Open your content repo in AI editor, then say:
#    "Bind this repo to my LiteStartup account"
#    "Write a blog post about our launch"
#    "Sync all content to production"
```

## Your Content Repo Structure

After binding and writing content, your repo will look like this:

```
my-content/
├── litestartup.yaml          ← Auto-generated config (binding, domain, sync rules)
├── blog/
│   └── announcing-myapp-launch.md
├── website/
│   ├── index.html
│   └── about.html
├── docs/
│   ├── config.json
│   └── en/
│       ├── _nav.md
│       ├── _sidebar.md
│       └── index.md
└── changelog/
    └── v1.0.0.md
```

## Editor Support

| Editor | Adapter file | Copy to |
|--------|-----------|----------|
| Codex | `adapters/codex/AGENTS.md` | `AGENTS.md` |
| Claude Code | `adapters/claude/CLAUDE.md` | `CLAUDE.md` |
| Cursor | `adapters/cursor/litestartup.mdc` | `.cursor/rules/litestartup.mdc` |

## Repo Structure

```
litestartup-skills/
├── shared/_lib.sh            ← Common bash functions (auth, API)
├── publish/                  ← Publish Skill
│   ├── SKILL.md             ← AI entry point (router)
│   ├── capabilities/        ← bind, sync, status, email
│   ├── specs/               ← blog, docs, website, changelog format rules
│   ├── templates/           ← Starter files for each content type
│   └── scripts/             ← Bash automation (ls-sync.sh, ls-bind.sh)
└── adapters/                 ← Per-editor integration files
```

## Security

- API keys NEVER appear in AI conversation or logs
- Keys stored in `~/.litestartup/credentials`, read only by scripts
- Scope-limited: `system.publish` only

## Links

- **Product page**: https://www.litestartup.com/products/litestartup-skills
- **Documentation**: https://www.litestartup.com/docs/en/features/litestartup-skills
- **Demo content repo**: https://github.com/litestartup-com/litestartup-workspace

## License

MIT
