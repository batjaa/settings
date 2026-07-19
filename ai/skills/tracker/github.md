# GitHub tracker operations

Module parent = a normal issue labelled `module`; tickets = **native sub-issues** of it, labelled `ticket`; blocking = **native issue dependencies** plus canonical `Blocked by:` body lines.

Two ids per issue, don't mix them: the **number** (`#42`, used in URLs, body references, and `gh issue` commands) and the numeric **database id** (returned as `.id`, required by the sub-issue and dependency endpoints). Creating via `gh api` returns both in one shot. `gh api` fills `{owner}/{repo}` from the current directory's remote.

## Create module parent

```bash
gh label create module 2>/dev/null || true
gh label create ticket 2>/dev/null || true
gh api repos/{owner}/{repo}/issues -f title="<Module>: <one-liner>" \
  -f body="Spec: docs/specs/<module>.md — see docs/ROADMAP.md" \
  -f "labels[]=module"
# capture .number (for references) and .id (for API linking) from the response
```

## Create ticket (child)

Create in dependency order, blockers first:

```bash
gh api repos/{owner}/{repo}/issues -f title="<t>" -f body="<b>" -f "labels[]=ticket"
# then attach to the parent (sub_issue_id = the ticket's DATABASE id):
gh api -X POST repos/{owner}/{repo}/issues/<parent_number>/sub_issues -F sub_issue_id=<ticket_id>
```

## Wire blocking

Body `Blocked by: #N` lines are canonical and always present. Add the native edge on top (`issue_id` = the BLOCKER's database id; for an existing issue: `gh api repos/{owner}/{repo}/issues/<n> --jq .id`):

```bash
gh api -X POST repos/{owner}/{repo}/issues/<blocked_number>/dependencies/blocked_by -F issue_id=<blocker_id>
```

## Frontier query

```bash
# open children of the module parent
gh api repos/{owner}/{repo}/issues/<parent_number>/sub_issues --paginate \
  --jq '.[] | select(.state == "open") | .number'
# a ticket is takeable when nothing open blocks it:
gh api repos/{owner}/{repo}/issues/<n>/dependencies/blocked_by \
  --jq '[.[] | select(.state == "open")] | length'   # 0 → on the frontier
```

If the dependency read fails, fall back to parsing the `Blocked by:` body lines and checking each referenced issue's state.

## Claim / Resolve / Rollup

- **Claim**: `gh issue edit <n> --add-assignee @me` (skip when solo).
- **Resolve**: `gh issue close <n> -c "<what shipped, commits, verification, deviations>"` — check off the acceptance criteria in the body first. The parent's sub-issue progress (x of y) updates automatically.
- **Rollup**: when the frontier query returns nothing and no children remain open, close the parent with a one-line summary and flip the module to `done` in `docs/ROADMAP.md`.

## Degradation

On a GitHub instance without sub-issues or dependencies (older GHE, API 404/403): skip the native calls — the `Blocked by:` body lines plus a `Parent: #<module>` line in each ticket body carry the same structure, and every recipe above has a body-parsing fallback. Never let a missing endpoint block publishing.
