---
name: pr-create
description: Use when the user says "create a PR", "open a pull request", "make a PR", or wants to push the current branch and open a GitHub pull request. Analyzes all commits on the branch, drafts a title and description, creates the PR via gh CLI, then monitors CI until it passes (retrying up to 2 times on failure).
disable-model-invocation: true
argument-hint: [optional base branch]
---

# Create Pull Request

Push the current branch and open a GitHub pull request with a well-crafted title and description. Then monitor CI and fix failures.

## Workflow

### Step 1: Review code quality

Run the `/simplify` skill on the changed code to check for reuse, quality, and efficiency issues. Fix any issues found before proceeding.

### Step 2: Gather context

Run these in parallel:
- `git status` — check for uncommitted changes.
- `git log --oneline main..HEAD` (or the base branch) — list all commits in this branch.
- `git diff main...HEAD` — see the full diff against the base branch.
- Check if the branch has a remote tracking branch and is up to date.

If there are uncommitted changes, ask the user whether to commit them first.

### Step 3: Determine the base branch

- Default to `main` or `master` (whichever exists on the remote).
- If the user provided a base branch argument, use that instead.

### Step 4: Analyze changes

- Review **all** commits on the branch, not just the latest one.
- Identify the type of change (feature, fix, refactor, etc.).

### Step 5: Draft the PR

- **Title**: Under 70 characters, concise, descriptive.
- **Body**: Use this format:

```markdown
## Summary
- Bullet points describing what changed and why.

## Test plan
- [ ] How to verify the changes work.
```

### Step 6: Push and create

Run these in parallel where possible:
- Create a new branch if needed.
- Push with `-u` flag if the branch has no upstream.
- Create the PR:

```bash
gh pr create --title "the pr title" --body "$(cat <<'EOF'
## Summary
- ...

## Test plan
- [ ] ...
EOF
)"
```

### Step 7: Confirm

- Return the PR URL to the user.

### Step 8: Monitor CI

After the PR is created, poll CI status every 30 seconds until all checks complete:

```bash
gh pr checks <PR_NUMBER> --watch --fail-fast
```

If `gh pr checks --watch` is not available, poll manually:

1. Wait 30 seconds, then run `gh pr checks <PR_NUMBER>`.
2. Repeat until all checks have a final status (pass or fail).

### Step 9: Handle CI failures (up to 2 retries)

If CI fails:

1. Run `gh pr checks <PR_NUMBER>` to identify which checks failed.
2. Fetch the failed check's logs using `gh run view <RUN_ID> --log-failed` to understand the failure.
3. Read the relevant source files and fix the issue (build error, test failure, lint, etc.).
4. Commit the fix with a descriptive message (e.g., `fix(ci): correct failing test in auth module`).
5. Push the fix and return to **Step 8** to monitor CI again.

Track retry count. After 2 failed fix attempts, stop and report the remaining failures to the user with the log output so they can intervene.
