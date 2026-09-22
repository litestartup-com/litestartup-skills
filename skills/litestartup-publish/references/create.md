# Capability: Create a Managed Site (LS-hosted Gitea)

> **Trigger**: User says "launch a site", "create a website/blog/docs", "start a new site",
> "register a domain and set up a site", or wants a repo but has none yet.
> **Requires**: LS API key with scope `system.publish` (stored at `~/.litestartup/credentials`).

This is the **default, zero-friction path**: LiteStartup hosts the git repo on its own
managed Gitea, so the user needs **only their LS API key** — no GitHub account, no OAuth,
no separate git credential.

For "bring your own GitHub public repo" instead, see `bind.md`.

## Flow

1. Ensure the target domain exists in the user's LS account (they added/registered it).
   You can list domains with `GET /client/v2/repo-sync/domains`.
2. Call create:
   ```
   POST <endpoint>/client/v2/repo-sync/create
   Authorization: Bearer <LS_API_KEY>
   Body: { "domain": "acme.com" }        # or { "domain_slug": "acme" }; optional "theme": "minimal"
   ```
3. Response returns the **proxy clone URL** (never a raw Gitea URL):
   ```
   { "binding_id": ..., "repo_url": "https://git.litestartup.com/team-<id>/acme.git",
     "gitea_full_name": "team-<id>/acme", "domain_slug": "acme", "app_url": "https://acme.com" }
   ```
4. Configure a git credential helper so the LS API key authenticates pushes **without ever
   writing the key into the repo or the remote URL** (see Security below), then clone:
   ```bash
   git clone https://git.litestartup.com/team-<id>/acme.git my-site
   ```
5. The repo already contains the scaffold (`litestartup.yaml`, `website/`, `blog/`, `docs/`,
   `changelog/`). Edit content, then just `git push` — the server auto-publishes on push
   (a webhook triggers sync). No separate "sync" call is needed for managed repos.

## Security — credential helper (key stays in ~/.litestartup/credentials)

Do NOT put the API key in the clone URL or `.git/config`. Configure git to read it from the
existing credentials file at auth time:

```bash
# One-time, inside the cloned repo (or global for the git.litestartup.com host):
git config credential.helper '!f() { echo "username=x"; echo "password=$(cat ~/.litestartup/credentials)"; }; f'
```

- The key is read on demand; it is never stored in the repo or echoed to the agent.
- NEVER print, cat, or display the key in conversation.

## Notes

- Managed repos are **private**; only LS can read them internally for publishing.
- Push publishes automatically; use `status.md` to check sync results if needed.
- To migrate later or keep a copy on GitHub, that's a future option — not required.

## Error Codes

| Code | Meaning | Action |
|------|---------|--------|
| 401 | Key missing/invalid | Re-run bind/setup to store a valid key |
| 403 | Missing scope | Key needs `system.publish` |
| 409 | Domain already has a repo | Already created — just clone `repo_url` from the response |
| 502 | Provisioning failed | Report the error; do NOT retry blindly |
