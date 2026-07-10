---
name: to-spec
description: Turn the current conversation or a ready-to-spec roadmap module into a markdown spec at docs/specs/<module>.md — synthesis of what's already been discussed, no interview. Testing seams are agreed before writing; ends by offering /plan-eng-review as the quality gate.
disable-model-invocation: true
argument-hint: [module-name]
---

# To Spec

Produce a spec (a module-level PRD) from what you already know — the conversation so far, the roadmap module's decisions, and the codebase. **Do NOT interview the user**; open questions should have been settled in `/wayfinder`. If a genuinely blocking unknown surfaces, ask that one question, don't run a questionnaire.

## Process

1. **Gather context.** If a module name is given, read `docs/ROADMAP.md` — the module row, its Decisions-so-far entries, and anything they link. Explore the repo to understand the current state of the code. Use the project's domain vocabulary (`CONTEXT.md`, if present) throughout, and respect ADRs in the area you're touching.

2. **Sketch the testing seams** — where the feature will be tested. Prefer existing seams to new ones; use the highest seam possible; the fewer seams the better (the ideal is one). Propose new seams only at the highest point you can. **Check with the user that these seams match their expectations before writing** — they become `/tdd`'s pre-agreed seams during implementation.

3. **Write the spec** to `docs/specs/<module>.md` using the template below.

4. **Close out**: update the module's status to `specced` in `docs/ROADMAP.md` (link the spec), commit both (`docs(spec): <module>`), then offer the gates: `/plan-eng-review` for architecture rigor, `/plan-ceo-review` if scope itself deserves a challenge. When the spec survives review, point at `/to-tickets docs/specs/<module>.md`.

## Spec template

Do NOT include specific file paths or code snippets — they go stale fast. Exception: a snippet that encodes a decision more precisely than prose can (state machine, schema, type shape) may be inlined within the relevant decision, trimmed to the decision-rich parts.

```markdown
# Spec: <module>

## Problem Statement

The problem the user is facing, from the user's perspective.

## Solution

The solution, from the user's perspective.

## User Stories

A LONG, numbered list covering all aspects of the feature:

1. As an <actor>, I want <feature>, so that <benefit>

## Implementation Decisions

The decisions already made: modules built/modified and their interfaces,
architectural choices, schema changes, API contracts, specific interactions.

## Testing Decisions

The agreed seams. What makes a good test here (external behavior, not
implementation details), which modules get tested, prior art in the codebase.

## Out of Scope

What this spec deliberately does not cover.

## Further Notes
```
