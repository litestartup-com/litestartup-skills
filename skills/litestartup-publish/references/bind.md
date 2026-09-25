# Capability: Bind / Unbind Repo (bring-your-own GitHub public repo)

> **Trigger**: User explicitly says "bind to litestartup", "connect my repo", "unbind", "list domains".
> **This is the fallback path** for users who want to keep their content in their own
> **public** GitHub/GitLab/Gitee repo. The **default/recommended** path is an LS-managed
> private repo (one API key, push-to-publish) — see `references/create.md`. If no
> `litestartup.yaml` exists, prefer `create` unless the user asks to use their own repo.
> **Script (fallback)**: `scripts/ls-bind.sh` (Linux/macOS only)

## Bind Flow

1. Ask user to provide their LiteStartup API key (scope: `system.publish`) — only if `~/.litestartup/credentials` missing
2. Run `bash scripts/ls-bind.sh [--domain <name_or_slug>] [repo_url]` (or agent executes steps directly)
3. Script performs:
   - Saves key to `~/.litestartup/credentials` (first time only)
   - Calls `GET /client/v2/repo-sync/domains` to list account domains
   - **1 domain** → auto-selects it (zero interaction)
   - **Multiple domains** → shows numbered list, prompts user to choose (or use `--domain`)
   - Calls `POST /client/v2/repo-sync/bind` with `repo_url` + `domain_slug`
   - Creates `litestartup.yaml` in repo root (includes `domain` field for readability)
4. Confirm success: "Repo bound to {domain}. You can now sync content."

## Unbind Flow

1. Run `bash scripts/ls-bind.sh --unbind [--domain <name_or_slug>]` (or agent executes steps directly)
2. Script performs:
   - Without `--domain`: reads `domain_slug` from `litestartup.yaml`
   - With `--domain`: resolves name to slug via domains API
   - Calls `DELETE /client/v2/repo-sync/binding` with `domain_slug`
   - Removes `litestartup.yaml` if it matches the unbound slug
3. Confirm success: "Unbound successfully."

## Agent-Native (Windows / REST)

`ls-bind.sh` is a Linux/macOS fallback. On Windows (or agent sessions without bash), run the
same flow via REST with `Authorization: Bearer <key from ~/.litestartup/credentials, never displayed>`:

1. List domains: `GET /client/v2/repo-sync/domains` → pick `domain_slug` (ask the user when several match)
2. Bind: `POST /client/v2/repo-sync/bind` body `{ "repo_url": "...", "domain_slug": "..." }`
3. Write `litestartup.yaml` from the response (`binding_id`, `domain`, `domain_slug`, `endpoint`, `repo_url`)
4. Unbind: `DELETE /client/v2/repo-sync/binding` body `{ "domain_slug": "..." }`; delete the matching `litestartup.yaml`

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
