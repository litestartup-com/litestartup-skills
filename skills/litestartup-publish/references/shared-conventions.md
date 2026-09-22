# Capability: Shared Content Conventions (shared.yml + content-guide.md)

> **Trigger**: Always — load these before writing/editing any content. Also when the user
> says "update pricing/version everywhere", "keep content consistent", or a repo lacks them.

Two repo-root files keep all content (website, blog, docs, changelog, campaigns, and future
content types) factually and stylistically consistent:

| File | Purpose | Format |
|------|---------|--------|
| `shared.yml` | Single source of truth for **facts** (machine-readable) | YAML |
| `content-guide.md` | **Voice / tone / terminology** conventions (for you to apply) | Markdown |

Both are at the repo root, version-controlled, and **non-secret** (never put API keys here).
The server does **not** publish them (only `blog/website/docs/changelog/campaign` are synced).

## `shared.yml` fields

```yaml
version: 1
identity: { name, tagline, description }
facts:
  product_version: "v1.0.0"
  pricing: { free: "$0", pro: "$12/mo" }
  urls: { website, docs, app }
  contact: { email }
terminology:
  - { use: "AI Gateway", avoid: ["AI stack"] }
```

## How to use it

1. **Before writing any content**, load `shared.yml` + `content-guide.md`.
2. Use `facts.*` values verbatim (pricing, version, URLs). Never hardcode a fact that
   lives in `shared.yml`; never state a value that contradicts it.
3. Apply `content-guide.md` voice + the `terminology` canonical names.

## Missing files (older repos)

If a repo has no `shared.yml` / `content-guide.md`, offer to create them from
`assets/shared.yml` + `assets/content-guide.md`, then help the user fill in the facts.

## Consistency check at sync (advisory)

Before syncing changed content, scan it for facts that contradict `shared.yml`:

- prices / plan names not matching `facts.pricing`
- a version string different from `facts.product_version`
- non-canonical terms listed under a `terminology[].avoid`

If you find a mismatch, **warn the user and suggest the correction** (or updating
`shared.yml` if the fact itself changed). This is advisory — it does not block the sync.
The single-source-of-truth guarantee (mechanical interpolation) is a separate, planned
server feature; until then, this check keeps drift visible.
