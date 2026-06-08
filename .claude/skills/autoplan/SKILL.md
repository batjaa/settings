---
name: autoplan
version: 1.0.0
description: |
  Auto-review pipeline. Chains the CEO, design, and eng plan reviews sequentially
  and auto-decides intermediate questions using 6 decision principles. Surfaces
  only taste decisions and user challenges at a final approval gate. One command,
  fully reviewed plan out.
  Use when asked to "auto review", "autoplan", "run all reviews", "review this
  plan automatically", or "make the decisions for me".
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - AskUserQuestion
---

# Autoplan — Auto-Review Pipeline

One command. Rough plan in, fully reviewed plan out.

Autoplan runs the full CEO, design, and eng plan reviews at full depth — same rigor, same sections, same methodology as running each review manually. The only difference: intermediate AskUserQuestion calls are auto-decided using the 6 principles below. Taste decisions (where reasonable people could disagree) are surfaced at a final approval gate.

The three sibling skills this depends on:
- the `plan-ceo-review` skill (strategy & scope)
- the `plan-design-review` skill (UI/UX, conditional)
- the `plan-eng-review` skill (architecture, tests, security)

Read each from disk and follow it at full depth. Skip only the sub-sections explicitly listed in Phase 0.

---

## The 6 Decision Principles

These rules auto-answer every intermediate question:

1. **Choose completeness** — Ship the whole thing. Pick the approach that covers more edge cases.
2. **Fix the blast radius** — Fix everything in the files this plan modifies + their direct importers. Auto-approve expansions that are in blast radius AND < 1 day of effort (< 5 files, no new infra).
3. **Pragmatic** — If two options fix the same thing, pick the cleaner one. 5 seconds choosing, not 5 minutes.
4. **DRY** — Duplicates existing functionality? Reject. Reuse what exists.
5. **Explicit over clever** — 10-line obvious fix > 200-line abstraction. Pick what a new contributor reads in 30 seconds.
6. **Bias toward action** — Merge > review cycles > stale deliberation. Flag concerns but don't block.

**Conflict resolution (context-dependent tiebreakers):**
- **CEO phase:** P1 (completeness) + P2 (blast radius) dominate.
- **Eng phase:** P5 (explicit) + P3 (pragmatic) dominate.
- **Design phase:** P5 (explicit) + P1 (completeness) dominate.

---

## Decision Classification

Every auto-decision is classified:

**Mechanical** — one clearly right answer. Auto-decide silently.
Examples: run evals (always yes), reduce scope on a complete plan (always no).

**Taste** — reasonable people could disagree. Auto-decide with recommendation, but surface at the final gate. Three natural sources:
1. **Close approaches** — top two are both viable with different tradeoffs.
2. **Borderline scope** — in blast radius but 3-5 files, or ambiguous radius.
3. **Reviewer disagreements** — an external reviewer recommends differently and has a valid point.

**User Challenge** — the review concludes the user's stated direction should change. This is qualitatively different from taste decisions. When the analysis recommends merging, splitting, adding, or removing features/skills/workflows that the user specified, this is a User Challenge. It is NEVER auto-decided.

User Challenges go to the final approval gate with richer context than taste decisions:
- **What the user said:** (their original direction)
- **What the review recommends:** (the change)
- **Why:** (the reasoning)
- **What context we might be missing:** (explicit acknowledgment of blind spots)
- **If we're wrong, the cost is:** (what happens if the user's original direction was right and we changed it)

The user's original direction is the default. The analysis must make the case for change, not the other way around.

**Exception:** If the change is flagged as a security vulnerability or feasibility blocker (not a preference), the AskUserQuestion framing explicitly warns: "This is a security/feasibility risk, not just a preference." The user still decides, but the framing is appropriately urgent.

---

## Sequential Execution — MANDATORY

Phases MUST execute in strict order: CEO → Design → Eng. Each phase MUST complete fully before the next begins. NEVER run phases in parallel — each builds on the previous.

Between each phase, emit a phase-transition summary and verify that all required outputs from the prior phase are written before starting the next.

---

## What "Auto-Decide" Means

Auto-decide replaces the USER'S judgment with the 6 principles. It does NOT replace the ANALYSIS. Every section in each loaded review skill must still be executed at the same depth as the interactive version. The only thing that changes is who answers the AskUserQuestion: you do, using the 6 principles, instead of the user.

**Two exceptions — never auto-decided:**
1. Premises (Phase 1) — require human judgment about what problem to solve.
2. User Challenges — when the analysis concludes the user's stated direction should change. The user always has context the review lacks. See Decision Classification above.

**You MUST still:**
- READ the actual code, diffs, and files each section references
- PRODUCE every output the section requires (diagrams, tables, registries, artifacts)
- IDENTIFY every issue the section is designed to catch
- DECIDE each issue using the 6 principles (instead of asking the user)
- LOG each decision in the audit trail

**You MUST NOT:**
- Compress a review section into a one-liner table row
- Write "no issues found" without showing what you examined
- Skip a section because "it doesn't apply" without stating what you checked and why
- Produce a summary instead of the required output (e.g., "architecture looks good" instead of the ASCII dependency graph the section requires)

"No issues found" is a valid output for a section — but only after doing the analysis. State what you examined and why nothing was flagged (1-2 sentences minimum). "Skipped" is never valid for a non-skip-listed section.

---

## Phase 0: Intake + Restore Point

### Step 1: Capture restore point

Before doing anything, save the plan file's current state to an external file so the run can be undone:

```bash
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null | tr '/' '-')
DATETIME=$(date +%Y%m%d-%H%M%S)
REPO_NAME=$(basename "$(git rev-parse --show-toplevel 2>/dev/null)")
RESTORE_DIR="$HOME/.autoplan-restore/$REPO_NAME"
mkdir -p "$RESTORE_DIR"
RESTORE_PATH="$RESTORE_DIR/${BRANCH}-autoplan-restore-${DATETIME}.md"
echo "RESTORE_PATH=$RESTORE_PATH"
```

Write the plan file's full contents to the restore path with this header:

```
# Autoplan Restore Point
Captured: [timestamp] | Branch: [branch] | Commit: [short hash]

## Re-run Instructions
1. Copy "Original Plan State" below back to your plan file
2. Invoke autoplan again

## Original Plan State
[verbatim plan file contents]
```

Then prepend a one-line HTML comment to the plan file:
`<!-- autoplan restore point: [RESTORE_PATH] -->`

### Step 2: Read context

- Read CLAUDE.md, TODOS.md, `git log -30`, `git diff <base>..HEAD --stat` against the base branch
- Detect UI scope: grep the plan for view/rendering terms (component, screen, form, button, modal, layout, dashboard, sidebar, nav, dialog). Require 2+ matches. Exclude false positives ("page" alone, "UI" in acronyms).

### Step 3: Load review skills from disk

Read each file using the Read tool:
- `~/.claude/skills/plan-ceo-review/SKILL.md`
- `~/.claude/skills/plan-design-review/SKILL.md` (only if UI scope detected)
- `~/.claude/skills/plan-eng-review/SKILL.md`

**Section skip list — when following a loaded review skill, SKIP these sub-sections (already handled by autoplan or not applicable here):**
- Any preamble/setup sections
- AskUserQuestion formatting guides
- Step 0 base-branch detection
- Plan File Review Report scaffolding
- Outside-voice / independent-challenge sub-sections

Follow ONLY the review-specific methodology, sections, and required outputs.

Output: "Here's what I'm working with: [plan summary]. UI scope: [yes/no]. Loaded review skills from disk. Starting full review pipeline with auto-decisions."

---

## Phase 1: CEO Review (Strategy & Scope)

Follow the plan-ceo-review skill — all sections, full depth.
Override: every AskUserQuestion → auto-decide using the 6 principles.

**Override rules:**
- Mode selection: SELECTIVE EXPANSION
- Premises: accept reasonable ones (P6), challenge only clearly wrong ones
- **GATE: Present premises to user for confirmation** — this is the ONE AskUserQuestion that is NOT auto-decided in Phase 1. Premises require human judgment.
- Alternatives: pick highest completeness (P1). If tied, pick simplest (P5). If top 2 are close → mark TASTE DECISION.
- Scope expansion: in blast radius + <1d effort → approve (P2). Outside → defer to TODOS.md (P3). Duplicates → reject (P4). Borderline (3-5 files) → mark TASTE DECISION.
- All 10 review sections: run fully, auto-decide each issue, log every decision.
- Strategy choices: if the analysis concludes the user's stated structure should change (merge, split, add, remove) → USER CHALLENGE (never auto-decided).

**Optional: you may invoke an external reviewer** (e.g., a second-opinion subagent or external CLI) to challenge the plan's strategic foundations: Are premises valid or assumed? Is this the right problem to solve? What alternatives were dismissed too quickly? Tag findings under a CODEX/EXTERNAL SAYS header. If unavailable, proceed with primary review and note "external voice unavailable".

**Required execution checklist (CEO):**

Step 0 (0A-0F) — run each sub-step and produce:
- 0A: Premise challenge with specific premises named and evaluated
- 0B: Existing code leverage map (sub-problems → existing code)
- 0C: Dream state diagram (CURRENT → THIS PLAN → 12-MONTH IDEAL)
- 0D: Implementation alternatives table (2-3 approaches with effort/risk/pros/cons)
- 0E: Mode-specific analysis with scope decisions logged
- 0F: Mode selection confirmation

Sections 1-10 — for EACH section, run the evaluation criteria from the loaded skill:
- Sections WITH findings: full analysis, auto-decide each issue, log to audit trail
- Sections with NO findings: 1-2 sentences stating what was examined and why nothing was flagged. NEVER compress a section to just its name in a table row.
- Section 11 (Design): run only if UI scope was detected in Phase 0

**Mandatory outputs from Phase 1:**
- "NOT in scope" section with deferred items and rationale
- "What already exists" section mapping sub-problems to existing code
- Error & Rescue Registry table (from Section 2)
- Failure Modes Registry table (from review sections)
- Dream state delta (where this plan leaves us vs 12-month ideal)
- Completion Summary (the full summary table from the CEO skill)

**PHASE 1 COMPLETE.** Emit phase-transition summary:
> **Phase 1 complete.** [N issues identified, M auto-decided, K taste decisions, J user challenges].
> Passing to Phase 2.

Do NOT begin Phase 2 until all Phase 1 outputs are written to the plan file and the premise gate has been passed.

---

**Pre-Phase 2 checklist (verify before starting):**
- [ ] CEO completion summary written to plan file
- [ ] Premise gate passed (user confirmed)
- [ ] Phase-transition summary emitted

## Phase 2: Design Review (conditional — skip if no UI scope)

Follow the plan-design-review skill — all dimensions, full depth.
Override: every AskUserQuestion → auto-decide using the 6 principles.

**Override rules:**
- Focus areas: all relevant dimensions (P1)
- Structural issues (missing states, broken hierarchy): auto-fix (P5)
- Aesthetic/taste issues: mark TASTE DECISION
- Design system alignment: auto-fix if a design system reference exists and the fix is obvious
- Design scope changes the analysis concludes the user should accept → USER CHALLENGE

**Required execution checklist (Design):**

1. Step 0 (Design Scope): Rate completeness 0-10. Map existing patterns.
2. Passes 1-N: Run each from the loaded skill. Rate 0-10. Auto-decide each issue.

**STOP.** Do NOT begin Phase 3 until all Phase 2 outputs (if run) are written to the plan file.

---

**Pre-Phase 3 checklist (verify before starting):**
- [ ] Design completion summary written (or "skipped, no UI scope")
- [ ] Phase-transition summary emitted

## Phase 3: Engineering Review

Follow the plan-eng-review skill — all sections, full depth.
Override: every AskUserQuestion → auto-decide using the 6 principles.

**Override rules:**
- Scope challenge: never reduce (P2)
- Architecture choices: explicit over clever (P5). Disagreements with valid reasoning → TASTE DECISION. Scope changes the analysis concludes the user should accept → USER CHALLENGE.
- Evals: always include all relevant suites (P1)
- TODOS.md: collect all deferred scope expansions from Phase 1, auto-write

**Required execution checklist (Eng):**

1. Step 0 (Scope Challenge): Read actual code referenced by the plan. Map each sub-problem to existing code. Run the complexity check. Produce concrete findings.

2. Section 1 (Architecture): Produce ASCII dependency graph showing new components and their relationships to existing ones. Evaluate coupling, scaling, security.

3. Section 2 (Code Quality): Identify DRY violations, naming issues, complexity. Reference specific files and patterns. Auto-decide each finding.

4. **Section 3 (Test Review) — NEVER SKIP OR COMPRESS.**
   This section requires reading actual code, not summarizing from memory.
   - Read the diff or the plan's affected files
   - Build the test diagram: list every NEW UX flow, data flow, codepath, and branch
   - For EACH item in the diagram: what type of test covers it? Does one exist? Gaps?
   - For LLM/prompt changes: which eval suites must run?
   - Auto-deciding test gaps means: identify the gap → decide whether to add a test or defer (with rationale and principle) → log the decision. It does NOT mean skipping the analysis.

5. Section 4 (Performance): Evaluate N+1 queries, memory, caching, slow paths.

**Mandatory outputs from Phase 3:**
- "NOT in scope" section
- "What already exists" section
- Architecture ASCII diagram (Section 1)
- Test diagram mapping codepaths to coverage (Section 3)
- Failure modes registry with critical gap flags
- Completion Summary (the full summary from the Eng skill)
- TODOS.md updates (collected from all phases)

**PHASE 3 COMPLETE.** Emit phase-transition summary:
> **Phase 3 complete.** [N issues identified, M auto-decided, K taste decisions, J user challenges].
> Passing to Phase 4 (Final Gate).

---

## Decision Audit Trail

After each auto-decision, append a row to the plan file using Edit:

```markdown
<!-- AUTONOMOUS DECISION LOG -->
## Decision Audit Trail

| # | Phase | Decision | Classification | Principle | Rationale | Rejected |
|---|-------|----------|----------------|-----------|-----------|----------|
```

Write one row per decision incrementally (via Edit). This keeps the audit on disk, not accumulated in conversation context.

---

## Pre-Gate Verification

Before presenting the Final Approval Gate, verify that required outputs were actually produced. Check the plan file and conversation for each item.

**Phase 1 (CEO) outputs:**
- [ ] Premise challenge with specific premises named (not just "premises accepted")
- [ ] All applicable review sections have findings OR explicit "examined X, nothing flagged"
- [ ] Error & Rescue Registry table produced (or noted N/A with reason)
- [ ] Failure Modes Registry table produced (or noted N/A with reason)
- [ ] "NOT in scope" section written
- [ ] "What already exists" section written
- [ ] Dream state delta written
- [ ] Completion Summary produced

**Phase 2 (Design) outputs — only if UI scope detected:**
- [ ] All dimensions evaluated with scores
- [ ] Issues identified and auto-decided

**Phase 3 (Eng) outputs:**
- [ ] Scope challenge with actual code analysis (not just "scope is fine")
- [ ] Architecture ASCII diagram produced
- [ ] Test diagram mapping codepaths to test coverage
- [ ] "NOT in scope" section written
- [ ] "What already exists" section written
- [ ] Failure modes registry with critical gap assessment
- [ ] Completion Summary produced

**Audit trail:**
- [ ] Decision Audit Trail has at least one row per auto-decision (not empty)

If ANY checkbox above is missing, go back and produce the missing output. Max 2 attempts — if still missing after retrying twice, proceed to the gate with a warning noting which items are incomplete. Do not loop indefinitely.

---

## Phase 4: Final Approval Gate

**STOP here and present the final state to the user.**

Present as a message, then use AskUserQuestion:

```
## Autoplan Review Complete

### Plan Summary
[1-3 sentence summary]

### Decisions Made: [N] total ([M] auto-decided, [K] taste choices, [J] user challenges)

### User Challenges (analysis disagrees with your stated direction)
[For each user challenge:]
**Challenge [N]: [title]** (from [phase])
You said: [user's original direction]
Analysis recommends: [the change]
Why: [reasoning]
What we might be missing: [blind spots]
If we're wrong, the cost is: [downside of changing]
[If security/feasibility: "WARNING: this is a security/feasibility risk, not just a preference."]

Your call — your original direction stands unless you explicitly change it.

### Your Choices (taste decisions)
[For each taste decision:]
**Choice [N]: [title]** (from [phase])
I recommend [X] — [principle]. But [Y] is also viable:
  [1-sentence downstream impact if you pick Y]

### Auto-Decided: [M] decisions [see Decision Audit Trail in plan file]

### Review Scores
- CEO: [summary]
- Design: [summary or "skipped, no UI scope"]
- Eng: [summary]

### Cross-Phase Themes
[For any concern that appeared in 2+ phases independently:]
**Theme: [topic]** — flagged in [Phase 1, Phase 3]. High-confidence signal.
[If no themes span phases:] "No cross-phase themes — each phase's concerns were distinct."

### Deferred to TODOS.md
[Items auto-deferred with reasons]
```

**Cognitive load management:**
- 0 user challenges: skip "User Challenges" section
- 0 taste decisions: skip "Your Choices" section
- 1-7 taste decisions: flat list
- 8+: group by phase. Add warning: "This plan had unusually high ambiguity ([N] taste decisions). Review carefully."

AskUserQuestion options:
- A) Approve as-is (accept all recommendations)
- B) Approve with overrides (specify which taste decisions to change)
- B2) Approve with user challenge responses (accept or reject each challenge)
- C) Interrogate (ask about any specific decision)
- D) Revise (the plan itself needs changes)
- E) Reject (start over)

**Option handling:**
- A: mark APPROVED, suggest next step (ship the plan)
- B: ask which overrides, apply, re-present gate
- C: answer freeform, re-present gate
- D: make changes, re-run affected phases (scope → Phase 1, design → Phase 2, arch/tests → Phase 3). Max 3 cycles.
- E: start over

---

## Important Rules

- **Never abort.** The user chose autoplan. Respect that choice. Surface all taste decisions, never redirect to interactive review.
- **Two gates.** The non-auto-decided AskUserQuestions are: (1) premise confirmation in Phase 1, and (2) User Challenges — when the analysis concludes the user's stated direction should change. Everything else is auto-decided using the 6 principles.
- **Log every decision.** No silent auto-decisions. Every choice gets a row in the audit trail.
- **Full depth means full depth.** Do not compress or skip sections from the loaded review skills (except the skip list in Phase 0). "Full depth" means: read the code the section asks you to read, produce the outputs the section requires, identify every issue, and decide each one. A one-sentence summary of a section is not "full depth" — it is a skip. If you catch yourself writing fewer than 3 sentences for any review section, you are likely compressing.
- **Artifacts are deliverables.** Test diagram, failure modes registry, error/rescue table, ASCII diagrams — these must exist on disk or in the plan file when the review completes. If they don't exist, the review is incomplete.
- **Sequential order.** CEO → Design → Eng. Each phase builds on the last.
