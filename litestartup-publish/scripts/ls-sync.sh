#!/usr/bin/env bash
# T-PUBSKILL01 · Sync content repo to LiteStartup.
# Atomic sequence: git add → commit → push → trigger API.
# Usage: ls-sync.sh [commit_message]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/_lib.sh"

# --- Find content repo ---
CONFIG_DIR=$(ls_find_config_dir)
if [ -z "$CONFIG_DIR" ]; then
    ls_error "No litestartup.yaml found. Run ls-bind.sh first."
fi

cd "$CONFIG_DIR"

# --- Check for changes ---
if git diff --quiet HEAD 2>/dev/null && git diff --cached --quiet 2>/dev/null; then
    # Check untracked files in convention directories
    UNTRACKED=$(git ls-files --others --exclude-standard blog/ website/ docs/ changelog/ 2>/dev/null)
    if [ -z "$UNTRACKED" ]; then
        echo "No changes to sync."
        # Still trigger sync in case remote has changes not yet synced
    fi
fi

# --- Git add + commit + push ---
COMMIT_MSG="${1:-content: sync $(date +%Y-%m-%d-%H%M)}"

git add -A blog/ website/ docs/ changelog/ litestartup.yaml 2>/dev/null || true
if ! git diff --cached --quiet 2>/dev/null; then
    git commit -m "$COMMIT_MSG"
    echo "Committed: $COMMIT_MSG"
fi

# Push (fail gracefully if no remote configured)
if git push 2>/dev/null; then
    ls_ok "Pushed to remote"
else
    ls_warn "git push failed (no remote or auth issue). Sync will use last pushed state."
fi

# --- Get commit SHA + domain_slug ---
COMMIT_SHA=$(git rev-parse HEAD 2>/dev/null || echo "")
DOMAIN_SLUG=$(ls_get_domain_slug)

# --- Trigger sync API ---
echo "Triggering sync..."
TRIGGER_BODY="{\"commit_sha\": \"${COMMIT_SHA}\""
if [ -n "$DOMAIN_SLUG" ]; then
    TRIGGER_BODY="${TRIGGER_BODY}, \"domain_slug\": \"${DOMAIN_SLUG}\""
fi
TRIGGER_BODY="${TRIGGER_BODY}}"
RESPONSE=$(ls_api POST "/client/v2/repo-sync/trigger" "$TRIGGER_BODY")

# --- Parse and display results ---
echo ""
echo "$RESPONSE" | python3 -c "
import sys, json
try:
    data = json.loads(sys.stdin.read())['data']
    synced = data.get('synced', {})
    inserted = synced.get('inserted', [])
    updated = synced.get('updated', [])
    skipped = synced.get('skipped', [])
    conflicts = data.get('conflicts', [])
    needs_confirm = data.get('needs_confirm', [])
    urls = data.get('urls', {})

    if inserted:
        print(f'✅ Inserted ({len(inserted)}):')
        for f in inserted: print(f'   + {f}')
    if updated:
        print(f'✅ Updated ({len(updated)}):')
        for f in updated: print(f'   ~ {f}')
    if skipped:
        print(f'⏭️  Skipped ({len(skipped)}): unchanged')
    if conflicts:
        print(f'⚠️  Conflicts ({len(conflicts)}):')
        for c in conflicts: print(f'   ! {c[\"path\"]} (backend modified after last sync)')
    if needs_confirm:
        print(f'❓ Needs confirm ({len(needs_confirm)}):')
        for n in needs_confirm: print(f'   ? {n[\"path\"]} → run ls-unpublish.sh to remove from live site')
    if urls:
        print()
        print('Live URLs:')
        for path, url in urls.items(): print(f'   {path} → {url}')

    if not inserted and not updated and not conflicts:
        print('Nothing new to sync. All files up to date.')
except Exception as e:
    print(f'Response: {sys.stdin.read() if not data else json.dumps(data, indent=2)}')
" 2>/dev/null || echo "$RESPONSE"
