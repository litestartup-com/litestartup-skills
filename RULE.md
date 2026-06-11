# Skill Development Rules

Rules for maintaining and extending litestartup-skills. Follow strictly when adding or updating any file.

---

## Monorepo Structure

```
litestartup-skills/
├── shared/           ← Shared infrastructure (scripts, auth)
├── {skill}/          ← One directory per skill
│   ├── SKILL.md      ← Entry point (router)
│   ├── capabilities/ ← Action specs
│   ├── specs/        ← Content writing specs
│   ├── templates/    ← Copy-paste starter files
│   └── scripts/      ← Bash scripts
└── adapters/         ← Per-editor integration (top-level, routes to all skills)
```

---

## Architecture Invariants

1. **SKILL.md is a router, not a spec.** Keep it under 100 lines. All details go in `specs/` or `capabilities/`.
2. **One file per concern.** Never merge multiple specs or capabilities into one file.
3. **Specs are self-contained.** Each spec file must be independently understandable without reading other files.
4. **Templates are copy-paste ready.** Every template must work as-is when copied to the content repo.
5. **Skills are independent.** Each skill directory must work without depending on other skill directories.
6. **Shared code in `shared/`.** Cross-skill utilities go in `shared/`, never duplicated.

---

## Adding a New Skill

When creating a new skill (e.g., "deploy", "analytics"):

1. Create `{skill}/SKILL.md` with `name: litestartup-{skill}` in frontmatter
2. Create `{skill}/capabilities/` with at least one capability
3. Create `{skill}/README.md` (optional, for humans)
4. Add the skill to the **router table** in all adapter files (`adapters/*/`)
5. Add the skill to the top-level `README.md` Available Skills table

### Skill Naming Convention

- Directory: `{skill}/` (e.g., `publish/`, `deploy/`)
- SKILL.md name: `litestartup-{skill}` (e.g., `litestartup-publish`)

---

## Adding a New Capability

When adding a new action (e.g., "unpublish", "preview"):

1. Create `{skill}/capabilities/{name}.md`
2. Add a row to the **Capability Router** table in `{skill}/SKILL.md`
3. If a new script is needed, create `{skill}/scripts/ls-{name}.sh` (must source `../../shared/_lib.sh`)
4. Update all adapter files (`adapters/*/`)

### Capability File Structure

```markdown
# Capability: {Name}

> **Trigger**: When user says "..."
> **Script**: `scripts/ls-{name}.sh`

## Flow
[numbered steps]

## Prerequisites
[what must exist before running]

## Error Scenarios
[table: Error | Cause | Resolution]
```

---

## Adding a New Content Type

When adding a new content type (e.g., "landing-page", "widget"):

1. Create `{skill}/specs/{type}.md`
2. Add a row to the **Content Type** table in `{skill}/SKILL.md`
3. Create template(s) in `{skill}/templates/{type}/` (or `{skill}/templates/{type}.ext` if single file)
4. Update `litestartup.yaml.example` sync paths if applicable
5. Update all adapter files

### Spec File Structure

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

## Updating Existing Specs

1. **Do not break existing templates.** If a format changes, keep backward compatibility or note it as a breaking change.
2. **Update the checklist** if adding new validation rules.
3. **Add examples** for any new feature — show correct AND incorrect usage where applicable.

---

## Templates Rules

- Path: `{skill}/templates/{type}/` for multi-file types, `{skill}/templates/{type}.ext` for single-file types
- Every template must include all required fields/structure filled with placeholder values
- Use realistic placeholder content (not "lorem ipsum")
- Comments in templates explain what to replace

---

## Adapter Rules

All adapters must be updated when:
- A new skill is added
- A new capability or content type is added to any skill
- The routing table in any SKILL.md changes
- Script names change

Each adapter uses the **native format** of its target editor:
- Windsurf: `.windsurfrules` (plain rules text)
- Cursor: `.mdc` (YAML frontmatter + markdown)
- Claude Code: `CLAUDE.md` (markdown)
- Codex: `AGENTS.md` (markdown)

Adapters should be **lightweight routers** — they tell the AI which skill to use, then point to that skill's SKILL.md for details.

---

## Script Rules

- All scripts source `../../shared/_lib.sh` for shared functions
- Scripts NEVER echo API keys to stdout
- Scripts must handle errors gracefully with `ls_error()` / `ls_warn()` / `ls_ok()`
- New scripts follow naming: `ls-{verb}.sh` (e.g., `ls-preview.sh`)

---

## Naming Conventions

| Item | Convention | Example |
|------|-----------|---------|
| Skill directory | `{skill}/` | `publish/` |
| SKILL.md name | `litestartup-{skill}` | `litestartup-publish` |
| Capability file | `{skill}/capabilities/{verb}.md` | `publish/capabilities/sync.md` |
| Spec file | `{skill}/specs/{content-type}.md` | `publish/specs/docs.md` |
| Script | `{skill}/scripts/ls-{verb}.sh` | `publish/scripts/ls-sync.sh` |
| Template dir | `{skill}/templates/{type}/` | `publish/templates/docs/` |
| Template file | `{skill}/templates/{type}.ext` | `publish/templates/blog-post.md` |

---

## Version Bumping

Update `version` in SKILL.md frontmatter when:
- **Patch** (x.y.Z): Fix typos, clarify wording, update examples
- **Minor** (x.Y.0): Add new capability or content type
- **Major** (X.0.0): Breaking change to file structure or routing

---

## Quality Checklist (Before Committing)

- [ ] SKILL.md router table is up to date
- [ ] New spec/capability follows the file structure template above
- [ ] Templates are valid and copy-paste ready
- [ ] All adapters reference new capabilities/specs
- [ ] Top-level README.md skill table is up to date
- [ ] `litestartup.yaml.example` paths are correct
- [ ] No duplicate information across files
- [ ] Each SKILL.md stays under 100 lines
- [ ] Shared code is in `shared/`, not duplicated across skills
