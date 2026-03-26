---
name: create-pr
description: Use when the user says "create a PR", "open a pull request", "make a PR", or wants to push the current branch and open a GitHub pull request. Analyzes all commits on the branch, drafts a title and description, and creates the PR via gh CLI.
disable-model-invocation: true
argument-hint: [optional base branch]
---

# Create Pull Request

Push the current branch and open a GitHub pull request with a well-crafted title and description.

## Workflow

### Step 1: Gather context

Run these in parallel:
- `git status` — check for uncommitted changes.
- `git log --oneline main..HEAD` (or the base branch) — list all commits in this branch.
- `git diff main...HEAD` — see the full diff against the base branch.
- Check if the branch has a remote tracking branch and is up to date.

If there are uncommitted changes, ask the user whether to commit them first.

### Step 2: Determine the base branch

- Default to `main` or `master` (whichever exists on the remote).
- If the user provided a base branch argument, use that instead.

### Step 3: Analyze changes

- Review **all** commits on the branch, not just the latest one.
- Identify the type of change (feature, fix, refactor, etc.).

### Step 4: Draft the PR

- **Title**: Under 70 characters, concise, descriptive.
- **Body**: Use this format:

```markdown
## Summary
- Bullet points describing what changed and why.

## Test plan
- [ ] How to verify the changes work.
```

### Step 5: Push and create

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

### Step 6: Confirm

- Return the PR URL to the user.
