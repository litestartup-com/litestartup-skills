# Capability: Configure

> **Trigger**: When user says "configure", "set up env", "connect to LS", "update credentials"
> **Script**: None (agent-driven)

## Flow

1. **Check if project is a litesaas-admin instance**
   - Look for `lib/ls-client.ts` in current directory
   - Missing → "This doesn't appear to be a litesaas-admin project."

2. **Check existing configuration**
   - Read `.env.local` (if exists)
   - Report current state: LS_API_URL set? LS_API_KEY set?

3. **Update credentials if needed**
   - Follow the same Key acquisition flow as `init.md` step 4
   - Write/update `.env.local`

4. **Verify connection**
   - Use the Key to call `GET /client/v2/auth/app/oauth-config`
   - Report: "✅ Connected to LS backend" or error details

## Prerequisites

- Must be inside a litesaas-admin project directory
- `lib/ls-client.ts` must exist

## Error Scenarios

| Error | Cause | Resolution |
|-------|-------|------------|
| `Not a litesaas-admin project` | Wrong directory | cd to the project root |
| `401 on verification` | Invalid Key | Re-enter key |
| `403 on verification` | Missing scope | Add `auth` scope at LS dashboard |
