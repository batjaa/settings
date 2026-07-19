---
name: implement
description: Work one tracker ticket or a markdown plan end to end — pre-flight, /tdd execution with verification, then /implementation-review (bugs + spec + standards + design), then /commit-and-push and close. One ticket per session.
disable-model-invocation: true
argument-hint: [issue-number | path-to-plan.md]
---

# Implement

Drive one unit of work to done. **One ticket per session** — finish it, close it, and tell the user to clear context before the next.

## Step 0: Load the work

- **Ticket id** → load it with its comments (consult `/tracker` for this repo's platform); read the spec via its module parent or `## Spec` link. If anything still blocks it, stop and say so.
- **No argument** → run `/tracker`'s frontier query on the active module's parent: open children whose blockers are all closed. Propose the first; confirm before starting.
- **Markdown path** → plan mode: treat each section/step of the file as a mini-ticket and run this same loop over them, checking off boxes in the file as you go.

## Step 1: Pre-flight

1. **Clean tree** — if dirty, ask: stash or commit first.
2. **Branch** — work on `feat/<module>` (create from the default branch if needed). Never work directly on `main` unless the user says so.
3. **Scan existing code** — check what already exists for this ticket; don't rebuild what's done. Read the spec's Implementation and Testing Decisions for the agreed seams.
4. **Flag external dependencies** (env vars, services, keys) before they surprise us mid-implementation.

## Step 2: Execute

- Follow project conventions (`CLAUDE.md`); respect the spec — implement exactly what it says, nothing more.
- Where a test suite exists, work test-first via `/tdd` at the spec's pre-agreed seams; run typechecking and the relevant test files regularly, not just at the end.
- **Verify behavior, not just green checks** — run the app, hit the endpoint, check the output.
- Ask when the ticket is ambiguous rather than guessing; note any deviation from the spec explicitly.

## Step 3: Completion gate (in order)

1. **Full relevant test suite** passes; app builds/starts.
2. **`/implementation-review`** against the ticket — one pass covering Bugs (delegates to the built-in `/code-review`), Spec (every acceptance criterion demonstrably met, nothing missing, no scope creep), Standards, and Design. Fix confirmed findings; note accepted deviations in the closing comment.
3. **`/commit-and-push`** — it handles `/simplify`, staging, conventional commits, push.
4. **Resolve the ticket** (per `/tracker`): check off its acceptance criteria, comment with what shipped (commits, verification done, deviations), close it — the module parent's progress rolls up automatically.
5. **Module rollup**: if this was the module's last open ticket, close the parent ticket, flip the module to `done` in `docs/ROADMAP.md`, and commit; run a branch-level `/implementation-review` (or `/code-review ultra`) before merging `feat/<module>`.

## Rules

- Never batch tickets silently; never skip the gate because the change "looks done".
- Report honestly: failing tests get reported with output, skipped steps get named.
- End the session by naming the next frontier ticket, and remind the user to clear context.
