---
name: implementation-plan
description: |
  This skill should be used when the user asks to "implement the plan",
  "follow the spec", "execute the phase", "work through the plan", or
  provides a markdown implementation plan/spec and expects step-by-step
  execution with commit checkpoints.
disable-model-invocation: true
argument-hint: [path-to-plan.md]
---

# Implementation Plan Executor

Execute a markdown implementation plan step-by-step with commit checkpoints, verification, and progress tracking.

## Step 0: Load the Plan

1. If `$ARGUMENTS` is provided, read that file as the plan.
2. Otherwise, search for the plan in common locations:
   - `docs/PHASE*.md`, `docs/IMPLEMENTATION*.md`, `docs/PLAN*.md`
   - `PHASE*.md`, `IMPLEMENTATION*.md`, `PLAN*.md`
   - `ROADMAP.md` (look for the next unchecked section)
3. If multiple plans exist, ask which one to execute.
4. Display a summary: total steps, estimated scope, files likely touched.

## Step 1: Pre-flight

Before touching any code:

1. **Check git status** — working tree must be clean. If dirty, ask whether to stash or commit first.
2. **Check current branch** — confirm we're on the right branch. If on `main`/`master`, suggest creating a feature branch.
3. **Scan existing code** — for each step in the plan, check what already exists. Don't rebuild what's already done.
4. **Identify dependencies** — flag steps that depend on external setup (env vars, API keys, services) so they don't surprise us mid-implementation.

## Step 2: Execute Step-by-Step

For each step/section in the plan:

### Before implementing:
- State which step is being worked on: `## Step N of M: <title>`
- List the files that will be created or modified
- If the step involves a migration, show the schema before writing it

### While implementing:
- Write the code following project conventions (check `CLAUDE.md`)
- Run tests if they exist and are relevant
- Verify the change works (run the app, check output, hit the endpoint)

### After implementing:
- Commit with a conventional commit message scoped to this step
- Report: `[N/M] ✓ <step title> — committed as <short hash>`
- If the step has sub-tasks, check them off in the plan file if it uses markdown checkboxes

## Step 3: Checkpoint Protocol

After every 2-3 steps (or after any step that changes behavior significantly):

1. Run the test suite if one exists
2. Verify the app still starts/builds
3. Give a brief progress update:
   ```
   Progress: [████████░░] 8/10 steps
   Last commit: abc1234 — feat(sheets): add PDF generation
   Next: Step 9 — Add download endpoint
   Issues: None
   ```

## Step 4: Completion

When all steps are done:

1. Run the full test suite
2. Show a summary of all commits made during this session
3. Update the plan file — check off completed items, note any deviations
4. List anything that was deferred or skipped with rationale
5. Suggest what to do next (push, create PR, start next phase)

## Rules

- **Never skip ahead** — complete steps in order unless a dependency requires reordering
- **Never batch steps silently** — each step gets its own commit
- **Verify before moving on** — don't assume a change works, check it
- **Ask when ambiguous** — if the plan is vague on implementation details, ask rather than guess
- **Respect existing code** — read before writing, don't duplicate what exists
- **Track deviations** — if you deviate from the plan (better approach, bug found, etc.), note it explicitly
- **Don't over-engineer** — implement exactly what the plan says, nothing more
