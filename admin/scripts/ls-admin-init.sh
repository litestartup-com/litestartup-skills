#!/usr/bin/env bash
set -euo pipefail

# ─── Source shared library ────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/_lib.sh"

# ─── Configuration ────────────────────────────────────────────────────────────
REPO_URL="https://github.com/litestartup-com/litesaas-admin.git"
LS_API_URL="https://api.litestartup.com"
VERIFY_ENDPOINT="/client/v2/auth/app/oauth-config"

# ─── Usage ────────────────────────────────────────────────────────────────────
usage() {
    echo "Usage: ls-admin-init.sh [project-name]"
    echo ""
    echo "Initialize a new SaaS project from litesaas-admin boilerplate."
    echo ""
    echo "Arguments:"
    echo "  project-name    Directory name for the project (default: my-saas-admin)"
    echo ""
    echo "Examples:"
    echo "  ls-admin-init.sh"
    echo "  ls-admin-init.sh my-app"
    exit 0
}

[[ "${1:-}" == "--help" || "${1:-}" == "-h" ]] && usage

# ─── Determine project directory ──────────────────────────────────────────────
PROJECT_NAME="${1:-my-saas-admin}"
PROJECT_DIR="$(pwd)/${PROJECT_NAME}"

if [ -d "$PROJECT_DIR" ]; then
    ls_error "Directory '${PROJECT_NAME}' already exists. Choose a different name or remove it."
fi

# ─── Clone repository ─────────────────────────────────────────────────────────
ls_info "Cloning litesaas-admin into ${PROJECT_NAME}..."
git clone --depth 1 "$REPO_URL" "$PROJECT_DIR"
rm -rf "${PROJECT_DIR}/.git"
cd "$PROJECT_DIR"
git init -q
ls_ok "Repository cloned and initialized."

# ─── Install dependencies ─────────────────────────────────────────────────────
ls_info "Installing npm dependencies..."
npm install --silent
ls_ok "Dependencies installed."

# ─── Obtain API Key ──────────────────────────────────────────────────────────
if [ ! -f "$CREDENTIALS_FILE" ]; then
    echo ""
    echo "A LiteStartup API Key is required (scope: auth)."
    echo "This key enables user authentication, AI chat, and profile management."
    echo ""
    echo "Generate one at: https://app.litestartup.com/settings/api-keys"
    echo "Required scope: auth"
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

API_KEY=$(cat "$CREDENTIALS_FILE")

# ─── Verify Key scope ─────────────────────────────────────────────────────────
ls_info "Verifying API Key scope..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
    -H "Authorization: Bearer ${API_KEY}" \
    "${LS_API_URL}${VERIFY_ENDPOINT}")

case "$HTTP_CODE" in
    200)
        ls_ok "API Key verified (auth scope confirmed)."
        ;;
    401)
        ls_error "API Key is invalid or expired. Please regenerate at https://app.litestartup.com/settings/api-keys"
        ;;
    403)
        ls_error "API Key is valid but missing 'auth' scope. Add it at https://app.litestartup.com/settings/api-keys"
        ;;
    *)
        ls_warn "Unexpected response (HTTP ${HTTP_CODE}). Proceeding anyway."
        ;;
esac

# ─── Generate .env.local ──────────────────────────────────────────────────────
ENV_FILE="${PROJECT_DIR}/.env.local"

if [ -f "$ENV_FILE" ]; then
    ls_warn ".env.local already exists. Skipping generation."
else
    cat > "$ENV_FILE" <<EOF
LS_API_URL=${LS_API_URL}
LS_API_KEY=${API_KEY}
NEXT_PUBLIC_APP_URL=http://localhost:3000
EOF
    ls_ok ".env.local generated."
fi

# ─── Done ─────────────────────────────────────────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✅ Project ready: ${PROJECT_DIR}"
echo ""
echo "  Available features:"
echo "  ✅ User signup/login (email + verification code + password reset)"
echo "  ✅ Google/GitHub OAuth (LS proxy mode, zero config)"
echo "  ✅ AI Chat (LS LLM Router)"
echo "  ✅ Profile management"
echo "  ✅ Multi-language (zh/en)"
echo "  ✅ Dark mode"
echo "  📋 Dashboard / Users / Notifications (display data)"
echo "  📋 Billing (display data)"
echo ""
echo "  Next steps:"
echo "  1. cd ${PROJECT_NAME}"
echo "  2. npm run dev"
echo "  3. Open http://localhost:3000"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
