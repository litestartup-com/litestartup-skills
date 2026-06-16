# Capability: Init

> **Trigger**: When user says "init saas", "create project", "scaffold admin", "initialize"
> **Mode**: Agent-native (no script required — agent executes steps directly)

## Flow

1. **Determine project directory**
   - Ask user for project name (default: `my-saas-admin`)
   - Target: `./<project-name>/` in current working directory
   - If directory exists → abort with error

2. **Clone litesaas-admin**
   ```bash
   git clone https://github.com/litestartup-com/litesaas-admin.git <project-dir>
   rm -rf <project-dir>/.git
   cd <project-dir> && git init
   ```

3. **Install dependencies**
   ```bash
   npm install
   ```

4. **Obtain LS API Key** (zero-friction strategy)

   4a. Check `~/.litestartup/credentials`
   - File exists → read API Key from it
   - File missing → go to step 4c

   4b. Verify Key scope
   ```bash
   curl -s -o /dev/null -w "%{http_code}" \
     -H "Authorization: Bearer <KEY>" \
     https://api.litestartup.com/client/v2/auth/app/oauth-config
   ```
   - `200` → Key valid with `auth` scope ✅
   - `401` → Key invalid/expired → go to 4c
   - `403` → Key valid but missing `auth` scope → tell user:
     "Your API key needs the `auth` scope. Add it at https://app.litestartup.com/settings/api-keys"

   4c. No Key or Key invalid
   - Tell user: "A LiteStartup API Key with `auth` scope is required."
   - Explain purpose: "This key enables user authentication, AI chat, and profile management. Your app data is stored on the LS backend."
   - Provide link: https://app.litestartup.com/settings/api-keys
   - User pastes Key → save to `~/.litestartup/credentials` (chmod 600)
   - Go back to 4b to verify

5. **Generate `.env.local`**
   ```
   LS_API_URL=https://api.litestartup.com
   LS_API_KEY=<key-from-credentials>
   NEXT_PUBLIC_APP_URL=http://localhost:3000
   ```
   - File is gitignored — safe to write
   - DO NOT display the actual key value in conversation

6. **Start development server** (ask user first)
   ```bash
   npm run dev
   ```
   - Verify http://localhost:3000 responds

7. **Output readiness report**
   ```
   ✅ Project ready: <project-dir>

   Available features:
   ✅ User signup/login (email + verification code + password reset)
   ✅ Google/GitHub OAuth (LS proxy mode, zero config)
   ✅ AI Chat (LS LLM Router)
   ✅ Profile management
   ✅ Multi-language (zh/en)
   ✅ Dark mode
   📋 Dashboard / Users / Notifications (display data)
   📋 Billing (display data, connect LS Billing later)

   Next steps:
   1. Open http://localhost:3000 and register your first user
   2. Try the AI chat feature
   3. Customize frontend pages for your product
   ```

## Prerequisites

- Node.js ≥ 18
- npm ≥ 9
- git
- Internet access (to clone repo and connect to LS API)

## Error Scenarios

| Error | Cause | Resolution |
|-------|-------|------------|
| `directory already exists` | Target dir not empty | Choose a different name or delete existing |
| `npm install failed` | Node.js version or network issue | Check Node.js ≥ 18, check network |
| `401 on key verification` | Invalid/expired API Key | Regenerate key at LS dashboard |
| `403 on key verification` | Key lacks `auth` scope | Add `auth` scope to existing key |
| `ECONNREFUSED on localhost:3000` | Port in use or build error | Check port availability, review build logs |
| `clone failed` | Network or GitHub access issue | Check internet, try again |

## Idempotency

- If `.env.local` already exists in target dir → skip generation, warn user
- If `~/.litestartup/credentials` exists → reuse, do not prompt again
- If `node_modules/` exists → skip `npm install`
