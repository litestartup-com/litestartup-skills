# LiteStartup Skills

> Modular AI skill packages for LiteStartup. Install all or pick what you need.

## Available Skills

| Skill | Description | Directory |
|-------|-------------|-----------|
| **Publish** | Publish blog, docs, website, changelog, and send emails from your AI editor | `publish/` |

More skills coming soon: deploy, analytics, admin.

## Quick Start

### Install All Skills

```bash
git clone https://github.com/litestartup-com/litestartup-skills.git
```

### Install a Single Skill (sparse checkout)

```bash
git clone --filter=blob:none --sparse https://github.com/litestartup-com/litestartup-skills.git
cd litestartup-skills
git sparse-checkout set shared publish adapters
```

### Setup Your Editor

Copy the adapter file for your editor into your **content repo** workspace:

| Editor | Copy from | Copy to |
|--------|-----------|----------|
| Windsurf | `adapters/windsurf/.windsurfrules` | `.windsurfrules` (workspace root) |
| Cursor | `adapters/cursor/litestartup.mdc` | `.cursor/rules/litestartup.mdc` |
| Claude Code | `adapters/claude/CLAUDE.md` | `CLAUDE.md` (workspace root) |
| Codex | `adapters/codex/AGENTS.md` | `AGENTS.md` (workspace root) |

### Get API Key

Log in to [LiteStartup Dashboard](https://app.litestartup.com) → Settings → API Keys → Create with `system.publish` scope.

### Bind and Publish

```
> Bind this repo to my LiteStartup account.
> Write a blog post about our new release.
> Sync all my content to production.
```

## Architecture

```
litestartup-skills/
├── README.md                ← You are here
├── RULE.md                  ← Development rules
├── shared/                  ← Shared infrastructure
│   └── _lib.sh             ← Common bash functions (auth, API calls)
├── publish/                 ← Publish Skill
│   ├── SKILL.md            ← Entry point (AI reads this first)
│   ├── capabilities/       ← How to perform actions
│   ├── specs/              ← How to write content
│   ├── templates/          ← Ready-to-use starter files
│   └── scripts/            ← Bash scripts for API calls
└── adapters/               ← Per-editor integration files
    ├── windsurf/.windsurfrules
    ├── cursor/litestartup.mdc
    ├── claude/CLAUDE.md
    └── codex/AGENTS.md
```

## Design Principles

1. **Monorepo** — All skills in one repo. Shared infrastructure, unified versioning.
2. **Modular** — Each skill is self-contained in its own directory. Install all or just one.
3. **Router-based** — Adapters route user intent to the correct skill, then to the correct capability.
4. **Agent-agnostic** — Core logic in SKILL.md + specs/ + capabilities/. Adapters translate to each editor's format.
5. **Spec-driven** — Content rules are precise, with tables and checklists — no ambiguity.
6. **Template-first** — Every content type has a ready-to-copy template file.

## Security

- API keys NEVER appear in AI conversation
- `~/.litestartup/credentials` is read only by scripts
- Scope-limited keys (`system.publish` only)

## Requirements

- `git`, `curl`, `bash` (for Linux/macOS script path)
- A [LiteStartup](https://litestartup.com) account with API key
- A public git repository (GitHub/GitLab/Gitee)

## Links

- **Website**: https://www.litestartup.com/products/litestartup-skills
- **Documentation**: https://www.litestartup.com/docs/en/features/litestartup-skills
- **Demo Repo**: https://github.com/litestartup-com/litestartup-workspace

## License

MIT
