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

If the project has existing design files (e.g., `DESIGN.md`, `design-system.html`, `brand-guidelines.html`, `*.html` mockups in `docs/`), read them first to understand the established visual language. **`DESIGN.md` is the default constraint**: when present, variants explore within the documented system (its fonts, palette, and tone) unless the user explicitly asks to diverge from it — say so up front so they can opt out.

### Step 2: Pitch Concepts

Before writing any HTML, present $ARGUMENTS concepts (default: 3-5 if no number specified) as a lettered list — a memorable 2-word name plus one sentence of direction:

```
A) "Editorial Mono" — newspaper-grade serif, generous whitespace, photo-led
B) "Neon Street"    — high-contrast dark, fluorescent accents, dense info
C) "Warm Film"      — analog cream tones, rounded sans, asymmetric layout
```

Wait for confirmation before generating. This catches a wrong direction while it's still one line of text instead of a fully built HTML file.

### Step 3: Generate Variants

Each approved concept becomes one variant. Each variant must be:

- **Distinct** — different aesthetic direction, not minor tweaks of the same design
- **Complete** — fully functional HTML with inline Tailwind (or framework equivalent)
- **Named** — keep the 2-word concept name from Step 2
- **Self-contained** — single HTML file per variant, loadable in a browser

Write each variant to a descriptive file path:
```
docs/designs/variant-1-editorial-mono.html
docs/designs/variant-2-warm-film.html
docs/designs/variant-3-neon-street.html
```

### Distinctness Requirement

Every pair of variants must differ across all three of these axes:
- **Font family** — different Google Fonts from different categories (serif / sans / mono / display)
- **Color palette** — different temperature and contrast register (light vs dark, warm vs cool, monochrome vs vibrant)
- **Layout** — centered vs asymmetric, card-based vs list-based, full-width vs contained

The test: **if the headline text could be swapped between two variants without anyone noticing, they're too similar** — regenerate the weaker one in a deliberately different direction.

Also vary tone (minimal vs maximalist, playful vs professional, editorial vs utilitarian) and spacing (tight/dense vs generous whitespace).

### Anti-Slop Guardrails

Avoid the default AI aesthetic:
- Generic gradient hero backgrounds.
- Default Tailwind blue (`bg-blue-500`) as the dominant accent without deliberate intent.
- "Image / title / two-line description / button" card repeated three times in a row.
- Emoji as decoration.
- Generic fonts (Inter, Arial, Roboto) — use distinctive Google Fonts instead.
- The same hero structure recycled across variants.

### Step 4: Present for Review

After generating, tell the user to review them in a browser:
```
open docs/designs/variant-*.html
```

Ask which elements they like from each variant. Common feedback patterns:
- "I like the spacing from variant 2 but the colors from variant 1"
- "Variant 3's typography is best"
- "Make it more like variant 1 but with variant 2's card layout"

### Step 5: Create Hybrid

Based on feedback, create a hybrid design combining the preferred elements:
```
docs/designs/hybrid-final.html
```

Present the hybrid for another round of feedback. Iterate until approved.

### Step 6: Implement

Once the hybrid is approved, implement it in the actual application using the project's tech stack (Tailwind classes, Vue/React components, Laravel Blade, etc.).

Clean up the design exploration files or keep them as reference — ask the user.

## Rules

- Always use Tailwind utility classes. No custom CSS or scoped style blocks.
- Load fonts from Google Fonts CDN in the HTML head.
- Make designs responsive (mobile-first).
- Include realistic placeholder content — not "Lorem ipsum". Use content relevant to the project.
- If the project has a specific domain (e-commerce, SaaS, photography), tailor the content accordingly.
- Never write exploration mockups inside production source folders — they live in `docs/designs/` (or the project's existing mockup directory).
