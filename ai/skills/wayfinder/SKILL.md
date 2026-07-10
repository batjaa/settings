---
name: wayfinder
description: Break a PRD or loose product idea into a phased roadmap of medium/large modules (docs/ROADMAP.md), then resolve open decisions one per session until each module is ready for /to-spec. Use when a feature is too big or foggy for one spec.
disable-model-invocation: true
argument-hint: [path-to-prd.md | module or decision to work on]
---

# Wayfinder

A PRD or loose idea has arrived — too big for one session, and the way from here to shipped isn't visible yet. Wayfinder charts that way as a **roadmap of modules**, then works its open decisions one at a time until every module is sharp enough to hand to `/to-spec`.

**Plan, don't do.** Wayfinder produces decisions and module boundaries, not code and not specs. The pull to just start building is the signal a module is ready — flip its status and stop.

## The map: docs/ROADMAP.md

One committed markdown file per effort — the canonical artifact. It is an **index, not a store**: a decision's detail lives where it was made (a spec, an issue, a linked doc); the map only gists it and links.

```markdown
# Roadmap: <effort name>

## Destination

<one or two lines: what done looks like for the whole effort. Every session orients to this first.>

## Modules

| Module | Size | Depends on | Status | Spec |
|---|---|---|---|---|
| <name> | M/L | <module names or —> | fog / deciding / ready-to-spec / specced / ticketed / done | <link once it exists> |

## Decisions so far

- <Decision name> — <one-line gist>, <link to where the detail lives>

## Not yet specified

<fog of war: questions you can tell are coming but can't phrase sharply yet>

## Out of scope

- <thing consciously ruled out> — <why>
```

## Module sizing

- **Medium**: one spec, roughly 3–10 tickets, one branch. The default target.
- **Large**: split it if seams exist; otherwise accept it as one spec that `/to-tickets` will slice harder.
- Prefer **vertical boundaries** (a user-visible capability: "billing", "notifications") over layers ("the API", "the frontend"). A module should be demoable when done.

## Fog of war

Don't chart what you can't see. The test for **Not yet specified** vs. a module/decision entry: can you state the question precisely now — not answer it, state it? Sharp → list it as an open decision or module. Blurry → leave it in the fog; resolving nearby decisions will graduate it. Out-of-scope items never graduate — they return only if the Destination is redrawn.

## Invocation

Two modes. Either way, **resolve at most one open decision per session** — depth over sweep.

### Chart (given a PRD or idea)

1. Read the PRD; explore the codebase enough to know what already exists.
2. **Name the destination** with the user — it fixes scope, so it comes first. Run `/grilling` (one question at a time, recommended answers included) with `/domain-modeling` sharpening terms as they crystallise.
3. Grill again, **breadth-first** this time: fan out across the whole space for open decisions and module boundaries, a few high-leverage questions at a time — don't go deep on any one thread. If this surfaces no fog and the work fits one spec, skip the map: say so and point at `/to-spec`.
4. Write `docs/ROADMAP.md`: modules in dependency order with status (`ready-to-spec` if nothing blocks it, `deciding`/`fog` otherwise), fog sketched into Not yet specified.
5. Commit it (`docs(roadmap): chart <effort>`). Stop — charting is one session's work.

### Work (given an existing map)

1. Load the map. Pick the decision: the user's, or the one unblocking the most modules.
2. Resolve it with the right tool: `/grilling` + `/domain-modeling` for decisions the user owns (the default); `/research` for external reading (docs, APIs) — its markdown summary becomes the linked asset; `/prototype` when "how should it behave/look" needs a cheap concrete artifact to react to (`/design-explore` for pure visual directions). If it needs async work outside this session (an experiment, a service signup), open a GitHub issue labelled `wayfinder` and link it instead of stalling.
3. Record it: one line in Decisions so far, detail wherever it naturally lives. Graduate any fog the answer sharpened; update module statuses and dependencies.
4. When a module's status flips to `ready-to-spec`, say so and suggest `/to-spec <module>`.
5. Commit the map update.

Refer to modules and decisions **by name** in everything the user reads — never by bare numbers.
