# Agent Skills Specification Reference

> Source: https://agentskills.io (led by Anthropic)
> Last synced: 2025-06-16

This document is a condensed reference of the official Agent Skills specification.
It guides all development within litestartup-skills.
Full specification: https://agentskills.io/specification

---

## Directory Structure

```
skill-name/                    ← Lowercase alphanumeric + hyphens only
├── SKILL.md                   ← Required: metadata + instructions
├── scripts/                   ← Optional: executable code
├── references/                ← Optional: detailed docs, checklists, guides
└── assets/                    ← Optional: templates, configs, diagrams
```

---

## SKILL.md Format

### Frontmatter (Required)

```yaml
---
name: skill-name          # Required: 1-64 chars, lowercase+digits+hyphens, MUST match directory name
description: >            # Required: 1-1024 chars, what it does + when to use it
  Do X for Y projects. Use when the user asks about X or mentions Y.
license: MIT              # Optional
compatibility: >          # Optional: environment requirements
  Requires Node.js 18+ and git
metadata:                 # Optional: arbitrary key-value pairs
  author: litestartup-com
  version: "1.0"
allowed-tools: >          # Optional (experimental): pre-approved tools
  Bash(git:*) Bash(npm:*) Read
---
```

### `name` Rules

- 1–64 characters
- Only lowercase letters (a-z), digits (0-9), and hyphens (-)
- Must not start or end with a hyphen
- Must not contain consecutive hyphens (--)
- **Must match the parent directory name exactly**

### `description` Rules

- 1–1024 characters
- Must describe both **what the skill does** and **when to use it**
- Include specific keywords to help agents identify relevant tasks
- Bad: `"Helps with SaaS."`
- Good: `"Initialize and configure SaaS applications using litesaas-admin boilerplate. Use when the user asks to create a new SaaS project, scaffold an admin panel, or set up LiteStartup integration."`

### Body (Markdown Instructions)

Recommended structure:
- What this skill does
- When to use it (and when not to)
- Inputs needed
- Step-by-step procedure
- Validation / "how to know we're done"
- Common failure modes and fixes

**SKILL.md body should be < 5000 tokens.**

---

## Progressive Disclosure

Agents do not load everything at once:

1. **Metadata** (~100 tokens): name + description loaded at startup for all skills
2. **Instructions** (< 5000 tokens recommended): full SKILL.md body loaded on activation
3. **Resources** (on demand): files in references/, scripts/, assets/ loaded only when needed

---

## Optional Directories

### scripts/

- For operations requiring **deterministic automation**
- Must be self-contained or clearly document dependencies
- Include helpful error messages
- Handle edge cases gracefully

### references/

- Detailed technical documentation
- Form templates, structured data formats
- Domain-specific reference files

### assets/

- Document templates, configuration templates
- Images, diagrams
- Data files, schemas

---

## Script Best Practices

### Progressive Complexity

1. **Markdown-only skill** (most skills) ← default choice
2. Add `scripts/` when you need deterministic automation
3. Use tool/MCP integration only when you need strict typed payloads

### Script Design Principles

1. **Avoid interactive prompts** — use CLI arguments, not `read -rsp`
2. **Support `--help`** — self-documenting usage
3. **Write helpful error messages** — include cause and resolution
4. **Use structured output** — JSON over text-aligned tables
5. **Idempotent** — agents may retry commands
6. **Support `--dry-run`** — preview destructive operations
7. **Meaningful exit codes** — distinct codes for different failure types
8. **Predictable output size** — agents may truncate large output

### Recommended Script Runners

| Language | Runner | Cross-platform |
|----------|--------|---------------|
| Python | `uvx` / `python3` | ✅ |
| Node.js | `npx` / `node` | ✅ |
| Deno | `deno run` | ✅ |
| Bun | `bunx` / `bun run` | ✅ |
| Bash | `bash` | ❌ Not natively supported on Windows |

**Conclusion: Prefer Python/Node.js/Deno scripts over Bash for cross-platform compatibility.**

---

## Skill vs AGENTS.md

| Put in AGENTS.md (global) | Put in a Skill (on-demand) |
|---------------------------|---------------------------|
| Applies to almost every task | Specialized workflow |
| Maximum reliability needed | Used occasionally |
| Agent should never ignore it | Discoverable and reusable across repos/teams |

---

## Naming Conventions Summary

| Item | Rule | Example |
|------|------|---------|
| Skill directory | Lowercase + hyphens | `litestartup-admin/`, `pdf-processing/` |
| SKILL.md `name` | Must match directory name | `litestartup-admin`, `pdf-processing` |
| Script files | Self-descriptive naming | `scripts/validate.sh` |
| Reference files | Uppercase .md or domain naming | `references/API.md` |
| Asset files | Organized by type | `assets/config.example` |

---

## Publishing

- No special publish command required
- Push to a GitHub repository
- Install with `npx skills add <owner>/<repo>`
- Automatically listed on skills.sh after installation

---

## Validation

```bash
npx skills-ref validate ./my-skill
```

Checks SKILL.md format, name rules, and directory structure compliance.
