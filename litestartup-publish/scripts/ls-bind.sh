#!/usr/bin/env bash
# T-PUBSKILL01 · Bind/unbind a content repo to a LiteStartup domain.
# Usage:
#   ls-bind.sh [--domain <name_or_slug>] [repo_url]
#   ls-bind.sh --unbind [--domain <name_or_slug>]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/_lib.sh"

# --- Parse arguments ---
DOMAIN_ARG=""
UNBIND=false
REPO_URL=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --domain)
            DOMAIN_ARG="$2"
            shift 2
            ;;
        --unbind)
            UNBIND=true
            shift
            ;;
        *)
            REPO_URL="$1"
            shift
            ;;
    esac
done

# --- Ensure credentials ---
if [ ! -f "$CREDENTIALS_FILE" ]; then
    echo "No credentials found. Please paste your LiteStartup API key."
    echo "(Generate one at https://app.litestartup.com/settings/api-keys with scope 'system.publish')"
    echo ""
    read -rsp "API Key: " API_KEY_INPUT
    echo ""

    if [ -z "$API_KEY_INPUT" ]; then
        ls_error "API key cannot be empty."
    fi

    mkdir -p "$(dirname "$CREDENTIALS_FILE")"
    echo -n "$API_KEY_INPUT" > "$CREDENTIALS_FILE"
    chmod 600 "$CREDENTIALS_FILE"
    ls_ok "Credentials saved to ${CREDENTIALS_FILE}"
fi

# =====================================================================
# UNBIND mode
# =====================================================================
if [ "$UNBIND" = true ]; then
    if [ -n "$DOMAIN_ARG" ]; then
        # Unbind specific domain by slug or name
        DOMAIN_SLUG="$DOMAIN_ARG"
        # If it doesn't look like a slug, resolve via domains API
        if [[ ! "$DOMAIN_ARG" =~ ^do ]]; then
            DOMAINS_JSON=$(ls_list_domains)
            DOMAIN_SLUG=$(echo "$DOMAINS_JSON" | python3 -c "
import sys, json
data = json.loads(sys.stdin.read())
target = '${DOMAIN_ARG}'.lower()
for d in data.get('data', {}).get('domains', []):
    if d['domain'].lower() == target or d['full_domain'].lower() == target:
        print(d['domain_slug'])
        sys.exit(0)
print('')
" 2>/dev/null || echo "")
            if [ -z "$DOMAIN_SLUG" ]; then
                ls_error "Domain '${DOMAIN_ARG}' not found in your account."
            fi
        fi
    else
        # Unbind current repo (from litestartup.yaml)
        DOMAIN_SLUG=$(ls_get_domain_slug)
        if [ -z "$DOMAIN_SLUG" ]; then
            ls_error "No litestartup.yaml found. Nothing to unbind."
        fi
    fi

    echo "Unbinding domain_slug: ${DOMAIN_SLUG}"
    RESPONSE=$(ls_api DELETE "/client/v2/repo-sync/binding" "{\"domain_slug\": \"${DOMAIN_SLUG}\"}" nofail)
    UNBOUND=$(echo "$RESPONSE" | grep -oP '"unbound"\s*:\s*\K(true|false)' 2>/dev/null || echo "false")

    if [ "$UNBOUND" = "true" ]; then
        ls_ok "Unbound successfully."
        # Remove local config if it matches
        LOCAL_SLUG=$(ls_get_domain_slug)
        if [ "$LOCAL_SLUG" = "$DOMAIN_SLUG" ] && [ -f "litestartup.yaml" ]; then
            rm -f litestartup.yaml
            ls_ok "Removed litestartup.yaml"
        fi
    else
        ls_warn "No binding found for domain_slug: ${DOMAIN_SLUG}"
    fi
    exit 0
fi

# =====================================================================
# BIND mode
# =====================================================================

# --- Get repo URL ---
if [ -z "$REPO_URL" ]; then
    REPO_URL=$(git remote get-url origin 2>/dev/null || echo "")
fi
if [ -z "$REPO_URL" ]; then
    ls_error "Could not detect repo URL. Pass it as argument: ls-bind.sh <repo_url>"
fi

# --- Fetch domains ---
echo "Fetching your domains..."
DOMAINS_JSON=$(ls_list_domains)

# Parse domains with python3
DOMAIN_INFO=$(echo "$DOMAINS_JSON" | python3 -c "
import sys, json
data = json.loads(sys.stdin.read())
domains = data.get('data', {}).get('domains', [])
if not domains:
    print('ERROR:No domains found. Add a domain in your LiteStartup dashboard first.')
    sys.exit(0)
# Output: index|domain|domain_slug|is_default|bound_repo_or_empty
for i, d in enumerate(domains):
    bound = ''
    if d.get('binding'):
        bound = d['binding'].get('repo_url', '')
    default_mark = ' (default)' if d.get('is_default') else ''
    print(f\"{i}|{d['domain']}{default_mark}|{d['domain_slug']}|{bound}\")
" 2>/dev/null)

if [[ "$DOMAIN_INFO" == ERROR:* ]]; then
    ls_error "${DOMAIN_INFO#ERROR:}"
fi

# Count domains
DOMAIN_COUNT=$(echo "$DOMAIN_INFO" | wc -l)

# --- Resolve target domain ---
SELECTED_DOMAIN=""
SELECTED_SLUG=""

if [ -n "$DOMAIN_ARG" ]; then
    # User specified --domain: match by name or slug
    while IFS='|' read -r idx dname dslug bound; do
        clean_name=$(echo "$dname" | sed 's/ (default)//')
        if [[ "${clean_name,,}" == "${DOMAIN_ARG,,}" ]] || [[ "$dslug" == "$DOMAIN_ARG" ]]; then
            SELECTED_DOMAIN="$clean_name"
            SELECTED_SLUG="$dslug"
            break
        fi
    done <<< "$DOMAIN_INFO"

    if [ -z "$SELECTED_SLUG" ]; then
        ls_error "Domain '${DOMAIN_ARG}' not found. Run without --domain to see available domains."
    fi
elif [ "$DOMAIN_COUNT" -eq 1 ]; then
    # Single domain: auto-select
    IFS='|' read -r idx dname dslug bound <<< "$DOMAIN_INFO"
    SELECTED_DOMAIN=$(echo "$dname" | sed 's/ (default)//')
    SELECTED_SLUG="$dslug"
    echo "Auto-selected domain: ${SELECTED_DOMAIN}"
else
    # Multiple domains: interactive selection
    echo ""
    echo "Your domains:"
    while IFS='|' read -r idx dname dslug bound; do
        num=$((idx + 1))
        if [ -n "$bound" ]; then
            repo_short=$(basename "$bound" .git)
            echo "  ${num}) ${dname}  [bound → ${repo_short}]"
        else
            echo "  ${num}) ${dname}  [not bound]"
        fi
    done <<< "$DOMAIN_INFO"

    echo ""
    read -rp "Select domain (1-${DOMAIN_COUNT}): " SELECTION

    if ! [[ "$SELECTION" =~ ^[0-9]+$ ]] || [ "$SELECTION" -lt 1 ] || [ "$SELECTION" -gt "$DOMAIN_COUNT" ]; then
        ls_error "Invalid selection."
    fi

    TARGET_IDX=$((SELECTION - 1))
    while IFS='|' read -r idx dname dslug bound; do
        if [ "$idx" -eq "$TARGET_IDX" ]; then
            SELECTED_DOMAIN=$(echo "$dname" | sed 's/ (default)//')
            SELECTED_SLUG="$dslug"
            break
        fi
    done <<< "$DOMAIN_INFO"
fi

if [ -z "$SELECTED_SLUG" ]; then
    ls_error "Failed to select a domain."
fi

# --- Call bind API ---
echo "Binding repo: ${REPO_URL} → ${SELECTED_DOMAIN}"
RESPONSE=$(ls_api POST "/client/v2/repo-sync/bind" "{\"repo_url\": \"${REPO_URL}\", \"domain_slug\": \"${SELECTED_SLUG}\"}")

BINDING_ID=$(echo "$RESPONSE" | grep -oP '"binding_id"\s*:\s*\K[0-9]+' 2>/dev/null || echo "")
DOMAIN_SLUG=$(echo "$RESPONSE" | grep -oP '"domain_slug"\s*:\s*"\K[^"]+' 2>/dev/null || echo "$SELECTED_SLUG")

if [ -z "$BINDING_ID" ]; then
    BINDING_ID=$(echo "$RESPONSE" | grep -oP '"binding_id"\s*:\s*\K[0-9]+' 2>/dev/null || echo "unknown")
fi

# --- Create litestartup.yaml ---
ENDPOINT="https://api.litestartup.com"

cat > litestartup.yaml << EOF
version: 1
binding_id: ${BINDING_ID}
domain: ${SELECTED_DOMAIN}
domain_slug: ${DOMAIN_SLUG}
endpoint: ${ENDPOINT}
repo_url: ${REPO_URL}
sync:
  blog:
    path: "blog/**/*.md"
  website:
    path: "website/**/*.html"
  docs:
    path: "docs/**/*.md"
  changelog:
    path: "changelog/**/*.md"
EOF

ls_ok "Created litestartup.yaml"
ls_ok "Repo bound to ${SELECTED_DOMAIN} (binding_id: ${BINDING_ID})"
echo ""
echo "Next steps:"
echo "  1. git add litestartup.yaml && git commit -m 'init litestartup' && git push"
echo "  2. Create content in blog/, website/, docs/, changelog/"
echo "  3. Run ls-sync.sh to publish"
