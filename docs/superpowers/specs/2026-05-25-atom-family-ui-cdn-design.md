# atom-family UI CDN — Design Spec

**Date:** 2026-05-25  
**Status:** Approved  
**Scope:** brand-atoms repo + schema-atoms migration (reference implementation)

---

## Logo Atom Class

The `atom-family` brand requires a new `logo` atom class in brand-atoms. Logos are discrete, independently versioned artifacts with their own usage rules — distinct from brand tokens (colors, fonts) or layout CSS.

### `[logo]` payload section

```toml
id       = "brand-atoms/logo/atom-family-icon"
version  = "1.0.0"
content_hash = ""
lifecycle    = "draft"
created_at   = "2026-05-25T00:00:00Z"

[logo]
brand    = "atom-family"
variant  = "icon"          # icon | wordmark | lockup
theme    = "dark"          # dark | light | mono
format   = "svg"           # canonical format; png permitted as asset_source only
asset    = "atom-family-icon.svg"
asset_source = "atom-family-icon.png"   # raster source/preview; optional
```

### Two initial atoms

| Atom ID | Variant | Description |
|---|---|---|
| `logo/atom-family-icon@1.0.0` | `icon` | 4-node molecular "A" mark, icon-only — used for favicon, app icon, hero |
| `logo/atom-family-wordmark@1.0.0` | `wordmark` | Mark + "ATOMS" text lockup — used for site headers, docs |

### Normative requirements

- `format` MUST be `svg` for the primary asset. PNG is permitted only as `asset_source`.
- The canonical SVG is faithfully recreated from the provided PNG source, preserving the 4-node structure, brand colors (Ember Orange `#FF8A3D`, Frost Cyan `#5CD6FF`, Snow White `#EEF1F7`, mid-node white), and glow halos.
- Usage rules (no recolor, no rotation, minimum size) belong in the brand's `rules/` atom, not in the `[logo]` section.

### CDN path

Logo SVGs are served alongside other brand assets:
```
https://brand-atoms.com/dist/brands/atom-family/1.0.0/assets/atom-family-icon.svg
https://brand-atoms.com/dist/brands/atom-family/1.0.0/assets/atom-family-wordmark.svg
```

These replace the interim 4-dot `mark.svg` currently in schema-atoms.

---

## Problem

The 25 *-atoms catalog sites each hardcode their own brand CSS. A color change requires 25 PRs. The sites are visually inconsistent — schema-atoms.com was recently aligned manually, but the other 24 have independent designs.

## Solution

Serve shared CSS from `brand-atoms.com/dist/brands/atom-family/1.0.0/`. Each catalog site links two URLs and removes its local brand code. A brand update in brand-atoms propagates to all 25 sites via a one-line URL bump.

---

## Brand Identity

`atom-family` is a distinct product brand — separate from the `convergent-systems` corporate brand — for the same reason JM Family's product brands (SET, SETF, JMA) are independent of the parent entity. The atoms ecosystem has its own visual identity (4-dot mark, Deep Space palette, Frost Cyan + Solar Gold accents) that should not be coupled to corporate brand changes.

**What this requires in brand-atoms:**
- A new brand atom at `brands/atom-family/1.0.0/brand.yaml` defining the `atom-family` palette, fonts, and mark
- The 4-dot mark, Deep Space/Snow/Cyan/Gold palette, and Inter + JetBrains Mono font stack formalized under this brand slug (not borrowed from `convergent-systems`)

---

## CDN URL Pattern

Follows the existing `brand-atoms.com/dist/brands/<brand>/<version>/` convention:

```html
<!-- Brand tokens — CSS custom properties (:root { --bg, --fg, --cyan, ... }) -->
<link rel="stylesheet"
      href="https://brand-atoms.com/dist/brands/atom-family/1.0.0/css/tokens.css" />

<!-- Catalog layout + component classes (.shell, .sidenav, .mark, .badge, .prose, ...) -->
<link rel="stylesheet"
      href="https://brand-atoms.com/dist/brands/atom-family/1.0.0/ui/atoms-catalog.css" />
```

SVG assets at the same path prefix:
```
/dist/brands/atom-family/1.0.0/assets/favicon.svg   — 32px 4-dot favicon
/dist/brands/atom-family/1.0.0/assets/mark.svg       — 120px hero mark
```

---

## File Contents

### `tokens.css`
Generated from `brand.yaml` by the existing brandatom toolchain. Contains `:root` CSS custom properties for light and dark modes:
```css
:root {
  --bg:          #07090F;
  --bg-surface:  #0B1020;
  --bg-elevated: #11182C;
  --fg:          #EEF1F7;
  --muted:       #A4ADBF;
  --subtle:      #7D8699;
  --cyan:        #5CD6FF;
  --cyan-soft:   #8DE4FF;
  --gold:        #F4C75E;
  --ember:       #FF8A3D;
  --border:      rgba(255,255,255,0.08);
  --border-strong: rgba(255,255,255,0.14);
  --font-sans:   "Inter", system-ui, sans-serif;
  --font-mono:   "JetBrains Mono", "Fira Code", monospace;
  /* brandDot1-4 for the 4-dot mark */
  --brandDot1:   #5CD6FF;
  --brandDot2:   #F4C75E;
  --brandDot3:   #FF8A3D;
  --brandDot4:   #EEF1F7;
}
```

### `atoms-catalog.css`
Hand-authored (not generated). Contains the shared layout and component classes used by all *-atoms catalog sites:

| Layer | Classes |
|---|---|
| Base | `*`, `html`, `body`, `a`, `a:hover`, `code`, `pre` |
| Layout | `.shell`, `.content`, `.sidenav` |
| Brand mark | `.mark`, `.dot`, `.dot-1`–`.dot-4` |
| Navigation | `.brand`, `.brand-text`, `.nav-link`, `.aside-meta`, `.meta-link` |
| Page | `.hero`, `.lede`, `.status`, `.status-dot` |
| Shared UI | `.breadcrumb`, `.badge` (with `.draft`, `.published`, `.historic` modifiers), `.section-label`, `.meta-table` |
| Prose | `.prose` (headings, paragraphs, tables, code, blockquote) |
| Responsive | `@media (max-width: 880px)` sidenav collapse |

All values reference `var(--*)` from `tokens.css`. No hardcoded colors.

---

## Version Pinning

- Catalog sites pin the full version in the URL: `atom-family/1.0.0/`
- Old versions remain permanently available (Cloudflare Pages immutable deploys)
- No `latest` alias — pinning is mandatory
- Version bump = update the version segment in the `<link>` URLs (one-line change per catalog site)

---

## Build + Deployment in brand-atoms

1. `atoms-catalog.css`, `favicon.svg`, and `mark.svg` are authored in `brand-atoms/web/public/dist/brands/atom-family/1.0.0/`
2. `tokens.css` is generated from `brand.yaml` by the brandatom CLI into the same directory
3. The existing Cloudflare Pages deploy serves everything under `web/public/` at `brand-atoms.com/`
4. No new CI job needed — the files land automatically with each brand-atoms deploy

---

## Migration Plan

**Step 1 — brand-atoms:** Create `brands/atom-family/1.0.0/brand.yaml`, author `atoms-catalog.css`, copy SVG assets, run brandatom CLI to emit `tokens.css`. Verify all four files are served at their CDN URLs.

**Step 2 — schema-atoms (reference implementation):** Replace `web/public/brand.css` and inline page styles with the two CDN `<link>` tags. Verify the site looks identical. This PR becomes the template for all other catalogs.

**Step 3 — remaining 24 catalogs:** One PR per catalog (or batched via `/spawn`) that removes local brand code and adds the two CDN links.

---

## What Does NOT Change

- Each catalog keeps its own Astro page structure, content logic, and routing
- Per-catalog class names and page-specific overrides stay in the catalog's own code
- The CDN owns only the visual layer — tokens, typography, layout grid, shared patterns
- Catalogs with React-based interactive components (brand-atoms, theme-atoms) keep their component CSS locally; only the shared shell/nav/mark/prose layer moves to the CDN
