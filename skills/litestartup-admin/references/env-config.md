# Environment Configuration Spec

> **When to use**: Setting up or troubleshooting `.env.local` for litesaas-admin.
> **File location**: `.env.local` in project root (gitignored).

## Required Variables

| Variable | Description | Example | Required |
|----------|-------------|---------|----------|
| `LS_API_URL` | LiteStartup API base URL | `https://api.litestartup.com` | ✅ |
| `LS_API_KEY` | LiteStartup API Key (auth scope) | `ls_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx` | ✅ |
| `NEXT_PUBLIC_APP_URL` | Public URL of this app | `http://localhost:3000` | ✅ |

## Optional Variables (Future)

| Variable | Description | When needed |
|----------|-------------|-------------|
| `DATABASE_URL` | PostgreSQL connection string | Phase 2 (Drizzle) |
| `DB_PASSWORD` | Database password | Phase 2 (Docker) |
| `STRIPE_SECRET_KEY` | Stripe API key | When billing is real |
| `STRIPE_WEBHOOK_SECRET` | Stripe webhook secret | When billing is real |

## Security Rules

1. `.env.local` is listed in `.gitignore` — never commit it
2. `LS_API_KEY` is server-side only — never prefix with `NEXT_PUBLIC_`
3. Store the canonical key copy at `~/.litestartup/credentials`
4. In Docker production, pass via `env_file` or Docker secrets

## Template

See `assets/env.local.example` for a copy-paste starting point.

## Validation

After writing `.env.local`, verify with:
```bash
# Check LS connection
curl -s -w "\n%{http_code}" \
  -H "Authorization: Bearer $(cat ~/.litestartup/credentials)" \
  https://api.litestartup.com/client/v2/auth/app/oauth-config
```

Expected: HTTP 200 with JSON body containing OAuth provider config.
