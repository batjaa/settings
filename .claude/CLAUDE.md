<!-- Generated from ai/AGENTS.md by bin/ai-sync - edit there, not here. -->

# Global Agent Instructions

## Git
- Use Conventional Commits: `<type>(<scope>): <description>`. Imperative, concise.
- Types: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`, `build`, `ci`, `perf`, `revert`.

## Documentation
- Treat README as a living document — update it when stack, setup, or architecture changes.
- Diagrams: Excalidraw for visual/shareable sketches (`roughness: 2`, `fontFamily: 1`). PlantUML for precise technical diagrams (sequence, class, ER).

## Frontend
- Always use Tailwind utility classes when available. No custom CSS or scoped `<style>` blocks.

## CLI tools
- Always include a `version` subcommand. Inject version at build time (e.g., Go ldflags). Default to `"dev"` locally.
- For SVG to PNG conversion, don't assume ImageMagick will preserve the full asset. If fidelity matters, verify the rendered output and prefer `rsvg-convert` over `magick` / `convert` when available.

## Workflow
- PRD pipeline: `/wayfinder` (PRD → `docs/ROADMAP.md` modules) → `/to-spec` (module → `docs/specs/*.md`) → `/to-tickets` (spec → module parent ticket + child tickets, per `/tracker`) → `/implement` (one ticket per session, review + spec-check baked in).
- I write implementation plans as markdown specs. Follow them step-by-step, committing after each logical unit.
- After implementing, verify the change works before moving on (run the app, check output, run tests).
- When I say "commit and push", stage relevant files, write a conventional commit message, and push.

## Design
- When I ask for design variants, generate 3–5 distinct directions (not minor tweaks). Use `/design-explore`.
- Each variant: distinct name, self-contained HTML, Tailwind only, Google Fonts, realistic placeholder content.
- I'll pick favorites and ask for a hybrid. Iterate until approved, then implement in the real codebase.

## Go
- Prefer stdlib over dependencies. Evaluate any new dependency carefully.
- Use GoReleaser for releases. Homebrew tap at `batjaa/homebrew-tap`.
- Always include `version` subcommand with build-time ldflags injection.
