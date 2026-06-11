# Website Writing Spec

> **When to use**: User wants to create or update website pages (landing, pricing, etc).
> **File location**: `website/` directory in the content repo.
> **Format**: Raw HTML (NOT markdown). Uses Tailwind CSS.

## CRITICAL: parseHtmlTemplate

When syncing, ALL website HTML goes through `parseHtmlTemplate()` on the server.
This function splits the HTML into 5 parts based on DOM structure.
**If the structure doesn't match, rendering WILL BREAK.**

---

## Page Types

| Type | URL | When to Use | Code Structure |
|------|-----|-------------|----------------|
| **website** | `/` (homepage) | Main/parent page with full layout | Full independent HTML |
| **block** | `/pricing`, `/about`, `/privacy` | Child/module pages | Placeholder template inheriting parent |

### ⚠️ MUST CONFIRM

**If user does not specify the page type, ASK before writing.**
The two types have incompatible code structures.

---

## Type: website (Main/Parent Page)

Full independent HTML with complete structure. Server splits into 5 .phtml parts:

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My SaaS | All-in-one Platform</title>
    <script src="/js/3.4.17.js"></script><!-- Tailwind -->
    <style>
        /* Shared CSS classes: .card, .btn-primary, .fade-in, etc. */
        /* These are available to ALL child pages via header.phtml */
    </style>
</head>
<body>
    <header>
        <nav class="fixed top-0 w-full z-50 ...">
            <!-- Desktop nav -->
            <a href="/" class="...">Logo</a>
            <div class="hidden md:flex gap-6">
                <a href="/pricing">Pricing</a>
                <a href="/docs/en/">Docs</a>
            </div>
        </nav>
        <!-- Mobile Overlay + Drawer (must be inside <header>) -->
        <div id="mobileOverlay" class="fixed inset-0 bg-black/50 hidden ..."></div>
        <div id="mobileDrawer" class="fixed top-0 right-0 w-72 h-full hidden ...">
            <!-- Mobile menu items -->
        </div>
    </header>

    <main>
        <!-- Hero section -->
        <section class="pt-32 pb-20 px-6 text-center">
            <h1 class="text-5xl font-bold">Your SaaS Headline</h1>
            <p class="mt-6 text-xl text-gray-600">Subheadline description</p>
            <a href="/signup{{utm_source}}" class="btn-primary mt-8">Get Started</a>
        </section>

        <!-- More sections... -->

        <script>
            // Page-specific JavaScript (animations, etc.)
        </script>
    </main>

    <footer class="bg-gray-900 text-white py-16 px-6">
        <div class="max-w-6xl mx-auto grid md:grid-cols-4 gap-8">
            <!-- Footer columns -->
        </div>
        <div class="mt-12 text-center text-gray-400">© 2026 My Company</div>
    </footer>

    <!-- Everything below </footer> → footer.phtml -->
    <button id="toTopBtn" class="fixed bottom-6 right-6 ...">↑</button>
    <script>
        // Shared JS: mobile drawer toggle, scroll-to-top, smooth scroll
    </script>
    <script>
        // Analytics (Google, Plausible, etc.)
    </script>
</body>
</html>
```

### How parseHtmlTemplate splits this:

| Part | Content | Saved As |
|------|---------|----------|
| header | `<!DOCTYPE html>` through `</head>` | `header.phtml` |
| menu | `<header>...</header>` (entire tag) | `menu.phtml` |
| layout | Everything between, with `{{header}}` `{{menu}}` `{{bottom}}` `{{footer}}` placeholders | `website.phtml` |
| bottom | `<footer>...</footer>` (entire tag) | `bottom.phtml` |
| footer | Everything after `</footer>` to `</html>` | `footer.phtml` |

---

## Type: block (Child/Module Page)

Inherits header/menu/bottom/footer from the parent page (type: website).
Only write the `<main>` content:

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Pricing | My SaaS</title>
</head>
<body>
    <header><!-- header placeholder --></header>

    <main>
        <!--seo:{"title":"Pricing | My SaaS","description":"Simple, transparent pricing for teams of all sizes","canonical":"https://www.example.com/pricing","og_title":"Pricing | My SaaS","og_description":"Simple, transparent pricing","og_url":"https://www.example.com/pricing","og_image":"https://www.example.com/imgs/pricing-og.jpg"}-->

        <section class="pt-32 pb-20 px-6 text-center">
            <h1 class="text-4xl font-bold">Simple Pricing</h1>
            <p class="mt-4 text-lg text-gray-600 max-w-2xl mx-auto">
                Choose the plan that works for you.
            </p>
        </section>

        <section class="pb-20 px-6">
            <div class="max-w-5xl mx-auto grid md:grid-cols-3 gap-8">
                <!-- Pricing cards using Tailwind -->
            </div>
        </section>

        <script>
            // Page-specific JS (toggle billing period, etc.)
        </script>
    </main>

    <footer><!-- footer placeholder --></footer>
</body>
</html>
```

At render time:
- `<header><!-- header placeholder --></header>` → replaced with parent's `menu.phtml`
- `<footer><!-- footer placeholder --></footer>` → replaced with parent's `bottom.phtml`
- Parent's `header.phtml` provides `<head>` (CSS, fonts, etc.)
- Parent's `footer.phtml` provides shared scripts after footer

---

## Writing Rules

| # | Rule | Applies To |
|---|------|-----------|
| 1 | Use Tailwind classes or `style=""` inline | Both |
| 2 | NEVER put `<style>` in `<head>` (gets replaced by parent for block) | Block |
| 3 | Page-specific JS goes inside `<main>` in `<script>` tags | Both |
| 4 | NEVER put `<script>` outside `<main>` (except in website type's footer area) | Block |
| 5 | Use `<header><!-- header placeholder --></header>` exactly | Block |
| 6 | Use `<footer><!-- footer placeholder --></footer>` exactly | Block |
| 7 | SEO comment recommended as first child of `<main>` (auto-generated if omitted) | Block |
| 8 | Use `{{utm_source}}` in signup/login URLs | Both |
| 9 | Shared CSS classes (`.card`, `.btn-primary`, `.fade-in`) are available | Block |
| 10 | First `<section>` in `<main>` MUST have `pt-24` or more (nav is `fixed h-16`, content will be hidden otherwise) | Both |

---

## SEO Comment (Block Pages — Recommended)

Recommended as first child inside `<main>`, invisible to visitors.
If omitted, server auto-generates default title/description from the page name and URL path.

```html
<!--seo:{"title":"Page Title | Brand","description":"Page description","keywords":"keyword1, keyword2","canonical":"https://www.example.com/page","og_title":"OG Title","og_description":"OG Description","og_url":"https://www.example.com/page","og_image":"https://www.example.com/imgs/og.jpg","og_site_name":"Brand","twitter_title":"Twitter Title","twitter_description":"Twitter Desc","twitter_image":"https://www.example.com/imgs/twitter.jpg","json_ld":{"@type":"FAQPage"}}-->
```

**Available keys:**

| Key | Maps To |
|-----|---------|
| `title` | `<title>` tag |
| `description` | `<meta name="description">` |
| `keywords` | `<meta name="keywords">` |
| `canonical` | `<link rel="canonical">` |
| `og_title` | `<meta property="og:title">` |
| `og_description` | `<meta property="og:description">` |
| `og_url` | `<meta property="og:url">` |
| `og_image` | `<meta property="og:image">` |
| `og_site_name` | `<meta property="og:site_name">` |
| `twitter_title` | `<meta property="twitter:title">` |
| `twitter_description` | `<meta property="twitter:description">` |
| `twitter_image` | `<meta property="twitter:image">` |
| `json_ld` | `<script type="application/ld+json">` in head |

If no `json_ld` provided, server auto-generates a `WebPage` schema from SEO fields.

---

## Directory Organization

```
website/
├── index.html                 ← type: website (homepage, full HTML)
├── pricing.html               ← type: block → /pricing
├── about.html                 ← type: block → /about
├── products/                  ← Product pages
│   ├── workmail.html          ← type: block → /products/workmail
│   └── ai-content.html        ← type: block → /products/ai-content
└── solutions/                 ← Solution pages
    ├── agencies.html          ← type: block → /solutions/agencies
    └── developers.html        ← type: block → /solutions/developers
```

Subdirectories are fully supported. Nesting depth is unlimited.

---

## URL Mapping

**File extension**: `.html` (NOT `.md`). Server processes `.html` files only for website type.

**Special rule**: `index.html` maps to `/` (root path). All other files map to `/{path}` (preserving subdirectory structure).

| File | URL |
|------|-----|
| `website/index.html` | `/` (homepage) |
| `website/pricing.html` | `/pricing` |
| `website/about.html` | `/about` |
| `website/privacy.html` | `/privacy` |
| `website/products/workmail.html` | `/products/workmail` |
| `website/products/ai-content.html` | `/products/ai-content` |
| `website/solutions/agencies.html` | `/solutions/agencies` |
| `website/solutions/developers.html` | `/solutions/developers` |

---

## Checklist Before Sync

- [ ] Page type confirmed (website or block)
- [ ] Structure matches the correct type template exactly
- [ ] Block pages have `<!-- header placeholder -->` and `<!-- footer placeholder -->`
- [ ] Block pages have SEO comment as first child of `<main>` (recommended, not required)
- [ ] No custom CSS classes defined in `<head>` for block pages
- [ ] All JS is inside `<main>` for block pages
- [ ] First `<section>` has `pt-24` or more (fixed nav clearance)
- [ ] `{{utm_source}}` used in signup/login links
