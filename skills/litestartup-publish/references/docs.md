# Docs Writing Spec

> **When to use**: User wants to create or update documentation pages.
> **File location**: `docs/` directory in the content repo.

## Directory Structure

```
docs/
├── config.json               ← Site configuration (REQUIRED)
├── en/                       ← Language directory (use locale code)
│   ├── _nav.md              ← Top navigation tabs
│   ├── _sidebar.md          ← Left sidebar menu
│   ├── index.md             ← Docs homepage
│   ├── guide/               ← Section directory
│   │   ├── _sidebar.md      ← Section-specific sidebar (optional, overrides parent)
│   │   ├── index.md         ← Section index page
│   │   └── quick-start.md   ← Content page
│   └── api/                 ← Another section
│       └── ...
└── zh/                      ← Additional language (same structure)
    ├── _nav.md
    ├── _sidebar.md
    └── index.md
```

## URL Mapping

| File Path | URL |
|-----------|-----|
| `docs/en/index.md` | `/docs/en/` |
| `docs/en/guide/quick-start.md` | `/docs/en/guide/quick-start` |
| `docs/zh/index.md` | `/docs/zh/` |

Language is always in the URL path, never as a query parameter.

---

## config.json

```json
{
  "site": {
    "title": "My Documentation",
    "description": "Official documentation for My SaaS"
  },
  "locales": {
    "default": "en",
    "available": ["en"]
  },
  "theme": {
    "primary_color": "#3b82f6",
    "dark_mode": true
  },
  "footer": {
    "copyright": "© 2026 My Company"
  }
}
```

**Fields:**
- `site.title` — Browser tab title and header brand name
- `site.description` — SEO meta description
- `locales.default` — Default language (redirects `/docs/` to `/docs/{default}/`)
- `locales.available` — Array of language codes with content
- `theme.primary_color` — Hex color for accent elements
- `theme.dark_mode` — Enable dark mode toggle (true/false)
- `footer.copyright` — Footer copyright text

---

## _nav.md (Top Navigation Tabs)

One tab per line. Links to `index.md` of each section.

```markdown
- [Guide](index.md)
- [API Reference](api/index.md)
- [Development](development/index.md)
```

**Rules:**
- Format: `- [Label](path-to-index.md)`
- Each link MUST point to an `index.md`
- Active tab auto-detected by URL prefix match
- Clicking a tab triggers full page load (loads section sidebar)
- **Every section linked in `_nav.md` MUST have its own `_sidebar.md`** in its directory — otherwise the section will render with the parent sidebar, causing incorrect navigation
- File: `docs/{lang}/_nav.md`

---

## _sidebar.md (Left Sidebar Menu)

```markdown
- [Introduction](index.md)
- **Getting Started**
  - [Quick Start](guide/quick-start.md)
  - [Configuration](guide/configuration.md)
- **Features**
  - [Themes](guide/themes.md)
  - [Search](guide/search.md)
```

**Syntax:**
- `- [Label](path.md)` = clickable link
- `- **Bold Text**` = collapsible group header (with indented children below)
- `  - [Label](path.md)` = child item (2-space indent under group)

**Rules:**
- All paths are relative to the language directory
- Groups with an active child auto-expand; others default collapsed
- API method badges: `- <get>[List Users](api/users-list.md)` → renders colored badge
- Supported methods: `<get>`, `<post>`, `<put>`, `<patch>`, `<delete>`
- File: `docs/{lang}/_sidebar.md`

### Section-specific sidebar

If `docs/{lang}/{section}/_sidebar.md` exists, it **replaces** the parent
sidebar when viewing pages in that section. Links are relative to the section:

```markdown
- [Overview](index.md)
- **Architecture**
  - [Project Structure](architecture.md)
  - [Theme System](theme-system.md)
```

The system auto-prefixes paths with the section name (e.g., `architecture` → `development/architecture`).

---

## Document Page (.md)

Every page starts with YAML frontmatter:

```markdown
---
title: Quick Start
description: Get started in under 2 minutes
order: 1
---

# Quick Start

Introduction paragraph explaining what this page covers.

## Installation

Step-by-step content...

### With npm

\```bash
npm install my-package
\```

## Configuration

> [!TIP]
> Use environment variables for sensitive config values.

See [Configuration Guide](configuration.md) for full details.
```

### Frontmatter Fields

| Field | Required | Description |
|-------|----------|-------------|
| `title` | Yes | Page title (browser tab + sidebar if no _sidebar.md entry) |
| `description` | No | SEO meta description |
| `order` | No | Sort order (lower = first, used when no _sidebar.md) |

### Content Rules

| Rule | Correct | Wrong |
|------|---------|-------|
| First heading | `# Quick Start` (matches title) | Starting without H1 |
| Section headings | `## Installation` (appears in TOC) | Using H1 for sections |
| Sub-sections | `### With npm` | Skipping levels (H2 → H4) |
| Internal links | `[Config](configuration.md)` | `[Config](/docs/en/guide/configuration)` |
| External links | `[GitHub](https://github.com/...)` | No special handling needed |
| Code blocks | ` ```bash ` with language tag | ` ``` ` without language |
| Callouts | `> [!NOTE]` / `> [!TIP]` / `> [!WARNING]` | Custom blockquote styling |
| Images | `![Alt](./images/screenshot.png)` | Absolute URLs preferred for hosted images |

### Callout Types

```markdown
> [!NOTE]
> Informational note for the reader.

> [!TIP]
> Helpful suggestion or best practice.

> [!WARNING]
> Something that could cause issues.

> [!IMPORTANT]
> Critical information the reader must know.

> [!CAUTION]
> Potential data loss or breaking changes.
```

---

## Checklist Before Sync

- [ ] `config.json` exists at `docs/` root
- [ ] At least one language directory exists (e.g., `docs/en/`)
- [ ] `_sidebar.md` exists in each language directory
- [ ] Every section in `_nav.md` has its own `_sidebar.md` (e.g., `reference/_sidebar.md`)
- [ ] Every `.md` page has `title` in frontmatter
- [ ] All internal links use relative paths with `.md` extension
- [ ] No broken links (referenced files exist)
