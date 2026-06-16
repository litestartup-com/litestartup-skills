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
✅ Bound to: https://github.com/user/content-repo
   Endpoint: https://api.litestartup.com
   Last sync: 2026-05-28 14:30:00 UTC
   Total syncs: 12
   Conflicts: 0
```

## Error Scenarios

| Error | Cause | Resolution |
|-------|-------|-----------|
| No litestartup.yaml | Not bound | Run `ls-bind.sh` |
| 401 | Key expired | Re-run `ls-bind.sh` |
