# Skill Development Rules

Rules for maintaining and extending litestartup-skills.
Follow strictly when adding or updating any file.

See `AGENT_SKILLS_SPEC.md` for the official Agent Skills specification reference.

---

## Repository Structure

```
litestartup-skills/
├── shared/                    ← Source of truth for _lib.sh (dev reference only)
├── litestartup-{skill}/       ← One directory per skill (self-contained)
│   ├── SKILL.md               ← Required: metadata + instructions (router)
│   ├── references/            ← Optional: capabilities, specs, guides
│   ├── assets/                ← Optional: templates, configs
│   └── scripts/               ← Optional: executable code (cross-platform preferred)
└── adapters/                  ← Per-editor integration files
```

---

## Architecture Invariants

1. **SKILL.md is a router, not a spec.** Keep body < 5000 tokens. All details go in `references/`.
2. **One file per concern.** Never merge multiple references into one file.
3. **References are self-contained.** Each file must be independently understandable.
4. **Assets are copy-paste ready.** Every template must work as-is when copied.
5. **Skills are self-contained.** Each skill directory must work standalone when installed via `npx skills add`. No cross-directory references (e.g., `../../shared/`).
6. **Shared code: copy, don't reference.** `shared/_lib.sh` is the dev source of truth. Each skill keeps its own copy at `{skill}/scripts/_lib.sh`. Sync all copies when `shared/_lib.sh` changes.
7. **Agent-native first.** Prefer markdown instructions over scripts. Use scripts only when deterministic automation is required.

---

## Adding a New Skill

1. Create `litestartup-{skill}/SKILL.md` — name must match directory name exactly
2. Create `litestartup-{skill}/references/` with at least one reference
3. Add the skill to the **router table** in all adapter files (`adapters/*/`)
4. Add the skill to the top-level `README.md` Available Skills table

### Skill Naming Convention

- Directory: `litestartup-{skill}/` (e.g., `litestartup-publish/`, `litestartup-admin/`)
- SKILL.md `name`: `litestartup-{skill}` (must match directory name)
- Name rules: lowercase a-z, digits 0-9, hyphens only. No leading/trailing/consecutive hyphens.

---

## Adding a New Reference

When adding a new capability or content spec:

1. Create `litestartup-{skill}/references/{name}.md`
2. Add a row to the **router table** in `litestartup-{skill}/SKILL.md`
3. Update all adapter files (`adapters/*/`)

### Reference File Structure (Capability)

```markdown
# Capability: {Name}

> **Trigger**: When user says "..."
> **Mode**: Agent-native (no script required) | Script fallback: `scripts/...`

## Flow
[numbered steps]

## Prerequisites
[what must exist before running]

## Error Scenarios
[table: Error | Cause | Resolution]
```

### Reference File Structure (Content Spec)

```markdown
# {Type} Writing Spec

> **When to use**: [trigger condition]
> **File location**: `{dir}/` directory in the content repo.
> **Format**: [file format description]

## Directory Structure / File Convention
[tree or table showing where files go]

## Template
[complete copy-paste example]

## Fields / Rules
[table or numbered list — no ambiguity]

## Checklist Before Sync
[checkbox list of validation items]
```

---

## Updating Existing References

1. **Do not break existing templates.** Keep backward compatibility or note breaking changes.
2. **Update the checklist** if adding new validation rules.
3. **Add examples** for new features — show correct AND incorrect usage where applicable.

---

## Assets Rules

- Path: `litestartup-{skill}/assets/{type}/` for multi-file types, `litestartup-{skill}/assets/{name}.ext` for single files
- Every template must include all required fields with placeholder values
- Use realistic placeholder content (not "lorem ipsum")
- Comments in templates explain what to replace

---

## Adapter Rules

All adapters must be updated when:
- A new skill is added
- A new reference is added to any skill
- The routing table in any SKILL.md changes

Each adapter uses the **native format** of its target editor:
- Windsurf: `.windsurfrules` (plain rules text)
- Cursor: `.mdc` (YAML frontmatter + markdown)
- Claude Code: `CLAUDE.md` (markdown)
- Codex: `AGENTS.md` (markdown)

Adapters should be **lightweight routers** — they tell the AI which skill to use, then point to that skill's SKILL.md for details.

---

## Script Rules

- **Agent-native first**: Most skills should be markdown-only. Add scripts only for deterministic automation.
- **Cross-platform**: Prefer Node.js (`npx`/`node`) or Python (`uvx`/`python3`) over Bash for cross-platform compatibility.
- Scripts source `_lib.sh` from the same `scripts/` directory (self-contained copy)
- Scripts NEVER echo API keys to stdout
- Scripts must handle errors gracefully with `ls_error()` / `ls_warn()` / `ls_ok()`
- Avoid interactive prompts — use CLI arguments instead of `read -rsp`
- Support `--help` for self-documentation
- Use structured output (JSON) over text-aligned tables

---

## Naming Conventions

| Item | Convention | Example |
|------|-----------|---------|
| Skill directory | `litestartup-{skill}/` | `litestartup-publish/` |
| SKILL.md `name` | `litestartup-{skill}` | `litestartup-publish` |
| Reference file | `references/{name}.md` | `references/sync.md` |
| Asset dir | `assets/{type}/` | `assets/docs/` |
| Asset file | `assets/{name}.ext` | `assets/blog-post.md` |
| Script | `scripts/ls-{verb}.sh` | `scripts/ls-sync.sh` |

---

## Version Bumping

Update `version` in SKILL.md `metadata` when:
- **Patch** (x.y.Z): Fix typos, clarify wording, update examples
- **Minor** (x.Y.0): Add new reference or asset
- **Major** (X.0.0): Breaking change to file structure or routing

---

## Quality Checklist (Before Committing)

- [ ] SKILL.md `name` matches directory name exactly
- [ ] SKILL.md `description` describes what + when to use
- [ ] SKILL.md router table is up to date
- [ ] New reference follows the file structure template above
- [ ] Assets are valid and copy-paste ready
- [ ] All adapters reference new skills/references
- [ ] Top-level README.md skill table is up to date
- [ ] No duplicate information across files
- [ ] Each SKILL.md body stays under 5000 tokens
- [ ] Scripts (if any) are cross-platform or clearly marked as fallback
