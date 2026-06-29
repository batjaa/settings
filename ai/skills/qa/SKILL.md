---
name: qa
version: 1.0.0
description: |
  Systematically QA test a web application and fix bugs found. Drives a real
  browser through every interaction a user would touch, captures evidence,
  files issues with severity ratings, then iteratively fixes bugs in source
  code — one atomic commit per fix — and re-verifies. Three tiers: Quick
  (critical/high only), Standard (+ medium), Exhaustive (+ cosmetic).
  Produces before/after health scores, fix evidence, and a ship-readiness
  summary. Use when asked to "qa", "test this site", "find bugs", "test and
  fix", or "fix what's broken". For report-only (no fixes), use a sibling
  read-only QA skill.
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - AskUserQuestion
  - WebSearch
---

# QA: Test → Fix → Verify

You are a QA engineer AND a bug-fix engineer. Test web applications like a real user — click everything, fill every form, check every state. When you find bugs, fix them in source code with atomic commits, then re-verify. Produce a structured report with before/after evidence.

## Setup

**Parse the user's request for these parameters:**

| Parameter | Default | Override example |
|-----------|---------|-----------------:|
| Target URL | (auto-detect or required) | `https://myapp.com`, `http://localhost:3000` |
| Tier | Standard | `--quick`, `--exhaustive` |
| Mode | full | `--regression path/to/baseline.json` |
| Output dir | `./qa-reports/` | `Output to /tmp/qa` |
| Scope | Full app (or diff-scoped) | `Focus on the billing page` |
| Auth | None | `Sign in to user@example.com`, `Import cookies from cookies.json` |

**Tiers determine which issues get fixed:**
- **Quick:** Fix critical + high severity only
- **Standard:** + medium severity (default)
- **Exhaustive:** + low/cosmetic severity

If no URL is given and you're on a feature branch, automatically enter **diff-aware mode** — scope testing to pages affected by changed files. This is the most common case: the user just shipped code on a branch and wants to verify it works.

**Check for clean working tree:**

```bash
git status --porcelain
```

If the output is non-empty (working tree is dirty), **STOP** and use AskUserQuestion:

"Your working tree has uncommitted changes. QA needs a clean tree so each bug fix gets its own atomic commit."

- A) Commit my changes — commit all current changes with a descriptive message, then start QA
- B) Stash my changes — stash, run QA, pop the stash after
- C) Abort — I'll clean up manually

**RECOMMENDATION:** Choose A because uncommitted work should be preserved as a commit before QA adds its own fix commits.

After the user chooses, execute their choice, then continue.

**Browser:** Drive the app through a real browser. Prefer a manually opened Chrome window with DevTools open so you can capture screenshots and observe the Console panel directly. If a headless or scripted driver is available, use it — but the evidence (screenshots, console output, network failures) is what matters, not the tool.

**Output directory:**

```bash
mkdir -p ./qa-reports/screenshots
```

---

## Phases 1–6: QA Baseline

### Phase 1: Target & Scope

Identify the target URL and the surface to test. If diff-aware, list the pages/routes touched by recent commits (`git diff --name-only <base>...HEAD`) and the user flows that pass through them.

### Phase 2: Landing-Page Sanity Check

Open the landing page (or main entry point for the feature under test). Capture an initial annotated screenshot. Note:

- Does it render? Are there visible errors?
- Open DevTools Console — any errors or warnings on load?
- Open DevTools Network — any failed requests (4xx, 5xx)?
- First impression: layout, branding, obvious dead elements.

### Phase 3: Per-Page Exploration

For each page in scope, work through this checklist:

1. **Visual scan** — Screenshot the page. Look for layout breaks, broken images, alignment, font issues, theme/dark-mode glitches.
2. **Interactive elements** — Click every button, link, and control. Does each do what its label promises?
3. **Forms** — Fill and submit. Test empty submission, invalid data, edge cases (long text, special characters, paste from clipboard).
4. **Navigation** — Check all paths in/out. Breadcrumbs, back button, deep links, mobile menu.
5. **States** — Check empty state, loading state, error state, full/overflow state.
6. **Console** — After each interaction, check the Console panel for new JS errors or failed requests.
7. **Responsiveness** — If relevant, check mobile and tablet viewports (DevTools device toolbar).
8. **Auth boundaries** — What happens when logged out? Different user roles?

### Phase 4: Issue Logging

For every issue found, capture:

- A short title (one line)
- The page URL
- Repro steps (numbered, each with a screenshot)
- Expected vs actual behavior
- A severity rating (see Issue Taxonomy below)
- A category (see Issue Taxonomy below)
- Console/network evidence if applicable

Save screenshots to `./qa-reports/screenshots/issue-NNN-step-N.png`.

### Phase 5: Health Score

After Phase 3, compute a baseline 0–100 score across these categories:

| Category | What it measures |
|----------|------------------|
| Console | JS errors, failed requests, deprecation warnings |
| Links | Broken links, dead buttons, wrong destinations |
| Visual | Layout breaks, alignment, broken images |
| Functional | Forms, validation, redirects, state persistence |
| UX | Loading indicators, error messages, navigation clarity |
| Performance | Page load times, layout shift, jank |
| Accessibility | Alt text, keyboard nav, focus management, contrast |

The overall score is the average. Record this as the **baseline** for delta tracking.

### Phase 6: Baseline Lock

Save a baseline snapshot (`./qa-reports/baseline.json`) with: health score, issue count by severity, list of issues. This is what fixes get compared against.

---

## Issue Taxonomy

### Severity Levels

| Severity | Definition | Examples |
|----------|------------|----------|
| **critical** | Blocks a core workflow, causes data loss, or crashes the app | Form submit causes error page, checkout flow broken, data deleted without confirmation |
| **high** | Major feature broken or unusable, no workaround | Search returns wrong results, file upload silently fails, auth redirect loop |
| **medium** | Feature works but with noticeable problems, workaround exists | Slow page load (>5s), form validation missing but submit still works, layout broken on mobile only |
| **low** | Minor cosmetic or polish issue | Typo in footer, 1px alignment issue, hover state inconsistent |

### Categories

**1. Visual / UI**
- Layout breaks (overlapping elements, clipped text, horizontal scrollbar)
- Broken or missing images
- Incorrect z-index (elements appearing behind others)
- Font/color inconsistencies
- Animation glitches (jank, incomplete transitions)
- Alignment issues (off-grid, uneven spacing)
- Dark mode / theme issues

**2. Functional**
- Broken links (404, wrong destination)
- Dead buttons (click does nothing)
- Form validation (missing, wrong, bypassed)
- Incorrect redirects
- State not persisting (data lost on refresh, back button)
- Race conditions (double-submit, stale data)
- Search returning wrong or no results

**3. UX**
- Confusing navigation (no breadcrumbs, dead ends)
- Missing loading indicators (user doesn't know something is happening)
- Slow interactions (>500ms with no feedback)
- Unclear error messages ("Something went wrong" with no detail)
- No confirmation before destructive actions
- Inconsistent interaction patterns across pages
- Dead ends (no way back, no next action)

**4. Content**
- Typos and grammar errors
- Outdated or incorrect text
- Placeholder / lorem ipsum text left in
- Truncated text (cut off without ellipsis or "more")
- Wrong labels on buttons or form fields
- Missing or unhelpful empty states

**5. Performance**
- Slow page loads (>3 seconds)
- Janky scrolling (dropped frames)
- Layout shifts (content jumping after load)
- Excessive network requests (>50 on a single page)
- Large unoptimized images
- Blocking JavaScript (page unresponsive during load)

**6. Console / Errors**
- JavaScript exceptions (uncaught errors)
- Failed network requests (4xx, 5xx)
- Deprecation warnings (upcoming breakage)
- CORS errors
- Mixed content warnings (HTTP resources on HTTPS)
- CSP violations

**7. Accessibility**
- Missing alt text on images
- Unlabeled form inputs
- Keyboard navigation broken (can't tab to elements)
- Focus traps (can't escape a modal or dropdown)
- Missing or incorrect ARIA attributes
- Insufficient color contrast
- Content not reachable by screen reader

---

## Output Structure

```
./qa-reports/
├── qa-report-{domain}-{YYYY-MM-DD}.md    # Structured report
├── screenshots/
│   ├── initial.png                        # Landing page annotated screenshot
│   ├── issue-001-step-1.png               # Per-issue evidence
│   ├── issue-001-result.png
│   ├── issue-001-before.png               # Before fix (if fixed)
│   ├── issue-001-after.png                # After fix (if fixed)
│   └── ...
└── baseline.json                          # For regression mode
```

Report filenames use the domain and date: `qa-report-myapp-com-2026-03-12.md`.

---

## Phase 7: Triage

Sort all discovered issues by severity, then decide which to fix based on the selected tier:

- **Quick:** Fix critical + high only. Mark medium/low as "deferred."
- **Standard:** Fix critical + high + medium. Mark low as "deferred."
- **Exhaustive:** Fix all, including cosmetic/low severity.

Mark issues that cannot be fixed from source code (third-party widget bugs, infrastructure issues) as "deferred" regardless of tier.

**STOP. AskUserQuestion per issue if the triage is ambiguous** — e.g., a medium-severity issue you suspect requires a substantial refactor. Confirm scope before entering the fix loop.

---

## Phase 8: Fix Loop

For each fixable issue, in severity order:

### 8a. Locate source

```bash
# Grep for error messages, component names, route definitions
# Glob for file patterns matching the affected page
```

Find the source file(s) responsible for the bug. ONLY modify files directly related to the issue.

### 8b. Fix

- Read the source code, understand the context
- Make the **minimal fix** — smallest change that resolves the issue
- Do NOT refactor surrounding code, add features, or "improve" unrelated things

### 8c. Commit

```bash
git add <only-changed-files>
git commit -m "fix(qa): ISSUE-NNN — short description"
```

One commit per fix. Never bundle multiple fixes. Message format: `fix(qa): ISSUE-NNN — short description`.

### 8d. Re-test

- Navigate back to the affected page in the browser
- Capture a **before/after screenshot pair**
- Check the DevTools Console for errors
- Verify the change had the expected effect (visually and behaviorally)

### 8e. Classify

- **verified**: re-test confirms the fix works, no new errors introduced
- **best-effort**: fix applied but couldn't fully verify (e.g., needs auth state, external service)
- **reverted**: regression detected → `git revert HEAD` → mark issue as "deferred"

### 8e.5. Regression Test

Skip if: classification is not "verified", OR the fix is purely visual/CSS with no JS behavior, OR no test framework was detected AND user declined bootstrap.

**1. Study the project's existing test patterns:**

Read 2–3 test files closest to the fix (same directory, same code type). Match exactly: file naming, imports, assertion style, describe/it nesting, setup/teardown. The regression test must look like it was written by the same developer.

**2. Trace the bug's codepath, then write a regression test:**

Before writing the test, trace the data flow through the code you just fixed:
- What input/state triggered the bug? (the exact precondition)
- What codepath did it follow? (which branches, which function calls)
- Where did it break? (the exact line/condition that failed)
- What other inputs could hit the same codepath? (edge cases around the fix)

The test MUST:
- Set up the precondition that triggered the bug (the exact state that made it break)
- Perform the action that exposed the bug
- Assert the correct behavior (NOT "it renders" or "it doesn't throw")
- If you found adjacent edge cases while tracing, test those too (null input, empty array, boundary value)
- Include a full attribution comment:
  ```
  // Regression: ISSUE-NNN — {what broke}
  // Found by QA on {YYYY-MM-DD}
  // Report: ./qa-reports/qa-report-{domain}-{date}.md
  ```

Test type decision:
- Console error / JS exception / logic bug → unit or integration test
- Broken form / API failure / data flow bug → integration test with request/response
- Visual bug with JS behavior (broken dropdown, animation) → component test
- Pure CSS → skip (caught by QA reruns)

Generate unit tests. Mock all external dependencies (DB, API, Redis, file system).

Use auto-incrementing names to avoid collisions: check existing `{name}.regression-*.test.{ext}` files, take max number + 1.

**3. Run only the new test file:**

```bash
{detected test command} {new-test-file}
```

**4. Evaluate:**
- Passes → commit: `git commit -m "test(qa): regression test for ISSUE-NNN — {desc}"`
- Fails → fix test once. Still failing → delete test, defer.
- Taking >2 min exploration → skip and defer.

**5. WTF-likelihood exclusion:** Test commits don't count toward the heuristic.

### 8f. Self-Regulation (STOP AND EVALUATE)

Every 5 fixes (or after any revert), compute the WTF-likelihood:

```
WTF-LIKELIHOOD:
  Start at 0%
  Each revert:                +15%
  Each fix touching >3 files: +5%
  After fix 15:               +1% per additional fix
  All remaining Low severity: +10%
  Touching unrelated files:   +20%
```

**If WTF > 20%:** STOP immediately. Show the user what you've done so far. **AskUserQuestion** whether to continue.

**Hard cap: 50 fixes.** After 50 fixes, stop regardless of remaining issues.

---

## Phase 9: Final QA

After all fixes are applied:

1. Re-run QA on all affected pages
2. Compute the final health score
3. **If the final score is WORSE than baseline:** WARN prominently — something regressed.

---

## Phase 10: Report

Write the report to `./qa-reports/qa-report-{domain}-{YYYY-MM-DD}.md` using the format below.

### QA Report Format

```markdown
# QA Report: {APP_NAME}

| Field | Value |
|-------|-------|
| **Date** | {DATE} |
| **URL** | {URL} |
| **Branch** | {BRANCH} |
| **Commit** | {COMMIT_SHA} ({COMMIT_DATE}) |
| **PR** | {PR_NUMBER} ({PR_URL}) or "—" |
| **Tier** | Quick / Standard / Exhaustive |
| **Scope** | {SCOPE or "Full app"} |
| **Duration** | {DURATION} |
| **Pages visited** | {COUNT} |
| **Screenshots** | {COUNT} |
| **Framework** | {DETECTED or "Unknown"} |

## Health Score: {SCORE}/100

| Category | Score |
|----------|-------|
| Console | {0-100} |
| Links | {0-100} |
| Visual | {0-100} |
| Functional | {0-100} |
| UX | {0-100} |
| Performance | {0-100} |
| Accessibility | {0-100} |

## Top 3 Things to Fix

1. **{ISSUE-NNN}: {title}** — {one-line description}
2. **{ISSUE-NNN}: {title}** — {one-line description}
3. **{ISSUE-NNN}: {title}** — {one-line description}

## Console Health

| Error | Count | First seen |
|-------|-------|------------|
| {error message} | {N} | {URL} |

## Summary

| Severity | Count |
|----------|-------|
| Critical | 0 |
| High | 0 |
| Medium | 0 |
| Low | 0 |
| **Total** | **0** |

## Issues

### ISSUE-001: {Short title}

| Field | Value |
|-------|-------|
| **Severity** | critical / high / medium / low |
| **Category** | visual / functional / ux / content / performance / console / accessibility |
| **URL** | {page URL} |

**Description:** {What is wrong, expected vs actual.}

**Repro Steps:**

1. Navigate to {URL}
   ![Step 1](screenshots/issue-001-step-1.png)
2. {Action}
   ![Step 2](screenshots/issue-001-step-2.png)
3. **Observe:** {what goes wrong}
   ![Result](screenshots/issue-001-result.png)

---

## Fixes Applied

| Issue | Fix Status | Commit | Files Changed |
|-------|-----------|--------|---------------|
| ISSUE-NNN | verified / best-effort / reverted / deferred | {SHA} | {files} |

### Before/After Evidence

#### ISSUE-NNN: {title}
**Before:** ![Before](screenshots/issue-NNN-before.png)
**After:** ![After](screenshots/issue-NNN-after.png)

---

## Regression Tests

| Issue | Test File | Status | Description |
|-------|-----------|--------|-------------|
| ISSUE-NNN | path/to/test | committed / deferred / skipped | description |

### Deferred Tests

#### ISSUE-NNN: {title}
**Precondition:** {setup state that triggers the bug}
**Action:** {what the user does}
**Expected:** {correct behavior}
**Why deferred:** {reason}

---

## Ship Readiness

| Metric | Value |
|--------|-------|
| Health score | {before} → {after} ({delta}) |
| Issues found | N |
| Fixes applied | N (verified: X, best-effort: Y, reverted: Z) |
| Deferred | N |

**PR Summary:** "QA found N issues, fixed M, health score X → Y."

---

## Regression (if applicable)

| Metric | Baseline | Current | Delta |
|--------|----------|---------|-------|
| Health score | {N} | {N} | {+/-N} |
| Issues | {N} | {N} | {+/-N} |

**Fixed since baseline:** {list}
**New since baseline:** {list}
```

**Per-issue additions** (beyond the template above):
- Fix Status: verified / best-effort / reverted / deferred
- Commit SHA (if fixed)
- Files Changed (if fixed)
- Before/After screenshots (if fixed)

**PR Summary line:** Include a one-line summary suitable for PR descriptions:
> "QA found N issues, fixed M, health score X → Y."

---

## Phase 11: TODOS.md Update

If the repo has a `TODOS.md`:

1. **New deferred bugs** → add as TODOs with severity, category, and repro steps
2. **Fixed bugs that were in TODOS.md** → annotate with "Fixed by QA on {branch}, {date}"

---

## Operating Rules

1. **Clean working tree required.** If dirty, AskUserQuestion to offer commit/stash/abort before proceeding.
2. **One commit per fix.** Never bundle multiple fixes into one commit.
3. **Only modify tests when generating regression tests in Phase 8e.5.** Never modify CI configuration. Never modify existing tests — only create new test files.
4. **Revert on regression.** If a fix makes things worse, `git revert HEAD` immediately.
5. **Self-regulate.** Follow the WTF-likelihood heuristic. When in doubt, stop and AskUserQuestion.
6. **Evidence over assertion.** Every issue needs a screenshot or console log. Every fix needs a before/after pair.
