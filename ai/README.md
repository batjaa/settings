# AI Agent Configuration

This directory is the source of truth for reusable AI agent skills.

## Layout

| Path | Purpose |
|------|---------|
| `skills/<name>/SKILL.md` | Canonical skill instructions. Keep these provider-neutral when practical. |
| `skills/<name>/scripts/` | Optional deterministic scripts bundled with a skill. |
| `skills/<name>/references/` | Optional reference material a skill can load on demand. |
| `skills/<name>/assets/` | Optional templates or assets used by a skill. |
| `providers/<provider>/skills/<name>/` | Optional provider-specific overlay copied after the canonical skill. |

The sync command installs canonical skills into provider-specific locations:

```bash
bin/ai-sync --home
```

By default this syncs Claude and Codex:

| Provider | Home target |
|----------|-------------|
| Claude | `${CLAUDE_HOME:-~/.claude}/skills` |
| Codex | `${CODEX_HOME:-~/.codex}/skills` |

Codex receives a normalized `SKILL.md` frontmatter containing only `name` and
`description`. Claude receives the canonical file as written, so Claude-only
keys such as `allowed-tools` can stay in the source when needed.

The sync replaces only skill directories whose names exist in `ai/skills`.
Marketplace, system, or manually installed provider skills with other names are
left alone.

## Adding A Skill

1. Create `ai/skills/<skill-name>/SKILL.md`.
2. Use lowercase letters, digits, and hyphens for the directory and `name`.
3. Include YAML frontmatter with at least `name` and `description`.
4. Run `bin/ai-sync --check`.
5. Run `bin/ai-sync --home`.

## Adding A Provider

Add a provider target by setting environment variables, or extend `bin/ai-sync`
with a provider case once the target path is stable.

```bash
AI_SYNC_GEMINI_HOME_SKILLS_DIR="$HOME/.gemini/skills" \
AI_SYNC_GEMINI_FRONTMATTER=passthrough \
bin/ai-sync --provider gemini --home
```

Provider overlays live at `ai/providers/<provider>/skills/<skill-name>/`.
Use overlays only for provider-specific files; otherwise edit the canonical
skill in `ai/skills/`.
