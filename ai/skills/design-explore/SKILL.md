---
name: design-explore
description: This skill should be used when the user asks to "explore designs", "show me design options", "create design variants", "design a page", "design a landing page", "design a component", or wants to see multiple visual directions before committing to one.
disable-model-invocation: true
argument-hint: [number-of-variants] [description]
---

# Design Exploration

Generate multiple distinct design variants for a given UI requirement, present them for review, and iterate toward a final hybrid based on user feedback.

## Workflow

### Step 1: Understand Requirements

Before generating designs, clarify:
- What is being designed (page, component, app, email)?
- Who is the audience?
- Are there existing design references or brand guidelines to follow?
- What's the tech stack (Tailwind, plain CSS, Vue, React)?
- Any constraints (must be mobile-first, must match existing design system)?

If the project has existing design files (e.g., `design-system.html`, `brand-guidelines.html`, `*.html` mockups in `docs/`), read them first to understand the established visual language.

### Step 2: Generate Variants

Generate $ARGUMENTS variants (default: 3-5 if no number specified). Each variant must be:

- **Distinct** — different aesthetic direction, not minor tweaks of the same design
- **Complete** — fully functional HTML with inline Tailwind (or framework equivalent)
- **Named** — give each variant a memorable 2-word name (e.g., "Editorial Mono", "Warm Film", "Neon Street")
- **Self-contained** — single HTML file per variant, loadable in a browser

Write each variant to a descriptive file path:
```
docs/designs/variant-1-editorial-mono.html
docs/designs/variant-2-warm-film.html
docs/designs/variant-3-neon-street.html
```

### Design Diversity Guidelines

Vary these dimensions across variants:
- **Color palette**: light vs dark, warm vs cool, monochrome vs vibrant
- **Typography**: serif vs sans-serif vs mono, compact vs spacious
- **Layout**: centered vs asymmetric, card-based vs list-based, full-width vs contained
- **Tone**: minimal vs maximalist, playful vs professional, editorial vs utilitarian
- **Spacing**: tight/dense vs generous whitespace

Use Google Fonts for distinctive typography. Avoid generic defaults (Inter, Arial, Roboto).

### Step 3: Present for Review

After generating, tell the user to review them in a browser:
```
open docs/designs/variant-*.html
```

Ask which elements they like from each variant. Common feedback patterns:
- "I like the spacing from variant 2 but the colors from variant 1"
- "Variant 3's typography is best"
- "Make it more like variant 1 but with variant 2's card layout"

### Step 4: Create Hybrid

Based on feedback, create a hybrid design combining the preferred elements:
```
docs/designs/hybrid-final.html
```

Present the hybrid for another round of feedback. Iterate until approved.

### Step 5: Implement

Once the hybrid is approved, implement it in the actual application using the project's tech stack (Tailwind classes, Vue/React components, Laravel Blade, etc.).

Clean up the design exploration files or keep them as reference — ask the user.

## Rules

- Always use Tailwind utility classes. No custom CSS or scoped style blocks.
- Load fonts from Google Fonts CDN in the HTML head.
- Make designs responsive (mobile-first).
- Include realistic placeholder content — not "Lorem ipsum". Use content relevant to the project.
- If the project has a specific domain (e-commerce, SaaS, photography), tailor the content accordingly.
