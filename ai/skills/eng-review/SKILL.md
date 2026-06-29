---
name: eng-review
version: 1.0.0
description: |
  Pre-landing PR review. Analyzes the diff against the base branch for structural
  issues tests don't catch: SQL safety, race conditions, LLM trust boundary
  violations, enum completeness, shell injection. Runs a "review army" of
  specialist perspectives (security, performance, testing, maintainability,
  data migration, API contract, red team) inline. Use when asked to "review
  this PR", "code review", "pre-landing review", or "check my diff".
allowed-tools:
  - Bash
  - Read
  - Edit
  - Write
  - Grep
  - Glob
  - AskUserQuestion
  - WebSearch
---

# Pre-Landing PR Review

You are running a pre-landing PR review. Analyze the current branch's diff against the base branch for structural issues tests don't catch, then apply or surface fixes.

**Do not commit, push, or create PRs — that is a separate workflow.** Your job is to find problems, auto-fix the mechanical ones, and ask the user about the judgment calls.

---

## Step 0: Detect platform and base branch

Before anything else, figure out where the PR / diff lives and what to diff against.

```bash
# Try GitHub first
gh pr view --json baseRefName -q .baseRefName 2>/dev/null

# Fall back to git's default branch detection
git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@'

# Last resort
git rev-parse --abbrev-ref HEAD@{upstream} 2>/dev/null | sed 's@^origin/@@'
```

Use the first non-empty result. Call this `<base>`. Common values are `main`, `master`, `develop`. Do not hardcode.

---

## Step 1: Check branch

1. Run `git branch --show-current` to get the current branch.
2. If on the base branch, output **"Nothing to review — you're on the base branch or have no changes against it."** and stop.
3. Run `git fetch origin <base> --quiet && DIFF_BASE=$(git merge-base origin/<base> HEAD) && git diff "$DIFF_BASE" --stat`. If no diff, output the same message and stop.

---

## Step 1.5: Scope drift detection

Before reviewing code quality, check: **did the branch build what was requested — nothing more, nothing less?**

1. Read `TODOS.md` if it exists. Read the PR description: `gh pr view --json body --jq .body 2>/dev/null || true`. Read commit messages: `git log origin/<base>..HEAD --oneline`.
   - If no PR exists, rely on commit messages and `TODOS.md` for stated intent. This is the common case when review runs before the PR is created.
2. Identify the **stated intent** — what was this branch supposed to accomplish?
3. Compare files changed against the stated intent:
   ```bash
   DIFF_BASE=$(git merge-base origin/<base> HEAD) && git diff "$DIFF_BASE" --stat
   ```
4. Evaluate with skepticism:

   **SCOPE CREEP detection:**
   - Files changed that are unrelated to the stated intent
   - New features or refactors not mentioned in the plan
   - "While I was in there..." changes that expand blast radius

   **MISSING REQUIREMENTS detection:**
   - Requirements from `TODOS.md` / PR description not addressed in the diff
   - Test coverage gaps for stated requirements
   - Partial implementations (started but not finished)

5. Output (before the main review begins):

   ```
   Scope Check: [CLEAN / DRIFT DETECTED / REQUIREMENTS MISSING]
   Intent: <1-line summary of what was requested>
   Delivered: <1-line summary of what the diff actually does>
   [If drift: list each out-of-scope change]
   [If missing: list each unaddressed requirement]
   ```

6. This is **INFORMATIONAL** — does not block the review. Proceed.

---

## Step 1.6: Plan file discovery and completion audit (optional)

If a plan / spec markdown file exists for this branch, audit completion against it.

### Plan file discovery

1. **Conversation context (primary):** if a plan file path is referenced in the active conversation, use it directly.
2. **Content-based search (fallback):**
   ```bash
   BRANCH=$(git branch --show-current 2>/dev/null | tr '/' '-')
   REPO=$(basename "$(git rev-parse --show-toplevel 2>/dev/null)")
   for PLAN_DIR in "$HOME/.claude/plans" "docs/designs" ".plans" "plans"; do
     [ -d "$PLAN_DIR" ] || continue
     PLAN=$(ls -t "$PLAN_DIR"/*.md 2>/dev/null | xargs grep -l "$BRANCH" 2>/dev/null | head -1)
     [ -z "$PLAN" ] && PLAN=$(ls -t "$PLAN_DIR"/*.md 2>/dev/null | xargs grep -l "$REPO" 2>/dev/null | head -1)
     [ -n "$PLAN" ] && break
   done
   echo "${PLAN:-NO_PLAN_FILE}"
   ```
3. **Validation:** if found via search, read the first 20 lines and verify it is relevant to this branch. If not, treat as no plan file.

**No plan file → skip the rest of this step silently.** Continue to Step 2.

### Actionable item extraction

Read the plan file. Extract every actionable item — anything that describes work to be done:

- Checkbox items: `- [ ] ...` or `- [x] ...`
- Numbered steps under implementation headings: "1. Create ...", "2. Add ..."
- Imperative statements: "Add X to Y", "Create a Z service"
- File-level specs: "New file: path/to/file.ts"
- Test requirements: "Test that X", "Add test for Y"
- Data model changes: "Add column X to table Y"

**Ignore:** Context/Background, open questions ("TBD"), review report sections, explicitly deferred items ("Future:", "Out of scope:", "P2/P3/P4:"), decision records.

**Cap:** at most 50 items. Note if truncated.

For each item, note its category: CODE | TEST | MIGRATION | CONFIG | DOCS.

### Verification mode

Classify HOW each item can be verified:

- **DIFF-VERIFIABLE** — would manifest in `git diff <base>...HEAD`.
- **CROSS-REPO** — names a file or change in a sibling repo.
- **EXTERNAL-STATE** — names state in an external system (DNS, Cloudflare, Supabase, OAuth provider, third-party SaaS).
- **CONTENT-SHAPE** — requires a file to follow a specific convention.

Dispatch:

- **DIFF-VERIFIABLE** → cross-reference against the diff.
- **CROSS-REPO** → if the sibling repo is on disk, `[ -f <path> ]`; file exists → DONE (cite path), missing → NOT DONE, unreachable → UNVERIFIABLE.
- **EXTERNAL-STATE** → UNVERIFIABLE. Cite the specific manual check required.
- **CONTENT-SHAPE** → if a validator exists (`validate-*`, `lint-*`, `check-docs` in `package.json` scripts), run it before falling back to UNVERIFIABLE.

**Path concreteness rule.** If a plan item names a concrete filesystem path, classify DONE or NOT DONE based on `[ -f <path> ]`. UNVERIFIABLE is only valid when the path is genuinely abstract.

**Honesty rule.** Code that *handles* a deliverable is not the deliverable itself. Shipping a markdown-extraction library is not the same as shipping the markdown file. When in doubt, prefer UNVERIFIABLE.

### Cross-reference against diff

For each item, classify:

- **DONE** — clear evidence the item shipped. Cite specific files in the diff or verified paths.
- **PARTIAL** — some work exists but is incomplete.
- **NOT DONE** — verification ran and produced negative evidence.
- **CHANGED** — implemented differently than the plan described, but the same goal is achieved.
- **UNVERIFIABLE** — diff and any reachable sibling-repo checks cannot prove or disprove. Cite the manual check the user must perform.

Be conservative with DONE. Be generous with CHANGED. Be honest with UNVERIFIABLE.

### Investigation depth

For each PARTIAL or NOT DONE item, investigate WHY:

1. Check `git log` for commits that suggest the work was started, attempted, or reverted.
2. Read the relevant code to understand what was built instead.
3. Determine the likely reason:
   - **Scope cut** — evidence of intentional removal
   - **Context exhaustion** — work started but stopped mid-way
   - **Misunderstood requirement** — something was built but it doesn't match the plan
   - **Blocked by dependency** — the item depends on something not yet available
   - **Genuinely forgotten** — no evidence of any attempt

Output for each discrepancy:

```
DISCREPANCY: {PARTIAL|NOT_DONE} | {plan item} | {what was actually delivered}
INVESTIGATION: {likely reason with evidence}
IMPACT: {HIGH|MEDIUM|LOW} — {what breaks or degrades if this stays undelivered}
```

### Output format

```
PLAN COMPLETION AUDIT
═══════════════════════════════
Plan: {plan file path}

## Implementation Items
  [DONE]         Create UserService — src/services/user_service.rb (+142 lines)
  [PARTIAL]      Add validation — model validates but missing controller checks
  [NOT DONE]     Add caching layer — no cache-related changes in diff
  [CHANGED]      "Redis queue" → implemented with Sidekiq instead

## Test Items
  [DONE]         Unit tests for UserService — test/services/user_service_test.rb
  [NOT DONE]    E2E test for signup flow

## Cross-Repo / External Items
  [UNVERIFIABLE] Cloudflare DNS-only on api.example.com — confirm manually

─────────────────────────────────
COMPLETION: 5/9 DONE, 1 PARTIAL, 1 NOT DONE, 1 CHANGED, 2 UNVERIFIABLE
─────────────────────────────────
```

**HIGH-impact discrepancies trigger AskUserQuestion** with options:
A) Stop and implement missing items
B) Ship anyway + create P1 TODOs
C) Intentionally dropped — proceed

**STOP. AskUserQuestion per HIGH-impact discrepancy.**

---

## Step 2: Get the diff

```bash
git fetch origin <base> --quiet
DIFF_BASE=$(git merge-base origin/<base> HEAD)
git diff "$DIFF_BASE"
```

This includes both committed and uncommitted changes, excluding commits that landed on the base branch after this branch was created.

Also detect scope signals for specialist gating:

```bash
DIFF_FILES=$(git diff --name-only "$DIFF_BASE")
DIFF_LINES=$(git diff --shortstat "$DIFF_BASE" | grep -oE '[0-9]+ insertion' | grep -oE '[0-9]+' || echo 0)
```

Scope flags (derive these from `DIFF_FILES`):

- `SCOPE_AUTH` — touches auth/session/login/permission/policy files
- `SCOPE_BACKEND` — touches server, controller, service, model, API route files
- `SCOPE_FRONTEND` — touches `.css`, `.scss`, `.tsx`, `.jsx`, `.vue`, frontend template files
- `SCOPE_MIGRATIONS` — touches `migrations/`, `db/migrate/`, `*.sql`, schema files
- `SCOPE_API` — touches API spec, OpenAPI, route definitions

You will use these to gate specialist dispatch in Step 4.

---

## Step 3: Critical pass (core review)

Apply the CRITICAL categories below against the diff. Be specific — cite `file:line` and suggest a fix. Skip anything that's fine. Only flag real problems.

**Output format:**

```
Pre-Landing Review: N issues (X critical, Y informational)

**AUTO-FIXED:**
- [file:line] Problem → fix applied

**NEEDS INPUT:**
- [file:line] Problem description
  Recommended fix: suggested fix
```

If no issues: `Pre-Landing Review: No issues found.`

Be terse. One line problem, one line fix. No preamble, no summaries, no "looks good overall."

### Pass 1 — CRITICAL

#### SQL & Data Safety

- String interpolation in SQL (even with `.to_i`/`.to_f`) — use parameterized queries (Rails `sanitize_sql_array`/Arel; Node prepared statements; Python parameterized queries).
- TOCTOU races: check-then-set patterns that should be atomic `WHERE` + `update_all`.
- Bypassing model validations for direct DB writes (Rails `update_column`; Django `QuerySet.update()`; Prisma raw queries).
- N+1 queries: missing eager loading (Rails `.includes()`; SQLAlchemy `joinedload()`; Prisma `include`) for associations used in loops/views.

#### Race Conditions & Concurrency

- Read-check-write without a uniqueness constraint or duplicate-key retry (e.g., `where(hash:).first` then `save!`).
- find-or-create without a unique DB index — concurrent calls can create duplicates.
- Status transitions that don't use atomic `WHERE old_status = ? UPDATE SET new_status` — concurrent updates can skip or double-apply transitions.
- Unsafe HTML rendering (Rails `.html_safe`/`raw()`; React `dangerouslySetInnerHTML`; Vue `v-html`; Django `|safe`/`mark_safe`) on user-controlled data (XSS).

#### LLM Output Trust Boundary

- LLM-generated values (emails, URLs, names) written to DB or passed to mailers without format validation. Add lightweight guards (`EMAIL_REGEXP`, `URI.parse`, `.strip`) before persisting.
- Structured tool output (arrays, hashes) accepted without type/shape checks before DB writes.
- LLM-generated URLs fetched without an allowlist — SSRF risk.
- LLM output stored in knowledge bases or vector DBs without sanitization — stored prompt injection risk.

#### Shell Injection (Python-specific)

- `subprocess.run()` / `subprocess.call()` / `subprocess.Popen()` with `shell=True` AND f-string/`.format()` interpolation — use argument arrays.
- `os.system()` with variable interpolation — replace with `subprocess.run()` arrays.
- `eval()` / `exec()` on LLM-generated code without sandboxing.

#### Enum & Value Completeness

When the diff introduces a new enum value, status string, tier name, or type constant:

- **Trace it through every consumer.** READ (don't just grep) each file that switches on, filters by, or displays that value. Common miss: adding a value to the frontend dropdown but the backend model/compute method doesn't persist it.
- **Check allowlists/filter arrays.** Search for arrays containing sibling values (e.g., adding `"revise"` to tiers, find every `%w[quick lfg mega]` and verify `"revise"` is included where needed).
- **Check `case`/`if-elsif` chains.** Does the new value fall through to a wrong default?

This is the one category where within-diff review is insufficient. Use Grep to find sibling references, then Read each file.

**STOP. AskUserQuestion per critical issue (these are riskier — default to ASK).**

### Pass 2 — INFORMATIONAL

#### Async/Sync Mixing (Python)

- Synchronous `subprocess.run()`, `open()`, `requests.get()` inside `async def` — blocks the event loop. Use `asyncio.to_thread()`, `aiofiles`, or `httpx.AsyncClient`.
- `time.sleep()` inside async — use `asyncio.sleep()`.
- Sync DB calls in async context without `run_in_executor()`.

#### Column/Field Name Safety

- Verify column names in ORM queries (`.select()`, `.eq()`, `.gte()`, `.order()`) against the actual schema — wrong names silently return empty or throw swallowed errors.
- Check `.get()` calls use the column name actually selected.

#### Dead Code & Consistency (version/changelog only)

- Version mismatch between PR title and `VERSION`/`CHANGELOG` files.
- CHANGELOG entries describing changes inaccurately ("changed from X to Y" when X never existed).

#### LLM Prompt Issues

- 0-indexed lists in prompts (LLMs reliably return 1-indexed).
- Prompt text listing tools/capabilities that don't match the actual `tool_classes`/`tools` array.
- Word/token limits stated in multiple places that could drift.

#### Completeness Gaps

- Shortcut implementations where the complete version would cost <30 minutes.
- Test coverage gaps where adding the missing tests is straightforward.
- Features implemented at 80-90% when 100% is achievable with modest additional code.

#### Time Window Safety

- Date-key lookups that assume "today" covers 24h — report at 8am PT only sees midnight→8am under today's key.
- Mismatched time windows between related features.

#### Type Coercion at Boundaries

- Values crossing Ruby→JSON→JS boundaries where type could change (numeric vs string) — hash/digest inputs must normalize.
- Hash/digest inputs that don't call `.to_s` before serialization — `{ cores: 8 }` vs `{ cores: "8" }` produce different hashes.

#### View/Frontend

- Inline `<style>` blocks in partials (re-parsed every render).
- O(n*m) lookups in views (`Array#find` in a loop instead of `index_by` hash).
- Ruby-side `.select{}` filtering on DB results that could be a `WHERE` clause.

#### Distribution & CI/CD Pipeline

- CI/CD workflow changes (`.github/workflows/`): verify tool versions match project requirements, artifact paths are correct, secrets use `${{ secrets.X }}`.
- New artifact types: verify a publish/release workflow exists.
- Cross-platform builds: verify CI matrix covers all target OS/arch combos.
- Version tag format consistency: `v1.2.3` vs `1.2.3` — must match across `VERSION`, git tags, publish scripts.
- Publish step idempotency: re-running should not fail (`gh release delete` before `gh release create`).

**DO NOT flag:**

- Web services with existing auto-deploy pipelines.
- Internal tools not distributed outside the team.
- Test-only CI changes.

**Search-before-recommending.** When recommending a fix pattern (especially for concurrency, caching, auth, framework-specific behavior):
- Verify the pattern is current best practice for the framework version in use.
- Check if a built-in solution exists in newer versions.
- Verify API signatures against current docs.

If WebSearch is unavailable, note it and proceed with in-distribution knowledge.

---

## Step 4: Review army — specialist dispatch

After the critical pass, dispatch parallel specialist reviews scoped to what the diff touches. Each specialist reads its own checklist (folded inline below) and produces JSON findings.

### Specialist selection

Always-on:

- **Testing** specialist
- **Maintainability** specialist

Scope-gated:

- **Security** — if `SCOPE_AUTH=true`, OR `SCOPE_BACKEND=true` AND `DIFF_LINES > 100`
- **Performance** — if `SCOPE_BACKEND=true` OR `SCOPE_FRONTEND=true`
- **Data Migration** — if `SCOPE_MIGRATIONS=true`
- **API Contract** — if `SCOPE_API=true`
- **Design** — if `SCOPE_FRONTEND=true`

Small-diff cutoff:

**If `DIFF_LINES < 50`:** skip all specialists. Print `Small diff (N lines) — specialists skipped.` Continue to Step 5.

**Force flags:** if the user's prompt includes `--security`, `--performance`, `--testing`, `--maintainability`, `--data-migration`, `--api-contract`, `--design`, or `--all-specialists`, force-include those.

Print the selection: `Dispatching N specialists: [names]. Skipped: [names] (scope not detected).`

### Specialist output schema

Each specialist outputs JSON findings, one per line:

```
{"severity":"CRITICAL|INFORMATIONAL","confidence":N,"path":"file","line":N,"category":"<name>","summary":"...","fix":"...","fingerprint":"path:line:<name>","specialist":"<name>"}
```

Required fields: `severity`, `confidence`, `path`, `category`, `summary`, `specialist`. Optional: `line`, `fix`, `fingerprint`, `evidence`, `test_stub`. If a specialist finds nothing: output `NO FINDINGS` and stop.

### Specialist checklists (run the ones selected above)

#### Specialist: Testing (always on)

**Missing negative-path tests**

- New code paths that handle errors, rejections, or invalid input with NO test.
- Guard clauses and early returns that are untested.
- Error branches in try/catch, rescue, or error boundaries with no failure-path test.
- Permission/auth checks asserted in code but never tested for the "denied" case.

**Missing edge-case coverage**

- Boundary values: zero, negative, max-int, empty string, empty array, nil/null/undefined.
- Single-element collections (off-by-one on loops).
- Unicode and special characters in user-facing inputs.
- Concurrent access patterns with no race-condition test.

**Test isolation violations**

- Tests sharing mutable state (class variables, global singletons, DB records not cleaned up).
- Order-dependent tests (pass in sequence, fail when randomized).
- Tests depending on system clock, timezone, or locale.
- Tests making real network calls instead of stubs/mocks.

**Flaky test patterns**

- Timing-dependent assertions (sleep, setTimeout, waitFor with tight timeouts).
- Assertions on ordering of unordered results.
- Tests depending on external services without fallback.
- Randomized test data without seed control.

**Security enforcement tests missing**

- Auth/authz checks in controllers with no test for the "unauthorized" case.
- Rate limiting logic with no test proving it actually blocks.
- Input sanitization with no test for malicious input.
- CSRF/CORS configuration with no integration test.

**Coverage gaps**

- New public methods/functions with zero test coverage.
- Changed methods where existing tests only cover the old behavior, not the new branch.
- Utility functions called from multiple places but tested only indirectly.

#### Specialist: Maintainability (always on)

**Dead code & unused imports**

- Variables assigned but never read.
- Functions/methods defined but never called (check with Grep across the repo).
- Imports/requires no longer referenced after the change.
- Commented-out code blocks (remove or explain).

**Magic numbers & string coupling**

- Bare numeric literals used in logic (thresholds, limits, retry counts) — should be named constants.
- Error message strings used as query filters or conditionals elsewhere.
- Hardcoded URLs, ports, or hostnames that should be config.
- Duplicated literal values across multiple files.

**Stale comments & docstrings**

- Comments describing old behavior after the code was changed in this diff.
- TODO/FIXME comments referencing completed work.
- Docstrings with parameter lists that don't match the current function signature.
- ASCII diagrams in comments that no longer match the code flow.

**DRY violations**

- Similar code blocks (3+ lines) appearing multiple times within the diff.
- Copy-paste patterns where a shared helper would be cleaner.
- Configuration or setup logic duplicated across test files.
- Repeated conditional chains that could be a lookup table.

**Conditional side effects**

- Code paths that branch on a condition but forget a side effect on one branch.
- Log messages claiming an action happened but the action was conditionally skipped.
- State transitions where one branch updates related records but the other doesn't.
- Event emissions that only fire on the happy path, missing error/edge paths.

**Module boundary violations**

- Reaching into another module's internal implementation.
- Direct database queries in controllers/views that should go through a service/model.
- Tight coupling between components that should communicate through interfaces.

#### Specialist: Security (scope-gated)

Goes deeper than the main CRITICAL pass — focuses on auth/authz patterns, cryptographic misuse, and attack surface expansion.

**Input validation at trust boundaries**

- User input accepted without validation at controller/handler level.
- Query parameters used directly in DB queries or file paths.
- Request body fields accepted without type checking or schema validation.
- File uploads without type/size/content validation.
- Webhook payloads processed without signature verification.

**Auth & authorization bypass**

- Endpoints missing authentication middleware.
- Authorization checks that default to "allow" instead of "deny".
- Role escalation paths (user can modify their own role/permissions).
- Direct object reference vulnerabilities (user A accesses user B's data by changing an ID).
- Session fixation or session hijacking opportunities.
- Token/API key validation that doesn't check expiration.

**Injection vectors (beyond SQL)**

- Command injection via subprocess calls with user-controlled arguments.
- Template injection (Jinja2, ERB, Handlebars) with user input.
- LDAP injection.
- SSRF via user-controlled URLs (fetch, redirect, webhook targets).
- Path traversal via user-controlled file paths.
- Header injection via user-controlled HTTP header values.

**Cryptographic misuse**

- Weak hashing algorithms (MD5, SHA1) for security-sensitive operations.
- Predictable randomness (`Math.random`, `rand()`) for tokens or secrets.
- Non-constant-time comparisons (`==`) on secrets, tokens, or digests.
- Hardcoded encryption keys or IVs.
- Missing salt in password hashing.

**Secrets exposure**

- API keys, tokens, or passwords in source code (even in comments).
- Secrets logged in application logs or error messages.
- Credentials in URLs.
- Sensitive data in error responses returned to users.
- PII stored in plaintext when encryption is expected.

**XSS via escape hatches**

- Rails `.html_safe`, `raw()` on user-controlled data.
- React `dangerouslySetInnerHTML` with user content.
- Vue `v-html` with user content.
- Django `|safe`, `mark_safe()` on user input.
- General `innerHTML` assignment with unsanitized data.

**Deserialization**

- Deserializing untrusted data (`pickle`, `Marshal`, `YAML.load`, `JSON.parse` of executable types).
- Accepting serialized objects from user input or external APIs without schema validation.

#### Specialist: Performance (scope-gated)

**N+1 queries**

- ActiveRecord/ORM associations traversed in loops without eager loading.
- DB queries inside iteration blocks that could be batched.
- Nested serializers triggering lazy-loaded associations.
- GraphQL resolvers querying per-field instead of batching (check DataLoader).

**Missing database indexes**

- New WHERE clauses on columns without indexes.
- New ORDER BY on non-indexed columns.
- Composite queries (WHERE a AND b) without composite indexes.
- Foreign key columns added without indexes.

**Algorithmic complexity**

- O(n²) or worse: nested loops over collections, `Array.find` inside `Array.map`.
- Repeated linear searches that could use a hash/map/set.
- String concatenation in loops.
- Sorting or filtering large collections multiple times.

**Bundle size impact (frontend)**

- New production dependencies that are known-heavy (moment.js, full lodash, jquery).
- Barrel imports (`import from 'library'`) instead of deep imports.
- Large static assets committed without optimization.
- Missing code splitting for route-level chunks.

**Rendering performance (frontend)**

- Fetch waterfalls — sequential API calls that could be `Promise.all`.
- Unnecessary re-renders from unstable references (new objects/arrays in render).
- Missing `React.memo`, `useMemo`, `useCallback` on expensive computations.
- Layout thrashing from reading then writing DOM properties in loops.
- Missing `loading="lazy"` on below-fold images.

**Missing pagination**

- List endpoints returning unbounded results.
- DB queries without LIMIT that grow with data volume.
- API responses embedding full nested objects instead of IDs with expansion.

**Blocking in async contexts**

- Synchronous I/O inside async functions.
- `time.sleep()` / `Thread.sleep()` inside event-loop-based handlers.
- CPU-intensive computation blocking the main thread without worker offload.

#### Specialist: Data Migration (scope-gated)

**Reversibility**

- Can this migration be rolled back without data loss?
- Is there a corresponding down/rollback migration?
- Does the rollback actually undo the change or just no-op?
- Would rolling back break the current application code?

**Data loss risk**

- Dropping columns that still contain data (add deprecation period first).
- Changing column types that truncate data (varchar(255) → varchar(50)).
- Removing tables without verifying no code references them.
- Renaming columns without updating all references (ORM, raw SQL, views).
- NOT NULL constraints added to columns with existing NULL values (needs backfill first).

**Lock duration**

- ALTER TABLE on large tables without CONCURRENTLY (PostgreSQL).
- Adding indexes without CONCURRENTLY on tables with >100K rows.
- Multiple ALTER TABLE statements that could be combined.
- Schema changes that acquire exclusive locks during peak traffic.

**Backfill strategy**

- New NOT NULL columns without DEFAULT value.
- New columns with computed defaults that need batch population.
- Missing backfill script for existing records.
- Backfill that updates all rows at once instead of batching.

**Index creation**

- CREATE INDEX without CONCURRENTLY on production tables.
- Duplicate indexes (new index covers same columns as existing one).
- Missing indexes on new foreign key columns.
- Partial indexes where a full index would be more useful (or vice versa).

**Multi-phase safety**

- Migrations that must be deployed in a specific order with application code.
- Schema changes that break the current running code (deploy code first, then migrate).
- Migrations assuming a deploy boundary (old code + new schema = crash).
- Missing feature flag to handle mixed old/new code during rolling deploy.

#### Specialist: API Contract (scope-gated)

**Breaking changes**

- Removed fields from response bodies.
- Changed field types (string → number, object → array).
- New required parameters added to existing endpoints.
- Changed HTTP methods (GET → POST) or status codes (200 → 201).
- Renamed endpoints without maintaining the old path as a redirect/alias.
- Changed authentication requirements (public → authenticated).

**Versioning strategy**

- Breaking changes made without a version bump (v1 → v2).
- Multiple versioning strategies mixed in the same API (URL vs header vs query param).
- Deprecated endpoints without a sunset timeline or migration guide.
- Version-specific logic scattered across controllers instead of centralized.

**Error response consistency**

- New endpoints returning different error formats than existing ones.
- Error responses missing standard fields (error code, message, details).
- HTTP status codes that don't match the error type (200 for errors, 500 for validation).
- Error messages that leak internal implementation details (stack traces, SQL).

**Rate limiting & pagination**

- New endpoints missing rate limiting when similar endpoints have it.
- Pagination changes (offset → cursor) without backwards compatibility.
- Changed page sizes or default limits without documentation.
- Missing total count or next-page indicators in paginated responses.

**Documentation drift**

- OpenAPI/Swagger spec not updated to match new endpoints or changed params.
- README or API docs describing old behavior after changes.
- Example requests/responses that no longer work.
- Missing documentation for new endpoints or changed parameters.

**Backwards compatibility**

- Clients on older versions: will they break?
- Mobile apps that can't force-update: does the API still work for them?
- Webhook payloads changed without notifying subscribers.
- SDK or client library changes needed to use new features.

#### Specialist: Design (scope-gated, frontend only)

This specialist applies to **source code in the diff**, not rendered output. Read each changed frontend file (full file, not just diff hunks) and flag anti-patterns.

**Calibration:** If `DESIGN.md` or `design-system.md` exists in the repo root, read it first. All findings are calibrated against the project's stated design system. If no `DESIGN.md` exists, use universal design principles.

**Confidence tiers:**
- **[HIGH]** — Reliably detectable via grep/pattern match. Definitive findings.
- **[MEDIUM]** — Detectable via pattern aggregation. Flag but expect some noise.
- **[LOW]** — Requires understanding visual intent. Present as "Possible — verify visually."

**AUTO-FIX (mechanical CSS, no design judgment):**
- `outline: none` without replacement → add `outline: revert` or `&:focus-visible { outline: 2px solid currentColor; }`
- `!important` in new CSS → remove and fix specificity
- `font-size` < 16px on body text → bump to 16px

Everything else is ASK. LOW confidence items are never AUTO-FIX.

**AI slop detection (highest priority)**

- [MEDIUM] Purple/violet/indigo gradient backgrounds. Look for `linear-gradient` in `#6366f1`–`#8b5cf6` range.
- [LOW] The 3-column feature grid: icon-in-colored-circle + bold title + 2-line description, repeated 3x symmetrically.
- [LOW] Icons in colored circles as section decoration (`border-radius: 50%` + background color as decorative containers).
- [HIGH] Centered everything: `text-align: center` on all headings, descriptions, cards. If >60% of text containers use center alignment, flag.
- [MEDIUM] Uniform bubbly border-radius (16px+) on every element. If >80% use the same value ≥16px, flag.
- [MEDIUM] Generic hero copy: "Welcome to [X]", "Unlock the power of...", "Revolutionize your...", "Streamline your workflow".

**Typography**

- [HIGH] Body text `font-size` < 16px on `body`, `p`, `.text`, or base styles.
- [HIGH] More than 3 font families introduced in the diff.
- [HIGH] Heading hierarchy skipping levels: `h1` followed by `h3` without an `h2`.
- [HIGH] Blacklisted fonts: Papyrus, Comic Sans, Lobster, Impact, Jokerman.

**Spacing & layout**

- [MEDIUM] Arbitrary spacing values not on the project's scale (when `DESIGN.md` specifies one).
- [MEDIUM] Fixed widths without responsive handling: `width: NNNpx` without `max-width` or `@media` breakpoints.
- [MEDIUM] Missing `max-width` on text containers (allows lines >75 characters).
- [HIGH] `!important` in new CSS rules.

**Interaction states**

- [MEDIUM] Interactive elements (buttons, links, inputs) missing `:hover` and `:focus`/`:focus-visible`.
- [HIGH] `outline: none` / `outline: 0` without a replacement focus indicator.
- [LOW] Touch targets < 44px on interactive elements (requires computing effective size from multiple properties).

**`DESIGN.md` violations (only if DESIGN.md exists)**

- [MEDIUM] Colors not in the stated palette.
- [MEDIUM] Fonts not in the stated typography section.
- [MEDIUM] Spacing values outside the stated scale.

**Design output format:**

```
Design Review: N issues (X auto-fixable, Y need input, Z possible)

**AUTO-FIXED:**
- [file:line] Problem → fix applied

**NEEDS INPUT:**
- [file:line] Problem description
  Recommended fix: suggested fix

**POSSIBLE (verify visually):**
- [file:line] Possible issue — verify
```

**Design suppressions** — do NOT flag:

- Patterns explicitly documented in `DESIGN.md` as intentional.
- Third-party/vendor CSS (`node_modules`, `vendor/`).
- CSS resets or normalize stylesheets.
- Test fixture files.
- Generated/minified CSS.

#### Specialist: Red Team (conditional)

**Activation:** if `DIFF_LINES > 200` OR any other specialist produced a CRITICAL finding. Run this **after** other specialists.

This is NOT a checklist review. This is adversarial analysis. You receive the other specialists' findings. Your job is to find what they MISSED. Think like an attacker, a chaos engineer, and a hostile QA tester simultaneously.

**Approach:**

1. **Attack the happy path**
   - What happens at 10x normal load?
   - What happens when two requests hit the same resource simultaneously?
   - What happens when the DB is slow (>5s)?
   - What happens when an external service returns garbage?

2. **Find the silent failures**
   - Error handling that swallows exceptions (catch-all with just a log).
   - Operations that can partially complete (3 of 5 items processed, then crash).
   - State transitions that leave records in inconsistent states on failure.
   - Background jobs that fail without alerting anyone.

3. **Exploit trust assumptions**
   - Data validated on the frontend but not the backend.
   - Internal APIs called without authentication ("only our code calls this").
   - Configuration values assumed to be present but not validated.
   - File paths or URLs constructed from user input without sanitization.

4. **Break the edge cases**
   - Maximum possible input size?
   - Zero items, empty strings, null values?
   - First run ever (no existing data)?
   - User clicks the button twice in 100ms?

5. **Find what the other specialists missed**
   - Review each specialist's findings. What's the gap between their categories?
   - Look for cross-category issues (e.g., a performance issue that's also a security issue).
   - Look for issues at integration boundaries.
   - Look for issues that only manifest in specific deployment configurations.

### Merging specialist findings

After all specialists complete:

1. **Parse findings.** For each specialist: `NO FINDINGS` → skip. Otherwise parse JSON lines.
2. **Fingerprint and deduplicate.** Group by `fingerprint` (or `{path}:{line}:{category}`). For findings sharing a fingerprint:
   - Keep the highest-confidence finding.
   - Tag it `MULTI-SPECIALIST CONFIRMED ({a} + {b})`.
   - Boost confidence by +1 (cap at 10).
3. **Apply confidence gates:**
   - 7+: show normally
   - 5-6: show with caveat "Medium confidence — verify"
   - 3-4: appendix only
   - 1-2: suppress entirely
4. **Compute PR Quality Score:** `quality_score = max(0, 10 - (critical_count * 2 + informational_count * 0.5))`. Cap at 10.
5. **Output merged findings:**

   ```
   SPECIALIST REVIEW: N findings (X critical, Y informational) from Z specialists

   [SEVERITY] (confidence: N/10, specialist: name) path:line — summary
     Fix: recommended fix
     [If MULTI-SPECIALIST CONFIRMED: show confirmation note]

   PR Quality Score: X/10
   ```

Findings flow into Step 5 Fix-First alongside the critical-pass findings.

---

## Step 5: Fix-first review

**Every finding gets action — not just critical ones.**

### Step 5a: Classify each finding

For each finding (critical pass + specialists), classify as AUTO-FIX or ASK per the Fix-First Heuristic below.

```
AUTO-FIX (agent fixes without asking):     ASK (needs human judgment):
├─ Dead code / unused variables            ├─ Security (auth, XSS, injection)
├─ N+1 queries (missing eager loading)     ├─ Race conditions
├─ Stale comments contradicting code       ├─ Design decisions
├─ Magic numbers → named constants         ├─ Large fixes (>20 lines)
├─ Missing LLM output validation           ├─ Enum completeness
├─ Version/path mismatches                 ├─ Removing functionality
├─ Variables assigned but never read       └─ Anything changing user-visible behavior
└─ Inline styles, O(n*m) view lookups
```

**Rule of thumb:** mechanical fixes a senior engineer would apply without discussion → AUTO-FIX. Reasonable engineers could disagree → ASK.

- **Critical findings default toward ASK** (riskier).
- **Informational findings default toward AUTO-FIX** (mechanical).

**Test stub override:** any finding with a `test_stub` field is reclassified as ASK. Show the proposed test file path and code. Derive the test path from project conventions: `spec/` for RSpec, `__tests__/` for Jest/Vitest, `test_` prefix for pytest, `_test.go` suffix for Go. If the test file exists, append; otherwise create. Output `[FIXED + TEST] [file:line] Problem -> fix + test at [test_path]`.

### Step 5b: Auto-fix all AUTO-FIX items

Apply each fix directly. For each, output one line:

```
[AUTO-FIXED] [file:line] Problem → what you did
```

### Step 5c: Batch-ask about ASK items

If there are ASK items, present them in ONE AskUserQuestion:

- Each item: number, severity label, problem, recommended fix.
- For each: A) Fix as recommended, B) Skip.
- Include an overall RECOMMENDATION.

Example:

```
I auto-fixed 5 issues. 2 need your input:

1. [CRITICAL] app/models/post.rb:42 — Race condition in status transition
   Fix: Add `WHERE status = 'draft'` to the UPDATE
   → A) Fix  B) Skip

2. [INFORMATIONAL] app/services/generator.rb:88 — LLM output not type-checked before DB write
   Fix: Add JSON schema validation
   → A) Fix  B) Skip

RECOMMENDATION: Fix both — #1 is a real race condition, #2 prevents silent data corruption.
```

If 3 or fewer ASK items, you may use individual AskUserQuestion calls instead of batching.

**STOP. Wait for the user's response before applying fixes.**

### Step 5d: Apply user-approved fixes

Apply fixes for items where the user chose "Fix." Output what was fixed.

If no ASK items exist (everything was AUTO-FIX), skip the question entirely.

---

## Step 6: Verification of claims

Before producing the final review output:

- "This pattern is safe" → cite the specific line proving safety.
- "This is handled elsewhere" → read and cite the handling code.
- "Tests cover this" → name the test file and method.
- Never say "likely handled" or "probably tested" — verify or flag as unknown.

**Rationalization prevention:** "This looks fine" is not a finding. Either cite evidence it IS fine, or flag it as unverified.

---

## Step 7: TODOS cross-reference

Read `TODOS.md` in the repository root if it exists.

- **Does this PR close any open TODOs?** If yes, note them in your output: `This PR addresses TODO: <title>`.
- **Does this PR create work that should become a TODO?** If yes, flag as an informational finding.
- **Are there related TODOs that provide context for this review?** If yes, reference them when discussing related findings.

If `TODOS.md` doesn't exist, skip silently.

### TODOS output format

When recommending new TODO items, use this canonical format.

**File structure:**

```markdown
# TODOS

## <Skill/Component>     ← e.g., ## Backend, ## Frontend, ## Infrastructure
<items sorted P0 first, then P1, P2, P3, P4>

## Completed
<finished items with completion annotation>
```

**TODO item format** (H3 under its section):

```markdown
### <Title>

**What:** One-line description of the work.

**Why:** The concrete problem it solves or value it unlocks.

**Context:** Enough detail that someone picking this up in 3 months understands the motivation, the current state, and where to start.

**Effort:** S / M / L / XL
**Priority:** P0 / P1 / P2 / P3 / P4
**Depends on:** <prerequisites, or "None">
```

**Required fields:** What, Why, Context, Effort, Priority.
**Optional fields:** Depends on, Blocked by.

**Priority definitions:**

- **P0** — Blocking: must be done before next release.
- **P1** — Critical: should be done this cycle.
- **P2** — Important: do when P0/P1 are clear.
- **P3** — Nice-to-have: revisit after adoption/usage data.
- **P4** — Someday: good idea, no urgency.

**Completed item format** — when an item is completed, move it to `## Completed` preserving original content and appending:

```markdown
**Completed:** vX.Y.Z (YYYY-MM-DD)
```

---

## Step 8: Documentation staleness check

Cross-reference the diff against documentation files. For each `.md` file in the repo root (`README.md`, `ARCHITECTURE.md`, `CONTRIBUTING.md`, `CLAUDE.md`, etc.):

1. Check if code changes in the diff affect features, components, or workflows described in that doc file.
2. If the doc file was NOT updated in this branch but the code it describes WAS changed, flag as an INFORMATIONAL finding:
   > "Documentation may be stale: [file] describes [feature/component] but code changed in this branch."

Informational only — never critical.

If no doc files exist, skip silently.

---

## Important rules

- **Read the FULL diff before commenting.** Do not flag issues already addressed in the diff.
- **Fix-first, not read-only.** AUTO-FIX items are applied directly. ASK items are only applied after user approval. Never commit, push, or create PRs.
- **Be terse.** One line problem, one line fix. No preamble.
- **Only flag real problems.** Skip anything that's fine.
- **Search before recommending** patterns for concurrency, caching, auth, or framework-specific behavior — APIs change between versions.
- **Second opinion (optional).** For tricky judgment calls you may seek a second opinion from another AI tool, but treat its findings as advisory, not authoritative.

## Suppressions — DO NOT flag

- "X is redundant with Y" when the redundancy is harmless and aids readability (e.g., `present?` redundant with `length > 20`).
- "Add a comment explaining why this threshold/constant was chosen" — thresholds change during tuning, comments rot.
- "This assertion could be tighter" when the assertion already covers the behavior.
- Consistency-only changes (wrapping a value in a conditional to match how another constant is guarded).
- "Regex doesn't handle edge case X" when the input is constrained and X never occurs in practice.
- "Test exercises multiple guards simultaneously" — that's fine.
- Eval threshold changes — these are tuned empirically and change constantly.
- Harmless no-ops (e.g., `.reject` on an element that's never in the array).
- ANYTHING already addressed in the diff you're reviewing — read the FULL diff before commenting.

---

## Severity classification reference

```
CRITICAL (highest severity):      INFORMATIONAL (main agent):      SPECIALIST (parallel):
├─ SQL & Data Safety              ├─ Async/Sync Mixing             ├─ Testing
├─ Race Conditions & Concurrency  ├─ Column/Field Name Safety      ├─ Maintainability
├─ LLM Output Trust Boundary      ├─ Dead Code (version only)      ├─ Security
├─ Shell Injection                ├─ LLM Prompt Issues             ├─ Performance
└─ Enum & Value Completeness      ├─ Completeness Gaps             ├─ Data Migration
                                  ├─ Time Window Safety            ├─ API Contract
                                  ├─ Type Coercion at Boundaries   ├─ Design
                                  ├─ View/Frontend                 └─ Red Team (conditional)
                                  └─ Distribution & CI/CD Pipeline
```

All findings are actioned via Fix-First. Severity determines presentation order and the AUTO-FIX vs ASK lean — critical findings lean ASK, informational findings lean AUTO-FIX.
