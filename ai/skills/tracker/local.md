# Local markdown tracker operations

No remote tracker: the ticket layer lives at `docs/tickets/<module>.md`, committed like any other doc. The file is the module parent; its sections are the tickets.

## File shape

```markdown
# Tickets: <module>

Spec: docs/specs/<module>.md — see docs/ROADMAP.md.
Work the frontier: any unchecked ticket whose blockers are all done.

## <Ticket title>

**What to build:** end-to-end behaviour, from the user's perspective.

**Blocked by:** ticket titles that gate this one, or "None — can start immediately".

- [ ] Acceptance criterion 1
- [ ] Acceptance criterion 2
```

## Operations

- **Create module parent** — create the file with the header block; commit (`docs(tickets): <module>`).
- **Create ticket** — append a section, in dependency order (blockers first, so a linear chain reads top to bottom).
- **Wire blocking** — the `Blocked by:` line, referencing ticket *titles* (no numbers exist here).
- **Frontier query** — read the file: a ticket is takeable when it has unchecked criteria and every ticket named in its `Blocked by:` line has all criteria checked.
- **Claim** — not needed; a single working tree is its own lock.
- **Resolve** — check off the criteria, append a short **Resolution:** line under the ticket (what shipped, commit hashes, deviations); commit together with the code.
- **Module rollup** — when every ticket's criteria are checked, flip the module to `done` in `docs/ROADMAP.md`; keep the tickets file as the record.
