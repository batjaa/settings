---
name: copy-gstack
version: 1.0.0
description: |
  Sync selected gstack skills from the user's local clone at ~/git/gstack into
  ~/.claude/skills/, stripping gstack runtime scaffolding (preamble bash,
  gbrain, telemetry, voice/writing-style boilerplate, codex dispatch, browse/
  design binary calls). Each managed skill has its own handling rules.
  Use when asked to "update gstack skills", "resync gstack", "copy-gstack",
  "refresh my gstack skills", or after pulling a new gstack release.
allowed-tools:
  - Bash
  - Read
  - Grep
  - Glob
  - Edit
  - Write
  - AskUserQuestion
---

# Copy gstack skills

This skill keeps a curated set of skills sourced from `~/git/gstack` in sync
with `~/.claude/skills/`. The source skills carry a lot of gstack runtime
scaffolding (preamble bash, gbrain context queries, telemetry, codex dispatch,
browse/design binary calls). This skill orchestrates a re-clean and re-install
whenever the source repo updates.

**Do NOT skip phases.** Each phase has a `**STOP.**` gate — the user must
approve before moving to the next.

---

## Managed Skills

| Skill | Source in gstack | Special handling |
|---|---|---|
| `plan-ceo-review` | `plan-ceo-review/` | Standard clean |
| `plan-design-review` | `plan-design-review/` | Standard clean |
| `plan-devex-review` | `plan-devex-review/` | Inline `dx-hall-of-fame.md` |
| `plan-eng-review` | `plan-eng-review/` | Restructure to 11-section shape |
| `autoplan` | `autoplan/` | CEO → design → eng pipeline only (DX phase dropped by user choice) |
| `design-review` | `design-review/` | Reframe `$B`/`$D` binary calls as prose |
| `devex-review` | `devex-review/` | Inline `dx-hall-of-fame.md` |
| `eng-review` | `review/` | **Renamed** from `review` to `eng-review`; inline all `specialists/*.md` and `checklist.md`/`design-checklist.md`/`TODOS-format.md` |
| `design-consultation` | `design-consultation/` | Standard clean |
| `design-shotgun` | `design-shotgun/` | Reframe `design` (GPT Image) calls as self-contained HTML+Tailwind |
| `design-html` | `design-html/` | **Vendor** `vendor/pretext.js` alongside; preserve all Pretext API references and CDN fallback |
| `qa` | `qa/` | Inline `references/issue-taxonomy.md` and `templates/qa-report-template.md`; replace `$B` browse calls with tool-agnostic prose |
| `office-hours` | `office-hours/` | **PORT ONLY.** User's local v3.x.x is a polished fork. Do not overwrite. Diff and surface only substantive new content (new questions, sharper framings, anti-sycophancy rules). User cherry-picks. |

---

## Cleaning Rules (apply to every standard clean)

### Frontmatter — strip these fields
- `preamble-tier`
- `interactive`
- `voice-triggers`
- `triggers`
- `benefits-from`
- `gbrain` (entire block)

Keep only: `name`, `version` (reset to `1.0.0` for fresh installs; bump for updates), `description`, `allowed-tools`.

Drop the `(gstack)` suffix from the description.

### Body — strip these wholesale
- The leading `## Preamble (run first)` bash block (~70-100 lines)
- All `{{...}}` resolver placeholders: `{{PREAMBLE}}`, `{{GBRAIN_CONTEXT_LOAD}}`, `{{BRAIN_PREFLIGHT}}`, `{{SECTION_INDEX:...}}`, `{{BENEFITS_FROM}}`, `{{BASE_BRANCH_DETECT}}`, `{{REDACT_*}}`, etc.
- All references to `~/.claude/skills/gstack/bin/*` binaries: `gstack-update-check`, `gstack-config`, `gstack-repo-mode`, `gstack-slug`, `gstack-review-log`, `gstack-diff-scope`, `gstack-next-version`, etc.
- The `$B` shorthand (gstack browse binary) and `$D` shorthand (gstack design binary). Reframe as tool-agnostic prose: *"use your screenshot or browser tooling"*, *"produce self-contained HTML+Tailwind"*.
- All references to `~/.gstack/` paths, session files, telemetry, learnings, `attempts.jsonl`.
- All shared-preamble sections wholesale (these appear identically in every gstack skill):
  - `Plan Mode Safe Operations`
  - `Skill Invocation During Plan Mode`
  - `Skill routing`
  - `AskUserQuestion Format` (the tool-resolution one — the per-skill ones stay)
  - `Artifacts Sync`
  - `Model-Specific Behavioral Patch`
  - `Voice`
  - `Context Recovery`
  - `Writing Style`
  - `Completeness Principle — Boil the Lake`
  - `Confusion Protocol`
  - `Continuous Checkpoint Mode`
  - `Context Health`
  - `Question Tuning`
  - `Repo Ownership — See Something, Say Something`
  - `Search Before Building`
  - `Completion Status Protocol`
  - `Operational Self-Improvement`
  - `Telemetry (run last)`
  - `Plan Status Footer`
  - `Brain Context (preflight)`
  - `Prerequisite Skill Offer`
- The `<!-- AUTO-GENERATED from SKILL.md.tmpl -->` comments.
- "Outside Voice" / codex parallel-review phases (gstack codex dispatcher dependent). Keep at most a one-line "you may seek a second opinion from another AI tool".
- Greptile integration / triage references.
- Slash-name cross-references to other gstack skills (`/spec`, `/ship`, `/cso`, `/sync-gbrain`, etc.). Rewrite as plain skill names or drop.
- **Promotional / upsell blocks.** Any "personal note from me, Garry Tan", "Garry's Note", YC apply pitch (`ycombinator.com/apply?ref=gstack`), or similar GStack/YC marketing content. Strip the entire block — including surrounding `---` separators and any "One more thing." framing that introduces it.
- **Hardcoded `~/.gstack/` write paths.** Replace any instruction that writes output to `~/.gstack/<anything>/` with a project-local equivalent: prefer `./docs/<skill-name>/`, fall back to the current working directory. The skill must never write outside the current working directory tree.

### Body — keep
- The skill's unique behavior: phases, sections, mode selection, scoring rubrics, ASCII diagrams, tables, example output formats.
- The `**STOP.** AskUserQuestion per issue.` pattern at section boundaries (this matches the `plan-ceo-review` style template).
- Plain git/gh commands: `git log`, `git diff`, `gh pr view`.

### Style reference for output
`/Users/batjaa/.claude/skills/plan-ceo-review/SKILL.md` is the canonical style example. Match its frontmatter shape, prose density, and section pattern.

---

## Phase 1: Pre-flight

### 1A. Confirm source repo state

```bash
cd ~/git/gstack
git status
git rev-parse HEAD
cat VERSION
```

If working tree is dirty, ask the user whether to:
- stash and proceed (preferred — easy to recover)
- discard (only if user confirms changes are throwaway)
- abort

If the local branch is behind `origin/main`, ask the user whether to pull. If they say yes:

```bash
git pull --ff-only origin main
```

If the pull is not fast-forward (diverged), STOP and surface the situation.

### 1B. Snapshot current installed versions

For each managed skill, capture the current `version:` field and last-modified time of `~/.claude/skills/<name>/SKILL.md`. Build a small table the user can see:

```
SKILL                  INSTALLED VERSION   LAST UPDATED
plan-ceo-review        2.0.0               2026-03-29
plan-eng-review        1.0.0               2026-06-07
...
```

**STOP.** Show the user the snapshot, the source `HEAD`, and the source `VERSION`. AskUserQuestion: *"Proceed to detect changes?"*

---

## Phase 2: Change detection

For each managed skill, determine whether the source has changed since the last sync. Heuristic (no persisted state across runs):

1. Read source `<skill>/SKILL.md.tmpl` (and `sections/*.md`, `specialists/*.md`, etc. where present).
2. Read installed `~/.claude/skills/<skill>/SKILL.md`.
3. Compute a rough signal: do any non-scaffolding lines in source differ from the installed prose? Use `grep -v` to filter out lines matching `{{...}}`, `gstack-`, `~/.gstack/`, `$B`, `$D`, then diff the remaining.

Classify each skill as:
- **NO CHANGE** — installed prose covers all current source prose
- **MINOR CHANGE** — small additions/edits to existing sections
- **MAJOR CHANGE** — new sections, restructured methodology, materially different behavior

For each MINOR/MAJOR, summarize in 1-3 bullets what changed.

For `office-hours` specifically (PORT-ONLY rule): always run the logical-diff sub-routine described below, even if the file hash is unchanged from last time. The user's installed version is a polished fork; we never overwrite, only surface candidates.

**STOP.** Present a single table:

```
SKILL                  CHANGE LEVEL   SUMMARY
plan-eng-review        MINOR          New "test coverage diagram" example added
review (→ eng-review)  MAJOR          New "data migration" specialist added
office-hours           PORT-ONLY      2 new pushback patterns surfaced (see detail)
qa                     NO CHANGE      —
...
```

AskUserQuestion per non-NO-CHANGE skill: *"Update this skill?"* — one question per skill, not batched. Default to YES for MINOR, ASK for MAJOR.

---

## Phase 3: Per-skill apply

For each skill the user approved in Phase 2, perform the appropriate workflow:

### 3A. Standard clean (most skills)

1. Read source `<skill>/SKILL.md.tmpl` and any associated `sections/` / `specialists/` / `templates/` / `references/` files.
2. Produce a cleaned SKILL.md applying ALL the Cleaning Rules above.
3. Write to `~/.claude/skills/<skill>/SKILL.md`. Bump `version:` (e.g. `1.0.0` → `1.1.0` for minor, `2.0.0` for major).
4. Verify: frontmatter parses, no `{{...}}` placeholders, no `~/.gstack/` paths, no `$B`/`$D`, no `gstack-` binary references.

### 3B. `eng-review` (renamed from `review`)

Same as Standard clean, but:
- Source is `review/`, destination is `eng-review/`.
- Set `name: eng-review` in frontmatter (NOT `review`).
- Inline ALL `specialists/*.md` (api-contract, data-migration, maintainability, performance, red-team, security, testing) as subsections.
- Inline `checklist.md`, `design-checklist.md`, `TODOS-format.md`.
- Drop `greptile-triage.md` entirely.
- Do NOT create `~/.claude/skills/eng-review/specialists/` or similar subdirs — everything goes inline.

### 3C. `design-html` (vendor preservation)

Same as Standard clean, but:
- Preserve ALL Pretext API references, the smart routing table, the four wiring patterns, the API cheatsheet, and the CDN-fallback wiring (`https://esm.sh/@chenglou/pretext`).
- Copy the vendor file:

```bash
mkdir -p ~/.claude/skills/design-html/vendor
cp ~/git/gstack/design-html/vendor/pretext.js ~/.claude/skills/design-html/vendor/pretext.js
```

- Rewrite local-vendor lookup paths to `~/.claude/skills/design-html/vendor/pretext.js`.

### 3D. `office-hours` (PORT-ONLY)

Do NOT overwrite. The user's installed version is a polished fork. Instead:

1. Read installed `~/.claude/skills/office-hours/SKILL.md`.
2. Read source `~/git/gstack/office-hours/SKILL.md.tmpl` and `sections/design-and-handoff.md`.
3. Logical diff: find content in source that is NOT in installed, filtering out:
   - All gstack-runtime hooks (gbrain, telemetry, codex dispatch, session storage)
   - Style-only rewrites (voice changes without content change)
   - Auto-generated section-index machinery
4. Classify findings as:
   - **High signal** — new questions, sharper framings, new pushback patterns, methodology improvements
   - **Marginal** — borderline content, possibly tangled with runtime
   - **Skip** — pure gstack-runtime additions
5. Present each High signal item via AskUserQuestion (one per question, NOT batched). For each: source file + line range, one-sentence description, one-sentence why-it-matters.
6. For each YES, edit installed SKILL.md in place, slotting the addition into the most natural existing section. Match local v3.x voice (terse, direct, no gstack jargon). Do NOT add gstack-specific paths, binaries, or telemetry. **Reject any candidate that introduces a promotional block (Garry's Note / YC apply pitch) or a `~/.gstack/` write path** — these are auto-strip targets even when surfaced as "new content."
7. After all approved ports, bump `version:` minor (e.g. `3.1.0` → `3.2.0`).

### 3E. `autoplan` (pipeline composition)

The user chose CEO → design → eng (no DX phase). If they later say they want DX in the pipeline, this rule changes — until then, drop any `plan-devex-review` step the source introduces and keep the pipeline 3-stage.

---

## Phase 4: Verification

For every skill written or edited:

1. Read back the first 30 lines and confirm frontmatter shape: only `name`, `version`, `description`, `allowed-tools`.
2. `grep -n` for each of these in the body and confirm zero hits (or only safe incidental references):
   - `{{`
   - `gstack-` (case-insensitive — should not appear in any binary call)
   - `~/.gstack/`
   - `\$B\b` / `\$D\b`
   - `preamble-tier`
   - `voice-triggers`
   - `gbrain:`
   - `Garry Tan` / `Garry's Note` / `ycombinator.com/apply` (promotional content — auto-strip)
3. Confirm `eng-review` (if updated) has no `specialists/` subdirectory next to it — content was inlined.
4. Confirm `design-html` (if updated) has `vendor/pretext.js` present and the size matches source.

If any check fails, STOP and surface the file + line. Do NOT silently fix.

---

## Phase 5: Summary report

Print a single table:

```
SKILL                  ACTION             OLD VERSION   NEW VERSION   LINES
plan-eng-review        UPDATED            1.0.0         1.1.0         467 → 489
eng-review             UPDATED            1.0.0         1.1.0         1049 → 1083
office-hours           PATCHED            3.1.0         3.2.0         344 → 360
qa                     UNCHANGED          1.0.0         1.0.0         532
...
```

And one line per skill on what materially changed (for the UPDATED/PATCHED rows).

Do NOT make any commits in `~/git/gstack`. Do NOT push anything. This skill only writes to `~/.claude/skills/`.

---

## Operating Rules

1. **Always read CLAUDE.md / TODOS.md / MEMORY.md context first** if the user's prompt mentions a specific concern (e.g. "watch out for my Laravel changes").
2. **Never bulk-overwrite without diffing first.** The user's installed copies may have hand-edits.
3. **Never run `git commit`/`git push` in `~/git/gstack`.** This skill is read-only against the source repo.
4. **Never delete the vendor file** for `design-html` even if it's missing from source — the user explicitly opted in to vendor it.
5. **The Cleaning Rules list is the source of truth.** If gstack adds a new shared-preamble section in the future, surface it during Phase 2 as a "candidate strip target" so the user can extend this skill's rules.
6. **Frontmatter `version:` bumps:** minor for content additions, major if the skill's behavior contract changes (e.g. autoplan dropping a phase, eng-review adding a specialist).
7. **One AskUserQuestion at a time.** Never batch multiple decisions into a single prompt.

---

## When to skip the skill entirely

If `~/git/gstack` is not present, or the source `VERSION` is the same as the file you last saw AND no managed skill has been touched in the last sync's snapshot, tell the user the cleanest answer: *"Nothing to update — gstack at vX.Y.Z.0 is already mirrored."*
