---
name: tracker
description: Tracker abstraction for the PRD pipeline — resolves which issue tracker the current repo uses and defines the ticket operations (module parent, sub-issue tickets, blocking edges, frontier query, resolve, rollup). Consult before creating or querying tickets in /to-tickets, /implement, or /wayfinder; then follow the matching platform file.
---

# Tracker

One abstraction for everything the pipeline does with tickets. Skills state *what* to do in tracker operations; the platform file for this repo says *how*.

## Resolve the platform

In order:

1. **`docs/TRACKER.md` in the repo** — names the platform on its first line (`github`, `local`, …) and may override defaults (labels, conventions). Always wins.
2. **GitHub** — if the repo has a GitHub remote (`gh repo view` succeeds). → [github.md](github.md)
3. **Local markdown** — no remote tracker. → [local.md](local.md)

Read the matching platform file before performing any operation. To support a new platform (Linear, a kanban, …), add a `<platform>.md` here implementing the same operations, and point repos at it via `docs/TRACKER.md`.

## The operations

Every platform file defines these; skills reference them by name:

- **Create module parent** — one parent ticket per spec/module, created by `/to-tickets` when the spec is broken down. It carries the link to `docs/specs/<module>.md` and the roadmap, and is the container all the module's tickets hang off.
- **Create ticket (child)** — one per vertical slice, attached to the module parent, created in dependency order (blockers first) so edges can cite real identifiers.
- **Wire blocking** — record each ticket's blockers. Body-level `Blocked by:` lines are always written (the canonical, grep-able form); native dependency links are added on top where the platform has them.
- **Frontier query** — the open, unblocked children of a module parent: what can be started right now.
- **Claim** — mark a ticket as being worked (optional for solo work).
- **Resolve** — close a ticket with a resolution comment: what shipped, commits, verification, deviations.
- **Module rollup** — when the last child closes: close the parent and flip the module's status in `docs/ROADMAP.md`.

## Hierarchy model

```
docs/ROADMAP.md (local, from /wayfinder)
└── module  ──  spec: docs/specs/<module>.md (local, from /to-spec)
        └── module parent ticket          (from /to-tickets)
                ├── ticket (vertical slice)   ← /implement works these
                ├── ticket, blocked by the one above
                └── ticket
```

Specs and the roadmap stay in the repo regardless of platform; only the ticket layer moves between platforms.
