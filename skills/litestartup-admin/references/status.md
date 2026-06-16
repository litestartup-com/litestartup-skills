# Capability: Status

> **Trigger**: When user says "status", "check project", "is it working"
> **Script**: None (agent-driven)

## Flow

1. **Check project structure**
   - `lib/ls-client.ts` exists?
   - `package.json` has `next` dependency?
   - `.env.local` exists?

2. **Check LS connection**
   - Read `LS_API_KEY` from `.env.local` (do NOT display it)
   - Call `GET /client/v2/auth/app/oauth-config`
   - Report HTTP status

3. **Check dev server**
   - Is port 3000 in use?
   - If yes, try `GET http://localhost:3000` → report status

4. **Output status report**
   ```
   Project: <directory-name>
   LS Backend: ✅ Connected (api.litestartup.com)
   API Key: ✅ Valid (auth scope confirmed)
   Dev Server: ✅ Running on :3000
   OAuth: ✅ Google + GitHub enabled (LS proxy)

   Integrated features:
   ✅ Auth (register/login/oauth/reset)
   ✅ AI Chat
   ✅ Profile
   📋 Dashboard (mock data)
   📋 Users (mock data)
   📋 Billing (mock data)
   ```

## Prerequisites

- Must be inside a litesaas-admin project directory

## Error Scenarios

| Error | Cause | Resolution |
|-------|-------|------------|
| `No .env.local` | Not configured | Run configure capability |
| `401` | Key expired | Re-run configure |
| `ECONNREFUSED` | Dev server not running | Run `npm run dev` |
