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
   git add -A blog/ campaign/ website/ docs/ changelog/ litestartup.yaml
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

### Handling `needs_confirm`

If response contains `needs_confirm` items, **only report them to the user**. Do NOT call the confirm API automatically.

Report format:
```
⚠️ Server detected files that may need deletion:
  - [action] [path] (resource_type: [type])
Please handle manually in the LiteStartup dashboard, or remove/add the file in your repo and re-sync.
```

Common scenarios:
- `delete_doc` — .md file removed from repo, server asks to confirm deletion
- `unpublish` — content file removed, server asks to confirm unpublishing

---

## Path B: Script (Linux / macOS / WSL)

```bash
bash scripts/ls-sync.sh "content: add pricing page"
```

Script performs atomically:
- `git add -A blog/ campaign/ website/ docs/ changelog/ litestartup.yaml`
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

**Path format**: relative from repo root, e.g. `website/products/workmail.html`, `docs/en/guide/quick-start.md`. Must start with `blog/`, `campaign/`, `website/`, `docs/`, or `changelog/`.

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
