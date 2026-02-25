# Global Claude Instructions

Always use Conventional Commits for git commit messages:
- Spec: https://www.conventionalcommits.org/en/v1.0.0/
- Format: `<type>(<scope>): <description>` or `<type>: <description>`
- Use an imperative, concise description.
- Common types: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`, `build`, `ci`, `perf`, `revert`.

Treat README as a living document:
- When scaffolding a project, lay out the basics (stack, setup, structure).
- When local dev tools, architecture, or dependencies change, update the README immediately.
- Keep a brief summary of architecture and tooling — it's a project overview, not a one-time snapshot.

Diagrams — choose the right tool:
- **Excalidraw** (via MCP): Use for architecture overviews, system diagrams, user flows, and anything meant to be visual/shareable. Hand-drawn style, interactive, editable. Use `roughness: 2`, `fontFamily: 1` (Virgil), and hand-drawn primitives (stick figures, envelopes, cylinders) for the authentic Excalidraw feel. Export via `export_to_excalidraw` for shareable links.
- **PlantUML**: Use for precise, structured diagrams — sequence diagrams, class diagrams, ER diagrams, state machines. Better when exact relationships and flow ordering matter more than visual style.
- **Rule of thumb**: If someone would sketch it on a whiteboard → Excalidraw. If it belongs in technical documentation with strict notation → PlantUML.
