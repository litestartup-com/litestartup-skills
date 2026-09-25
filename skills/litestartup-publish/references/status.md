# Capability: Check Status

> **Trigger**: User says "ls status", "what's synced?", "check sync status".
> **Script (fallback)**: `scripts/ls-status.sh` (Linux/macOS only)

## Flow

The bash script is a Linux/macOS fallback; call the API directly on Windows (or anywhere):

```powershell
$key = (Get-Content "$env:USERPROFILE\.litestartup\credentials" -Raw).Trim()
Invoke-RestMethod -Uri "https://api.litestartup.com/client/v2/repo-sync/status" `
  -Headers @{ Authorization = "Bearer $key" } -Method Get
```

Display `data`: `binding_id`, `repo_url`, `last_synced_at`, `last_synced_sha`, `sync_count`,
`last_error` (only when set).

## Output Format

```
✅ Binding ID:  1906
   Repo URL:    https://git.litestartup.com/team-1/xxx.git
   Last Sync:   2026-05-28 14:30:00
   Last SHA:    6c565fc80ad4...
   Sync Count:  12
   Last Error:  (only shown when non-empty)
```

## Error Scenarios

| Error | Cause | Resolution |
|-------|-------|-----------|
| No litestartup.yaml | Not bound | Run `ls-bind.sh` |
| 401 | Key expired | Re-run `ls-bind.sh` |
