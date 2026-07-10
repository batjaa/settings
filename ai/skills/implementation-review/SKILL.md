---
name: implementation-review
description: Consolidated review of a diff since a fixed point — the built-in /code-review hunts bugs, then three parallel axes report side by side: Spec (vs the ticket/spec), Standards (repo standards + Fowler smell baseline), Design (A Philosophy of Software Design complexity red flags). The low-level complement to /plan-eng-review.
---

# Implementation Review

One review pass for an implemented ticket or branch, four lenses at different altitudes:

- **Bugs** — does the code break? (delegated to the built-in `/code-review`)
- **Spec** — does the code do what the ticket/spec asked, nothing more?
- **Standards** — does the code follow this repo's documented standards and avoid code-level smells?
- **Design** — does the change add complexity the system will pay for later?

The three judgement axes run as **parallel sub-agents** so they don't pollute each other's context; this skill aggregates. Findings are reported, not auto-fixed — the caller (usually `/implement`) decides what to fix.

## Process

### 1. Pin the fixed point

Whatever the user said — a commit SHA, branch name, tag, `HEAD~5`. If they didn't specify one, default to the merge-base with the default branch (`git merge-base main HEAD`); on a `feat/<module>` branch reviewing a single ticket, the last ticket-closing commit is often the better point — confirm which.

Capture the diff command once: `git diff <fixed-point>...HEAD` (three-dot, against the merge-base). Note the commits via `git log <fixed-point>..HEAD --oneline`. Confirm the ref resolves (`git rev-parse`) and the diff is non-empty **before** anything else.

### 2. Identify the spec source

In order: an issue number the user passed or `#N` references in commit messages — `gh issue view <n>` for its **What to build** and **Acceptance criteria** plus the spec it links; the module spec under `docs/specs/` or a path the user passed; otherwise ask. If there genuinely isn't one, the Spec axis skips and the report says "no spec available".

### 3. Identify the standards sources

Anything documenting how code should be written here: the project's `CLAUDE.md`, `CONTRIBUTING.md`, `docs/adr/`, and the lint/format configs (to know what tooling already enforces — those get skipped, on every axis).

### 4. Bugs pass

Run the built-in `/code-review` on the diff. Its confirmed findings become the `## Bugs` section.

### 5. Spawn the three axes in parallel

One message, three `Agent` tool calls (`general-purpose`). Each prompt includes the diff command and commit list, plus:

- **Spec** — the ticket body (acceptance criteria) and/or spec contents. Brief: "Report: (a) requirements/criteria that are missing or partial; (b) behaviour in the diff that wasn't asked for (scope creep); (c) requirements that look implemented but where the implementation looks wrong. Quote the ticket/spec line for each finding. Under 400 words."
- **Standards** — the standards-source files from step 3 **plus [standards-baseline.md](standards-baseline.md) pasted in full** (the sub-agent has no other access to it). Brief: "Report — per file/hunk — (a) every place the diff violates a documented standard: cite the standard; and (b) any baseline smell: name it and quote the hunk. Documented-standard breaches can be hard violations; baseline smells are always judgement calls, and a documented repo standard overrides the baseline. Skip anything tooling enforces. Under 400 words."
- **Design** — **[design-baseline.md](design-baseline.md) pasted in full.** Brief: "Judge the diff against this design baseline. Report each red flag by name with the hunk quoted, and any change that increases complexity (change amplification, cognitive load, unknown unknowns) — including complexity pushed onto callers that the module should absorb. Everything here is a judgement call; a documented repo standard or ADR overrides the baseline. Under 400 words."

### 6. Aggregate

Present `## Bugs`, `## Spec`, `## Standards`, `## Design` — verbatim or lightly cleaned. Do **not** merge or rerank across axes. The same hunk flagged by two axes is signal, not duplication — report it in both. End with one line per axis: finding count and the worst issue within that axis. Don't pick a single winner across axes.

## Why separate axes

A change can pass three lenses and fail the fourth: bug-free code that implements the wrong thing; spec-faithful code that breaks conventions; convention-clean code that ships a shallow, leaky module the next ten changes will pay for. Reporting them separately stops any axis from masking another.
