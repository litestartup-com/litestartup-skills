# Capability: Bind / Unbind Repo

> **Trigger**: User says "bind to litestartup", "connect repo", "unbind", or no `litestartup.yaml` found.
> **Script**: `scripts/ls-bind.sh`

## Bind Flow

1. Ask user to provide their LiteStartup API key (scope: `system.publish`) — only if `~/.litestartup/credentials` missing
2. Run `scripts/ls-bind.sh [--domain <name_or_slug>] [repo_url]`
3. Script performs:
   - Saves key to `~/.litestartup/credentials` (first time only)
   - Calls `GET /client/v2/repo-sync/domains` to list account domains
   - **1 domain** → auto-selects it (zero interaction)
   - **Multiple domains** → shows numbered list, prompts user to choose (or use `--domain`)
   - Calls `POST /client/v2/repo-sync/bind` with `repo_url` + `domain_slug`
   - Creates `litestartup.yaml` in repo root (includes `domain` field for readability)
4. Confirm success: "Repo bound to {domain}. You can now sync content."

## Unbind Flow

1. Run `scripts/ls-bind.sh --unbind [--domain <name_or_slug>]`
2. Script performs:
   - Without `--domain`: reads `domain_slug` from `litestartup.yaml`
   - With `--domain`: resolves name to slug via domains API
   - Calls `DELETE /client/v2/repo-sync/binding` with `domain_slug`
   - Removes `litestartup.yaml` if it matches the unbound slug
3. Confirm success: "Unbound successfully."

## Prerequisites

- Git repo initialized with a remote (GitHub/GitLab/Gitee)
- Valid API key with `system.publish` scope
- At least one domain configured in LiteStartup dashboard

## Error Scenarios

| Error | Cause | Resolution |
|-------|-------|-----------|
| 401 | Invalid/expired API key | Ask user to get a new key from LiteStartup dashboard |
| 409 | Repo already bound to this domain | Not an error — tell user they're already connected |
| No domains | Account has no domains | Ask user to add a domain in LiteStartup dashboard |
| No git remote | Repo has no remote URL | Ask user to `git remote add origin <url>` first |
| Domain not found | `--domain` value doesn't match | Run without `--domain` to see available domains |

## Security

- NEVER display the API key in conversation
- NEVER run `cat ~/.litestartup/credentials`
- The script handles all key storage internally
