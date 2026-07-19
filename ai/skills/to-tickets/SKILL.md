---
name: to-tickets
description: Break a spec into tracer-bullet vertical-slice tickets with Blocked-by edges and publish them to the repo's tracker — a module parent ticket with the tickets as children (GitHub sub-issues by default; see /tracker) — after a granularity check with the user. Feeds /implement.
disable-model-invocation: true
argument-hint: [path-to-spec.md]
---

# To Tickets

Break a spec into **tracer-bullet tickets** — vertical slices, each declaring the tickets that block it — and publish them to the repo's tracker as children of one **module parent ticket**.

## Process

### 1. Gather context

Read the spec (argument, or the module the conversation is about). Explore the codebase if you haven't. Ticket titles and descriptions use the project's domain vocabulary (`CONTEXT.md`, if present) and respect ADRs in the area being touched. Look for **prefactoring** opportunities — "make the change easy, then make the easy change"; prefactors become the first tickets.

### 2. Draft vertical slices

- Each slice cuts a narrow but COMPLETE path through every layer (schema, API, UI, tests) — vertical, never a horizontal slice of one layer.
- A completed slice is demoable or verifiable on its own.
- Each slice fits a single fresh context window.
- Prefactoring first. Give each ticket its **Blocked by** edges; a ticket with no blockers can start immediately.

**Wide refactors are the exception.** One mechanical change whose blast radius spans the codebase (rename a column, retype a shared symbol) can't land as a green vertical slice — sequence it **expand–contract**: an expand ticket adds the new form beside the old; migrate tickets move call sites in batches (per package/directory), each blocked by the expand; a contract ticket deletes the old form, blocked by every migrate batch.

### 3. Quiz the user

Present the breakdown as a numbered list — per ticket: **Title**, **Blocked by**, **What it delivers** (end-to-end behavior). Ask: granularity right? edges correct — does each ticket only depend on what genuinely gates it? merge or split anything? Iterate until approved.

### 4. Publish to the tracker

Consult `/tracker` — it resolves this repo's platform and defines the exact commands. What to publish, in order:

1. **Create the module parent ticket** — titled after the module, linking `docs/specs/<module>.md` and the roadmap. Every ticket below hangs off it (GitHub: native sub-issues), so progress rolls up on the parent.
2. **Create the tickets as children, in dependency order** (blockers first, so edges can cite real identifiers).
3. **Wire the blocking edges** — `Blocked by` body lines always; native dependency links on top where the platform has them.

Do NOT close or modify the spec. Update the module's status to `ticketed` in `docs/ROADMAP.md` if it exists; commit that.

Issue body template — avoid file paths and code snippets (stale fast; same prototype-snippet exception as `/to-spec`):

```markdown
## Spec

docs/specs/<module>.md (+ section if useful)

## What to build

The end-to-end behaviour this ticket makes work, from the user's
perspective — not a layer-by-layer implementation list.

## Acceptance criteria

- [ ] Criterion 1
- [ ] Criterion 2

## Blocked by

- #N, #M — or "None — can start immediately".
```

Finish by pointing at the frontier: work it one ticket at a time with `/implement`, clearing context between tickets.
