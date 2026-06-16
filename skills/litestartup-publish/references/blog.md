# Blog Writing Spec

> **When to use**: User wants to write or publish a blog post.
> **File location**: `blog/` directory in the content repo.
> **Format**: Markdown with YAML frontmatter → server converts to HTML.

## File Convention

```
blog/
├── my-first-post.md
├── v020-release.md
└── how-to-setup.md
```

- Filename becomes the default slug: `my-first-post.md` → `/blog/my-first-post`
- Explicit `slug` in frontmatter overrides the filename

---

## Template

```markdown
---
title: "My First Post"
date: 2026-05-28
slug: "my-first-post"
tags: ["release", "feature"]
status: "published"
---

Introduction paragraph — hook the reader.

## Section Heading

Body content in standard Markdown.

- Bullet points
- With details

## Another Section

More content, code blocks, images, etc.

\```bash
npm install my-package
\```
```

---

## Frontmatter Fields

| Field | Required | Type | Default | Description |
|-------|----------|------|---------|-------------|
| `title` | **Yes** | string | — | Post title (displayed as H1) |
| `date` | No | YYYY-MM-DD | today | Publish date |
| `slug` | No | string | filename | URL slug |
| `tags` | No | string[] | [] | Categorization tags |
| `status` | No | string | "published" | `"published"` or `"draft"` |
| `cover_image` | No | string | — | URL to cover/hero image |
| `excerpt` | No | string | first 160 chars | Custom excerpt for listing |

---

## Content Rules

1. **Do NOT include `# Title`** as the first line — the `title` frontmatter is rendered as H1 by the server
2. Use `## H2` for major sections
3. Use standard Markdown: bold, italic, links, code blocks, images, lists
4. Internal links to other blog posts: `[Previous Post](/blog/previous-slug)`
5. Images: use absolute URLs (hosted externally) or relative `./images/` paths

---

## Status Lifecycle

| Status | Behavior |
|--------|----------|
| `draft` | Saved in repo, NOT visible on live site |
| `published` | Visible on live site after sync |

To unpublish: change `status` to `"draft"` and re-sync.

---

## Checklist Before Sync

- [ ] `title` is present in frontmatter
- [ ] `status` is `"published"` (or omitted for default)
- [ ] No duplicate slugs across blog posts
- [ ] Tags are lowercase, hyphenated if multi-word
