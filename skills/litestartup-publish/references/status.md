# Capability: Check Status

> **Trigger**: User says "ls status", "what's synced?", "check sync status".
> **Script (fallback)**: `scripts/ls-status.sh` (Linux/macOS only)

## Flow

1. Run `bash scripts/ls-status.sh` (or agent calls the API directly)
2. Display to user:
   - Binding status (bound/unbound)
   - Repo URL
   - Last sync time
   - Sync count
   - Any pending conflicts

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
