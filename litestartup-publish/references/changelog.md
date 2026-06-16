# Changelog Writing Spec

> **When to use**: User wants to document a release or generate changelog from git history.
> **File location**: `changelog/` directory in the content repo.
> **Format**: Markdown with YAML frontmatter → server converts to HTML.

## File Convention

```
changelog/
├── v0.1.0.md
├── v0.2.0.md
└── v0.3.0.md
```

- Filename should match the version (for easy lookup)
- Sort order determined by `date` field

---

## Template

```markdown
---
title: "v0.2.0"
date: 2026-05-28
tags: ["feature", "bugfix"]
---

## New Features

- **Payment integration** — Stripe checkout for subscriptions
- **Dashboard redesign** — New layout with analytics widgets

## Improvements

- Faster email delivery (3x speed improvement)
- Better mobile responsive layout

## Bug Fixes

- Fixed email sending timeout (#123)
- Fixed login redirect on Safari

## Breaking Changes

- Removed deprecated `/api/v1/users` endpoint (use `/api/v2/users`)
```

---

## Frontmatter Fields

| Field | Required | Type | Default | Description |
|-------|----------|------|---------|-------------|
| `title` | **Yes** | string | — | Version number (e.g., "v0.2.0") |
| `date` | **Yes** | YYYY-MM-DD | — | Release date |
| `tags` | No | string[] | [] | Change categories |

## Allowed Tags

| Tag | Use For |
|-----|---------|
| `feature` | New functionality |
| `improvement` | Enhancement to existing feature |
| `bugfix` | Bug fix |
| `breaking` | Breaking change requiring user action |
| `security` | Security patch |
| `deprecated` | Feature marked for removal |

---

## Content Structure

Use `## H2` headings to group changes by type. Recommended order:

1. `## New Features` — New capabilities
2. `## Improvements` — Enhancements
3. `## Bug Fixes` — Fixes
4. `## Breaking Changes` — Migration required
5. `## Security` — Security updates
6. `## Deprecated` — Upcoming removals

Each item: `- **Short title** — Description (issue #number)`

---

## Generating from Git History

When user says "generate changelog from git":

1. Run `git log --oneline v0.1.0..HEAD` (or since last tag)
2. Group commits by conventional commit prefix:
   - `feat:` → New Features
   - `fix:` → Bug Fixes
   - `perf:` / `refactor:` → Improvements
   - `BREAKING CHANGE:` → Breaking Changes
3. Write to `changelog/vX.Y.Z.md` with proper frontmatter
4. Include date as today

---

## Checklist Before Sync

- [ ] `title` contains version number
- [ ] `date` is set to actual release date
- [ ] Each item is a single bullet with brief description
- [ ] Breaking changes clearly marked
