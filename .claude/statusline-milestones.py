#!/usr/bin/env python3
"""Claude Code status line: model · branch · milestone chips read live from a
/wayfinder-style roadmap at docs/ROADMAP.md.

Generic across repos by design:
  * The Status column is found by its HEADER NAME, not a fixed position, so it
    works whether the table is `| Module | Size | ... | Status | Spec |`
    (Kedge) or `| Module | Milestone | ... | Status | Spec |` (Groove).
  * If the table has a `Milestone` column, module rows are grouped by it and
    their statuses rolled up into one chip per milestone. Otherwise each row is
    its own chip, labelled M0, M1, … by order (a row named `Launch` -> `L`).
  * No roadmap -> just model + branch. Never hard-fails: a status line must
    always print something.

Status glyph ramp (fill grows toward done):
  ready-to-spec/fog ○   deciding ◔   specced ◑   ticketed/in-progress ◕   done ✓
Unrecognised status words show a grey `·` — a visible nudge to teach the map a
new word rather than mislabel it.
"""
import json
import os
import re
import subprocess
import sys

DIM = "\033[90m"; GREEN = "\033[1;32m"; YELLOW = "\033[1;33m"
CYAN = "\033[36m"; BLUE = "\033[34m"; GREY = "\033[90m"; BOLD = "\033[1m"; R = "\033[0m"

# status word -> (glyph, color, progress-rank). Rank drives milestone rollup.
STATUS = {
    "done": ("✓", GREEN, 4), "complete": ("✓", GREEN, 4), "shipped": ("✓", GREEN, 4),
    "ticketed": ("◕", YELLOW, 3), "in-progress": ("◕", YELLOW, 3),
    "in_progress": ("◕", YELLOW, 3), "wip": ("◕", YELLOW, 3),
    "building": ("◕", YELLOW, 3), "implementing": ("◕", YELLOW, 3),
    "specced": ("◑", CYAN, 2), "spec": ("◑", CYAN, 2),
    "deciding": ("◔", BLUE, 1), "scoping": ("◔", BLUE, 1),
    "ready-to-spec": ("○", GREY, 0), "ready": ("○", GREY, 0),
    "backlog": ("○", GREY, 0), "todo": ("○", GREY, 0), "fog": ("○", GREY, 0),
}
UNKNOWN = ("·", GREY, -1)


def cells(line):
    s = line.strip()
    if s.startswith("|"):
        s = s[1:]
    if s.endswith("|"):
        s = s[:-1]
    return [c.strip() for c in s.split("|")]


def is_separator(cc):
    return bool(cc) and all(re.fullmatch(r":?-+:?", c) for c in cc)


def norm_status(s):
    return re.split(r"[\s(]", (s or "").strip().lower(), maxsplit=1)[0]


def parse_roadmap(path):
    """-> (chips_data, name). chips_data is a list of (label, (glyph,color,rank))."""
    try:
        lines = open(path, encoding="utf-8").read().splitlines()
    except OSError:
        return [], None

    name = None
    for ln in lines:
        m = re.match(r"^#\s*Roadmap:\s*(\S+)", ln)
        if m:
            name = m.group(1)
            break

    hdr = None
    for i, ln in enumerate(lines):
        low = ln.lower()
        if ln.lstrip().startswith("|") and "status" in low and "module" in low:
            hdr = i
            break
    if hdr is None:
        return [], name

    header = [c.lower() for c in cells(lines[hdr])]
    if "status" not in header:
        return [], name
    si = header.index("status")
    mi = header.index("milestone") if "milestone" in header else None
    modi = header.index("module") if "module" in header else 0

    rows = []  # (milestone_or_None, status_norm, module)
    for ln in lines[hdr + 1:]:
        if not ln.lstrip().startswith("|"):
            break
        cc = cells(ln)
        if is_separator(cc) or si >= len(cc):
            continue
        milestone = cc[mi].split()[0] if (mi is not None and mi < len(cc) and cc[mi]) else None
        module = cc[modi] if modi < len(cc) else ""
        rows.append((milestone, norm_status(cc[si]), module))

    chips = []
    if rows and mi is not None:
        order, groups = [], {}
        for milestone, status, module in rows:
            key = milestone or module
            if key not in groups:
                groups[key] = []
                order.append(key)
            groups[key].append(status)
        for key in order:
            chips.append((key, rollup(groups[key])))
    else:
        idx = 0
        for _milestone, status, module in rows:
            if module.strip().lower() == "launch":
                label = "L"
            else:
                label = f"M{idx}"
                idx += 1
            chips.append((label, STATUS.get(status, UNKNOWN)))
    return chips, name


def rollup(statuses):
    """One milestone chip from its modules' statuses."""
    ranks = [STATUS.get(s, UNKNOWN)[2] for s in statuses]
    known = [r for r in ranks if r >= 0]
    if not known:
        return UNKNOWN
    if all(r == 4 for r in known):
        return STATUS["done"]
    if any(r >= 2 for r in known):   # some built/specced or partially done
        return STATUS["ticketed"]
    if any(r == 1 for r in known):
        return STATUS["deciding"]
    return STATUS["ready-to-spec"]


def render(label, glyph_color):
    glyph, color, _ = glyph_color
    return f"{color}{label}{glyph}{R}"


def main():
    try:
        data = json.load(sys.stdin)
    except (json.JSONDecodeError, ValueError):
        data = {}

    model = (data.get("model") or {}).get("display_name") or ""
    ws = data.get("workspace") or {}
    proj = ws.get("project_dir") or data.get("cwd") or ws.get("current_dir") or os.getcwd()
    cwd = ws.get("current_dir") or data.get("cwd") or proj

    parts = []
    if model:
        parts.append(f"{DIM}{model}{R}")

    try:
        branch = subprocess.run(
            ["git", "-C", proj, "symbolic-ref", "--quiet", "--short", "HEAD"],
            capture_output=True, text=True, timeout=1,
        ).stdout.strip()
    except (OSError, subprocess.SubprocessError):
        branch = ""
    if branch:
        parts.append(f"{DIM}⎇ {branch}{R}")

    roadmap = next(
        (p for p in (os.path.join(proj, "docs", "ROADMAP.md"),
                     os.path.join(cwd, "docs", "ROADMAP.md")) if os.path.isfile(p)),
        None,
    )
    if roadmap:
        chips, name = parse_roadmap(roadmap)
        if chips:
            head = f"{BOLD}{CYAN}{name}{R} " if name else ""
            parts.append(head + " ".join(render(lbl, gc) for lbl, gc in chips))

    sys.stdout.write(f"  {DIM}·{R}  ".join(parts))


if __name__ == "__main__":
    main()
