---
name: resolve-conflict
description: Use when the user wants to rebase onto a branch and resolve merge conflicts. Fetches latest, rebases, resolves all conflicts intelligently, and optionally force-pushes. Trigger on "rebase", "resolve conflicts", "rebase on main", "rebase and push".
argument-hint: [target branch, default: origin/main]
---

# Rebase and Resolve Conflicts

Rebase the current branch onto a target branch, resolve any merge conflicts intelligently, and continue until the rebase is complete.

## Steps

### 1. Fetch and start rebase
1. Run `git fetch origin` to get the latest remote state.
2. Run `git log --oneline HEAD..{target}` to show what's new on the target branch.
3. Run `git rebase {target}` (default: `origin/main`).
4. If the rebase completes cleanly, skip to Step 4.

### 2. For each conflict, resolve it
When a conflict occurs:

1. **Identify conflicted files:** Run `git diff --name-only --diff-filter=U` to list all files with conflicts.
2. **For each conflicted file:**
   a. Read the file and find all `<<<<<<<` / `=======` / `>>>>>>>` conflict markers.
   b. Understand both sides:
      - `HEAD` (theirs/target) = changes from the branch we're rebasing onto
      - The other side (ours) = changes from our commits being replayed
   c. **Resolve by combining both sides intelligently:**
      - If both sides changed different things (e.g., one changed an icon, the other added i18n), take BOTH changes.
      - If both sides changed the same thing differently, prefer our change but incorporate any non-conflicting improvements from theirs (new props, styling tweaks, etc.).
      - For `package-lock.json` conflicts: run `npm install --package-lock-only` to regenerate.
      - For generated files or lockfiles: regenerate rather than manually merge.
   d. Verify no `<<<<<<<`, `=======`, or `>>>>>>>` markers remain in the file.
3. **Stage resolved files:** `git add <resolved files>`
4. **Continue rebase:** `git rebase --continue`
5. **Repeat** if more conflicts arise on subsequent commits.

### 3. Verify
1. Run `git log --oneline {target}..HEAD` to show the rebased commits.
2. Run a quick grep for any leftover conflict markers: `grep -rn "<<<<<<" src/ --include="*.ts" --include="*.tsx" --include="*.json"`
3. If tests exist, run them to verify nothing broke.

### 4. Push (if on a remote-tracking branch)
1. Check if the branch tracks a remote: `git rev-parse --abbrev-ref @{upstream}`
2. If yes, ask the user if they want to force-push, then run: `git push --force-with-lease`

## Conflict Resolution Principles

- **Never discard changes from either side** unless they are truly redundant.
- **Upstream wins for:** styling, spacing, layout, icon changes, new props, dependency versions.
- **Our branch wins for:** the feature being developed (the whole point of the branch).
- **Both win when possible:** most conflicts are additive — both sides added different things to the same region.
- **When in doubt:** show the user both sides and ask which to keep.
- **package-lock.json:** Always regenerate with `npm install --package-lock-only`. Never manually merge.
- **Binary files or generated output:** Regenerate from source rather than merging.
