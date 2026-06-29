---
name: commit-and-push
description: Use when the user says "commit and push", "commit & push", "cap", or wants to stage, commit, and push changes in one step. Stages relevant files, writes a conventional commit message, and pushes to the remote.
disable-model-invocation: true
argument-hint: [optional commit message]
---

# Commit and Push

Stage relevant changes, create a conventional commit, and push to the remote branch.

## Workflow

### Step 1: Review code quality

Run the `/simplify` skill on the changed code to check for reuse, quality, and efficiency issues. Fix any issues found before proceeding.

### Step 2: Inspect the working tree

Run these in parallel:
- `git status` — identify changed and untracked files.
- `git diff` and `git diff --staged` — review all changes.
- `git log --oneline -5` — check recent commit style.

### Step 3: Stage files

- Stage only the files relevant to the current change.
- **Never** stage secrets (`.env`, credentials, tokens).
- Prefer explicit file paths over `git add -A` or `git add .`.

### Step 4: Write the commit message

- Follow **Conventional Commits**: `<type>(<scope>): <description>`.
- Types: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`, `build`, `ci`, `perf`, `revert`.
- Keep the subject line concise and imperative.
- If the user provided a message as an argument, use it (reformatted to conventional style if needed).
- Use a HEREDOC to pass the message:

```bash
git commit -m "$(cat <<'EOF'
type(scope): description
EOF
)"
```

### Step 5: Push

- Push to the current branch's remote tracking branch.
- If no upstream is set, push with `-u origin <branch>`.
- **Never** force-push without explicit user approval.

### Step 6: Confirm

- Run `git status` to verify a clean working tree.
- Show the commit hash and remote URL so the user can verify.
