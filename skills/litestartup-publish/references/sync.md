# Capability: Sync Content

> **Trigger**: User says "publish", "sync", "deploy", or after writing content.

## Environment Detection

Before syncing, detect the execution environment:

- **Windows (PowerShell)** → Use **AI-native path** (PowerShell + direct REST API calls)
- **Linux / macOS (bash)** → Use **script path** (`scripts/ls-sync.sh`) as fallback

---

## Path A: AI-Native (Windows / PowerShell)

Use this when running in a Windows environment where bash is unavailable.

### Steps

1. Locate directory containing `litestartup.yaml`
2. Validate changed files have correct frontmatter/structure:
   - Blog: check `title` in frontmatter
   - Docs: check `title` + verify `_sidebar.md` exists
   - Website: check structure matches type (website/block)
   - Changelog: check `title` + `date`
   - Campaign: check `subject` + `from` + `tag` + confirm with user if status is `ready`/`scheduled`
3. Git commit and push:
   ```powershell
   git add -A blog/ campaign/ website/ data/ docs/ changelog/ litestartup.yaml
   git commit -m "content: <brief description>"
   git push
   ```
4. Read config from `litestartup.yaml` (endpoint, domain_slug)
5. Read API key from `~/.litestartup/credentials` (file content is the key — **never display it**)
6. Trigger sync via REST API:
   ```powershell
   $commitSha = git rev-parse HEAD
   $apiKey = (Get-Content "$env:USERPROFILE\.litestartup\credentials" -Raw).Trim()
   # Full sync (all files):
   $body = @{ commit_sha = $commitSha; domain_slug = "<domain_slug_from_yaml>" } | ConvertTo-Json
   # Partial sync (only changed files — optional, faster):
   $changed = (git diff --name-only HEAD~1 HEAD) -match '^(blog|campaign|website|docs|changelog)/'
   if ($changed) {
     $body = @{ commit_sha = $commitSha; domain_slug = "<domain_slug_from_yaml>"; paths = @($changed) } | ConvertTo-Json -Depth 3
   }
   $r = Invoke-RestMethod -Uri "<endpoint>/client/v2/repo-sync/trigger" `
     -Method POST `
     -Headers @{ Authorization = "Bearer $apiKey"; "Content-Type" = "application/json" } `
     -Body $body
   ```
7. Report results using compact output:
   ```powershell
   "code=$($r.code) msg=$($r.message)"
   "inserted=$($r.data.synced.inserted.Count) updated=$($r.data.synced.updated.Count) skipped=$($r.data.synced.skipped_count)"
   if ($r.data.synced.inserted.Count -gt 0) { $r.data.synced.inserted }
   if ($r.data.synced.updated.Count -gt 0) { $r.data.synced.updated }
   if ($r.data.needs_confirm.Count -gt 0) { $r.data.needs_confirm | ConvertTo-Json -Depth 3 }
   if ($r.data.conflicts.Count -gt 0) { $r.data.conflicts | ConvertTo-Json -Depth 3 }
   ```

### Deletions (GitOps desired-state)

The repo is the desired state: removing a content file and syncing **soft-unpublishes**
that page automatically (recoverable — re-add the file + sync to bring it back live).
The response lists these under `unpublished`. Managed-Gitea repos do this on push
automatically (no action needed).

**Mass-deletion safety valve**: if a single sync would unpublish an abnormally large
slice of the site (> 25% of pages **and** ≥ 5 pages — e.g. a deleted directory or wrong
branch), the server does NOT auto-unpublish. Instead it returns `needs_confirm` (the list)
plus a `needs_confirm_token`.

### Handling `needs_confirm`

If the response contains `needs_confirm`, **show the list to the user and ask them to
confirm**. Do NOT confirm automatically.

Report format:
```
⚠️ This sync would unpublish N pages (over the safety threshold):
  - [path] (resource_type: [type])
Confirm to proceed? (these can be restored later by re-adding the files)
```

Only if the user explicitly says yes, call:
```
POST <endpoint>/client/v2/repo-sync/confirm
Body: { "confirm_token": "<needs_confirm_token from the sync response>" }
```
Response: `{ unpublished: [...], count: N }`. The token is short-lived (~1h); if it expired,
re-run sync to get a fresh one. Unpublish is soft (recoverable) — never a hard delete.

---

## Path B: Script (Linux / macOS / WSL)

```bash
# Preview what will be synced (safe, no push):
bash scripts/ls-sync.sh "content: add pricing page"

# Full automation (commit + push + deploy):
bash scripts/ls-sync.sh --yes "content: add pricing page"

# Dry-run (show files, no git operations):
bash scripts/ls-sync.sh --dry-run
```

**Safety model:** Without `--yes`, the script only commits locally. Push + deploy requires explicit `--yes` flag.

With `--yes`, script performs:
- `git add -A blog/ campaign/ website/ data/ docs/ changelog/ litestartup.yaml`
- `git commit -m "<message>"`
- `git push`
- `POST /client/v2/repo-sync/trigger` with commit SHA

## Commit Message Convention

Format: `content: <brief description>`

Examples:
- `content: add pricing page`
- `content: update docs quick-start guide`
- `content: publish v0.3.0 changelog`
- `content: new blog post about email features`
- `content: add June product launch campaign`

## Sync Results

The API returns:
- **inserted** — New files published (full path list)
- **updated** — Existing files updated (full path list)
- **skipped_count** — Number of unchanged files (integer, no path list)
- **conflicts** — Server has newer edits (manual resolution needed)
- **needs_confirm** — Destructive actions pending user decision (report only, do not execute)
- **urls** — Live URLs for published content

## Partial Sync (paths parameter)

The API accepts an optional `paths` array to sync only specific files:

```json
{ "commit_sha": "abc", "domain_slug": "xxx", "paths": ["website/index.html", "blog/new-post.md"] }
```

**Behavior differences**:
- `paths` empty or omitted → **full sync** (all files, deletion detection, updates last_synced_sha)
- `paths` provided → **partial sync** (only listed files, no deletion detection, does NOT update last_synced_sha)

**When to use partial sync**:
- User only changed 1-2 files and wants faster feedback
- AI detects small change set via `git diff --name-only`

**Path format**: relative from repo root, e.g. `website/products/workmail.html`, `docs/en/guide/quick-start.md`, `blog/zh/hello.md`. Must start with `blog/`, `campaign/`, `website/`, `data/`, `docs/`, or `changelog/`.

## Language Directories

`blog/`, `changelog/` and `docs/` treat a leading language directory as the
language of that content, not part of the slug:

| Repo path | Published URL | Stored language |
|-----------|---------------|-----------------|
| `blog/hello.md` | `/blog/hello` | default |
| `blog/zh/hello.md` | `/blog/zh/hello` | `zh` |
| `changelog/v1.0.0.md` | `/changelog` | default |
| `changelog/zh/v1.0.0.md` | `/changelog/zh` | `zh` |
| `docs/zh/guide/intro.md` | `/docs/zh/guide/intro` | `zh` |
| `website/zh/plugins.html` | `/zh/plugins` | (part of the page path) |

- The same slug may exist once per language, so moving a file into `blog/zh/`
  creates a new page and the old one is reported under `needs_confirm`
- A slug equal to a language code (`blog/zh.md`) is rejected and reported in
  `synced.errors`
- Only recognised codes count as a language; `blog/ai/agents.md` stays the slug
  `ai/agents`

## Important Notes

- Sync API is **idempotent** — repeated calls with same commit_sha safely return skipped; safe to re-trigger if unsure whether previous sync succeeded
- Website HTML goes through `parseHtmlTemplate()` on server — structure must match
- Docs files are rendered as-is through markdown parser
- Blog/changelog markdown is converted to HTML server-side
- Always git push BEFORE triggering sync API (server pulls from remote)

## Error Scenarios

| Error | Cause | Resolution |
|-------|-------|-----------|
| 404 | No binding | Run bind flow first (see `references/bind.md`) |
| 422 | Clone/parse failed | Check file structure matches spec |
| 429 | Rate limited | Wait and retry (but do NOT auto-retry) |
| git push fails | Auth issue | User needs to fix git credentials |
