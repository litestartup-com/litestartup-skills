#!/usr/bin/env bash
# T-PUBSKILL01 · Check repo sync status.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/_lib.sh"

RESPONSE=$(ls_api GET "/client/v2/repo-sync/status")

echo "$RESPONSE" | python3 -c "
import sys, json
try:
    data = json.loads(sys.stdin.read())['data']
    print(f\"Binding ID:  {data.get('binding_id', 'N/A')}\")
    print(f\"Repo URL:    {data.get('repo_url', 'N/A')}\")
    print(f\"Last Sync:   {data.get('last_synced_at', 'Never')}\")
    print(f\"Last SHA:    {data.get('last_synced_sha', 'N/A')}\")
    print(f\"Sync Count:  {data.get('sync_count', 0)}\")
    if data.get('last_error'):
        print(f\"Last Error:  {data['last_error']}\")
except:
    print(sys.stdin.read())
" 2>/dev/null || echo "$RESPONSE"
