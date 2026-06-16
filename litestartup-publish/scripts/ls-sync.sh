#!/usr/bin/env bash
# T-PUBSKILL01 · Sync content repo to LiteStartup.
# Sequence: git add → commit → push → trigger API.
#
# Usage:
#   ls-sync.sh [--yes] [--dry-run] [commit_message]
#
# Modes:
#   (default)   Preview changes, commit locally, but DO NOT push or deploy.
#   --yes       Full automation: commit + push + trigger deploy.
#   --dry-run   Show what would be staged. No git operations performed.
#
# Exit codes:
#   0  Success
#   1  Error (no config, API failure)
#   2  Nothing to sync

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/_lib.sh"

# --- Parse arguments ---
AUTO_CONFIRM=false
DRY_RUN=false
COMMIT_MSG=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --yes|-y) AUTO_CONFIRM=true; shift ;;
        --dry-run) DRY_RUN=true; shift ;;
        --help|-h)
            echo "Usage: ls-sync.sh [--yes] [--dry-run] [commit_message]"
            echo ""
            echo "Options:"
            echo "  --yes, -y    Skip confirmation: push + trigger deploy"
            echo "  --dry-run    Preview only, no git operations"
            echo "  --help, -h   Show this help"
            exit 0
            ;;
        *) COMMIT_MSG="$1"; shift ;;
    esac
done

# --- Find content repo ---
CONFIG_DIR=$(ls_find_config_dir)
if [ -z "$CONFIG_DIR" ]; then
    ls_error "No litestartup.yaml found. Run ls-bind.sh first."
fi

cd "$CONFIG_DIR"

# --- Determine what would be staged ---
CONTENT_DIRS="blog/ website/ docs/ changelog/ campaign/"
STAGED_PREVIEW=""

for dir in $CONTENT_DIRS; do
    if [ -d "$dir" ]; then
        STAGED_PREVIEW+=$(git diff --name-only HEAD -- "$dir" 2>/dev/null)
        STAGED_PREVIEW+=$(git ls-files --others --exclude-standard "$dir" 2>/dev/null)
    fi
done
# Also check litestartup.yaml
if git diff --name-only HEAD -- litestartup.yaml 2>/dev/null | grep -q .; then
    STAGED_PREVIEW+="litestartup.yaml"
fi

if [ -z "$STAGED_PREVIEW" ]; then
    echo "No content changes detected."
    if [ "$AUTO_CONFIRM" = true ]; then
        echo "Triggering sync API to check remote state..."
    else
        exit 2
    fi
fi

# --- Dry-run mode: show preview and exit ---
if [ "$DRY_RUN" = true ]; then
    echo "=== DRY RUN: Files that would be staged ==="
    echo "$STAGED_PREVIEW" | sort | sed 's/^/  /'
    echo ""
    echo "No operations performed. Use --yes to execute."
    exit 0
fi

# --- Stage + commit ---
COMMIT_MSG="${COMMIT_MSG:-content: sync $(date +%Y-%m-%d-%H%M)}"

git add -A blog/ website/ docs/ changelog/ campaign/ litestartup.yaml 2>/dev/null || true

if ! git diff --cached --quiet 2>/dev/null; then
    git commit -m "$COMMIT_MSG"
    echo "Committed: $COMMIT_MSG"
else
    echo "Nothing new to commit."
fi

# --- Without --yes: stop here (safe mode) ---
if [ "$AUTO_CONFIRM" != true ]; then
    echo ""
    echo "Changes committed locally. To push and deploy, run:"
    echo "  ls-sync.sh --yes"
    echo ""
    echo "Or manually:"
    echo "  git push && curl (see references/sync.md)"
    exit 0
fi

# --- Push (--yes mode only) ---
if git push 2>/dev/null; then
    ls_ok "Pushed to remote"
else
    ls_warn "git push failed (no remote or auth issue). Sync will use last pushed state."
fi

# --- Get commit SHA + domain_slug ---
COMMIT_SHA=$(git rev-parse HEAD 2>/dev/null || echo "")
DOMAIN_SLUG=$(ls_get_domain_slug)

# --- Trigger sync API (--yes mode only) ---
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
