---
name: pr-review
description: >
  Review pull requests using the PERFECT framework. Use this skill whenever the user
  asks to review a PR, diff, or code changes — or pastes code and asks for feedback,
  a review, or "what do you think about this". Also trigger when the user says things
  like "can you review this?", "check my PR", "look at these changes", "LGTM?", or
  shares a GitHub/GitLab link. Applies to any language but has extra heuristics for
  Go, TypeScript, and distributed systems patterns (SQS, gRPC, AWS).
---

# PR Review Skill (PERFECT Framework)

Perform structured, prioritized code reviews using the **PERFECT** principles.
Work top-down through the pyramid. Stop and flag blockers immediately — don't
soft-pedal issues.

---

## Input Formats

Accept any of:
- Raw diff/patch text
- Pasted code with context
- GitHub/GitLab PR URL (use `web_fetch` to retrieve the diff)
- File upload

If a URL is given, fetch the diff view (append `.diff` to GitHub PR URLs).

---

## Review Process

### Step 0 — Understand the PR

Before applying PERFECT, extract:
- **What task does this solve?** (from PR title, description, linked ticket)
- **Scope**: files changed, lines added/removed
- **Language(s)** and runtime context

If the description is missing or vague, note it as a **process issue** in the summary.

---

### Step 1 — P: Purpose

> Does the code actually solve the stated task?

- Trace the happy path end-to-end.
- Compare implementation to the stated goal.
- Flag if the PR description doesn't match what the code does.
- Flag if the PR solves the wrong problem.

**Severity if violated**: 🔴 Blocker

---

### Step 2 — E: Edge Cases

> Are inputs, boundaries, and unexpected states handled?

Check for:
- Nil/null/undefined dereferences
- Off-by-one errors
- Empty collections, zero values, negative numbers
- Type coercion / overflow (especially in Go: int vs int64)
- Missing enum/switch cases
- Unhandled error returns (Go: unchecked `err`)
- Race conditions if concurrent code is present
- Missing fallback for optional/maybe types used without guards

**Go-specific**: All returned `error` values must be handled. `interface{}` casts must be guarded.

**TS-specific**: No `as any` without justification. Optional chaining (`?.`) used where needed.

**Severity if violated**: 🔴 Blocker or 🟠 Major (depending on reachability)

---

### Step 3 — R: Reliability

> Does the code introduce performance or security regressions?

Performance:
- N+1 queries or loops doing sequential I/O that could be batched
- Missing pagination on potentially large datasets
- Unbounded goroutine spawning (Go: missing `sync.WaitGroup`, no context cancellation)
- Missing indexes on DB queries introduced by this PR
- Memory leaks (Go: unclosed `http.Response.Body`, leaked goroutines)

Security:
- Secrets or credentials in code or logs
- Unvalidated user input reaching SQL/shell/filesystem
- Auth checks missing on new endpoints
- Overly permissive IAM policies (AWS context)
- SQS/SNS message payloads logged in plaintext

Distributed systems (SQS, gRPC, Kinesis):
- Missing idempotency handling for SQS consumers
- No dead-letter queue consideration
- gRPC streaming without cancellation context
- Kinesis shard iterator not renewed

**Severity if violated**: 🔴 Blocker (security) / 🟠 Major (perf)

---

### Step 4 — F: Form

> Does the code align with design principles?

Focus on **High Cohesion / Low Coupling**:
- Are new responsibilities placed in the right layer/package?
- Does this function/method do one thing?
- Are dependencies injected, not hardcoded?
- Does this PR violate existing patterns in the codebase?

Flag SOLID violations only when they create tangible maintenance cost — not as style preferences.

**Severity if violated**: 🟠 Major or 🟡 Minor

---

### Step 5 — E: Evidence

> Do tests exist and pass?

- Are new code paths covered by tests?
- Are tests testing behavior (not implementation details)?
- Do CI checks pass? (flag if unknown)
- Are mocks/stubs overused to the point of not testing real behavior?
- Are test names descriptive (`TestHandleEvent_WhenQueueEmpty_ReturnsNoOp`)?

If no tests are added for non-trivial logic: flag as 🟠 Major.

---

### Step 6 — C: Clarity

> Is intent obvious without reading every line?

- Are function/variable names self-documenting?
- Are non-obvious decisions explained with comments?
- Is there dead code or commented-out blocks?
- Would a new team member understand what this does in 2 minutes?

**Severity if violated**: 🟡 Minor (unless truly obfuscated)

---

### Step 7 — T: Taste

> Personal preferences — never block a PR on these.

- Style deviations not covered by a linter
- Minor naming preferences
- Alternative approaches that are equally valid

Always prefix these with `[nit]` or `[suggestion]`. These are non-blocking.

---

## Output Format

```
## PR Review: {{PR_TITLE_OR_FILENAME}}

**Summary**: {{1-2 sentence overall assessment}}
**Verdict**: ✅ Approve | 🟡 Approve with suggestions | 🔴 Request changes

---

### 🔴 Blockers
1. [P/E/R/F/E/C/T] {{file:line}} — {{issue description}}
   > {{suggested fix or direction}}

### 🟠 Major
1. [P/E/R/F/E/C/T] {{file:line}} — {{issue description}}
   > {{suggested fix or direction}}

### 🟡 Minor
1. [C/T] {{file:line}} — {{issue description}}

### [nit] Taste
1. {{file:line}} — {{preference note}}

---

### ✅ Positives
- {{What was done well — always include at least 1}}
```

---

## Severity Definitions

| Level | Label | Meaning |
|---|---|---|
| 🔴 | Blocker | Must be fixed before merge |
| 🟠 | Major | Should be fixed; discuss if not |
| 🟡 | Minor | Nice to fix; author's call |
| nit | Taste | Personal preference only |

---

## Rules

1. Every comment must include: **location** (file:line if possible), **what's wrong**, **why it matters**, and **a proposed fix**.
2. Never use vague feedback like "this is bad" or "refactor this".
3. Always include at least 1 positive observation.
4. Tag each finding with its PERFECT letter: `[P]`, `[E]`, `[R]`, `[F]`, `[E2]`, `[C]`, `[T]`.
5. If the PR description is missing, note it — good process is part of a good review.
6. Do not bikeshed on formatting if a linter is configured (eslint, gofmt, golangci-lint).
