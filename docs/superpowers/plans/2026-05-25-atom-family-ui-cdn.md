# atom-family UI CDN Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Publish the `atom-family` product brand to brand-atoms.com and update schema-atoms to consume its CDN CSS/SVG instead of hardcoded local files.

**Architecture:** brand-atoms gains a new `atom-family` brand directory with `brand.yaml`, hand-authored `ui/atoms-catalog.css`, and SVG assets. `tools/build.ts` is extended to copy `assets/` and `ui/` subdirectories alongside emitter output. schema-atoms drops `web/public/brand.css` and links two CDN URLs.

**Tech Stack:** brand-atoms (TypeScript + Node, tsx, pnpm, Astro 6), schema-atoms (Astro 6), Cloudflare Pages

**Repos:**
- brand-atoms: `convergent-systems-co/brand-atoms` (clone locally before starting)
- schema-atoms: `/Users/itsfwcp/workspace/convergent-system-co/atoms/src/schema-atoms`

---

## File Map

### brand-atoms (new files)
| File | Purpose |
|---|---|
| `brands/atom-family/1.0.0/brand.yaml` | atom-family brand definition — palette refs, font refs, mark role |
| `brands/atom-family/1.0.0/assets/favicon.svg` | 32px 4-dot rounded-rect mark (replaces schema-atoms local copy) |
| `brands/atom-family/1.0.0/assets/mark.svg` | 120px hero mark with glow halos |
| `brands/atom-family/1.0.0/assets/atom-family-icon.svg` | Full molecular "A" logo, icon-only |
| `brands/atom-family/1.0.0/assets/atom-family-wordmark.svg` | Molecular "A" + "ATOMS" wordmark |
| `brands/atom-family/1.0.0/ui/atoms-catalog.css` | Shared layout + component CSS for all *-atoms catalog sites |
| `logo/atom-family-icon/1.0.0/atom.toml` | logo atom for the icon variant |
| `logo/atom-family-wordmark/1.0.0/atom.toml` | logo atom for the wordmark variant |

### brand-atoms (modified)
| File | Change |
|---|---|
| `tools/build.ts` | Add asset + ui directory copy after emitter loop |

### schema-atoms (modified)
| File | Change |
|---|---|
| `web/src/pages/index.astro` | Replace `<link href="/brand.css">` with two CDN links |
| `web/src/pages/[class]/index.astro` | Same |
| `web/src/pages/[class]/[slug]/index.astro` | Same |
| `web/src/pages/[class]/[slug]/[version]/index.astro` | Same |
| `web/public/favicon.svg` | Replace Astro logo with direct CDN `<link>` (or inline 4-dot SVG) |

### schema-atoms (deleted)
| File | Reason |
|---|---|
| `web/public/brand.css` | Replaced by CDN |
| `web/public/mark.svg` | Replaced by CDN |

---

## Task 1: Clone brand-atoms and verify build pipeline

**Files:** (none changed yet)

- [ ] **Step 1: Clone brand-atoms**

```bash
git clone https://github.com/convergent-systems-co/brand-atoms.git ~/workspace/convergent-system-co/brand-atoms
cd ~/workspace/convergent-system-co/brand-atoms
```

- [ ] **Step 2: Install dependencies**

```bash
pnpm install
```

- [ ] **Step 3: Run existing build and verify output**

```bash
pnpm build
ls dist/brands/convergent-systems/1.0.0/
```

Expected output includes: `css/  json/  scss/  tailwind/  w3c/  markdown/  figma/  swift/  kotlin/`

- [ ] **Step 4: Verify no existing atom-family brand**

```bash
ls brands/ | grep atom-family || echo "not found — correct"
```

---

## Task 2: Create the atom-family brand.yaml

**Files:** Create `brands/atom-family/1.0.0/brand.yaml`

The `atom-family` brand reuses the convergent-deep-space palette and inter font — it does NOT reference convergent-systems. It is a standalone product brand.

- [ ] **Step 1: Create directory**

```bash
mkdir -p brands/atom-family/1.0.0/assets brands/atom-family/1.0.0/ui
```

- [ ] **Step 2: Write brand.yaml**

Create `brands/atom-family/1.0.0/brand.yaml`:

```yaml
id: atom-family
version: 1.0.0
name: Atom Family
description: >
  The Atom Family is the product brand for the convergent-systems.co *-atoms
  catalog ecosystem. 25 catalog sites (schema-atoms, brand-atoms, theme-atoms,
  etc.) share this visual identity: the Deep Space canvas, molecular mark,
  Frost Cyan primary, Solar Gold accent, and Ember Orange warmth.

tags: [atom-family, atoms-ecosystem, dark-first]

provenance:
  source: https://convergent-systems.co
  license: MIT
  attribution: >
    Atom Family brand identity. Part of the convergent-systems.co atoms
    ecosystem. Trademarks and design rights belong to Convergent Systems Co.

references:
  palette: convergent-deep-space@1
  fonts:
    heading: inter@1
    body: inter@1

roles:
  colors:
    background: deep-space-0
    surface: deep-space-1
    surface-elevated: deep-space-2
    text-primary: snow-0
    text-secondary: snow-1
    text-tertiary: snow-2
    primary: frost-cyan
    primary-hover: frost-cyan-soft
    accent: solar-gold
    accent-hover: solar-gold-soft
    warning: ember-orange
    identity: frost-cyan
    on-identity: deep-space-0
    mark: solar-gold

assets:
  - id: favicon
    category: mark
    name: Favicon
    description: 32px 4-dot rounded-rect mark for browser tabs and app icons
    variants:
      - id: dark
        file: assets/favicon.svg
        colorScheme: dark
        format: svg

  - id: mark
    category: mark
    name: Hero Mark
    description: 120px 4-dot mark with glow halos for page heroes
    variants:
      - id: dark
        file: assets/mark.svg
        colorScheme: dark
        format: svg

  - id: atom-family-icon
    category: logo
    name: Atom Family Icon
    description: Molecular A-frame logo, icon-only variant
    variants:
      - id: dark
        file: assets/atom-family-icon.svg
        colorScheme: dark
        format: svg

  - id: atom-family-wordmark
    category: logo
    name: Atom Family Wordmark
    description: Molecular A-frame logo with ATOMS wordmark
    variants:
      - id: dark
        file: assets/atom-family-wordmark.svg
        colorScheme: dark
        format: svg
```

- [ ] **Step 3: Validate brand loads**

```bash
pnpm validate
```

Expected: no errors about atom-family/1.0.0

- [ ] **Step 4: Check brand resolves**

```bash
pnpm build --brand atom-family@1.0.0
ls dist/brands/atom-family/1.0.0/
```

Expected: css/ json/ scss/ (emitter outputs) — assets not yet (Task 4 fixes that)

- [ ] **Step 5: Commit**

```bash
git add brands/atom-family/
git commit -m "feat(brand): add atom-family brand definition"
```

---

## Task 3: Create SVG assets

**Files:** Create 4 SVG files in `brands/atom-family/1.0.0/assets/`

The 4-dot favicon and mark follow the existing schema-atoms design. The molecular A logo is recreated from the approved PNG source using SVG gradients and paths.

- [ ] **Step 1: Create favicon.svg (32px 4-dot mark)**

Create `brands/atom-family/1.0.0/assets/favicon.svg`:

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">
  <rect width="32" height="32" rx="8" fill="#0B1020"/>
  <circle cx="10" cy="10" r="4" fill="#5CD6FF"/>
  <circle cx="22" cy="10" r="4" fill="#F4C75E"/>
  <circle cx="10" cy="22" r="4" fill="#FF8A3D"/>
  <circle cx="22" cy="22" r="4" fill="#EEF1F7"/>
</svg>
```

- [ ] **Step 2: Create mark.svg (120px hero with glow)**

Create `brands/atom-family/1.0.0/assets/mark.svg`:

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 120 120" width="120" height="120">
  <defs>
    <radialGradient id="g-cyan" cx="50%" cy="50%" r="50%">
      <stop offset="0%" stop-color="#5CD6FF" stop-opacity="0.3"/>
      <stop offset="100%" stop-color="#5CD6FF" stop-opacity="0"/>
    </radialGradient>
    <radialGradient id="g-gold" cx="50%" cy="50%" r="50%">
      <stop offset="0%" stop-color="#F4C75E" stop-opacity="0.3"/>
      <stop offset="100%" stop-color="#F4C75E" stop-opacity="0"/>
    </radialGradient>
    <radialGradient id="g-ember" cx="50%" cy="50%" r="50%">
      <stop offset="0%" stop-color="#FF8A3D" stop-opacity="0.3"/>
      <stop offset="100%" stop-color="#FF8A3D" stop-opacity="0"/>
    </radialGradient>
  </defs>
  <rect width="120" height="120" rx="28" fill="#0B1020"/>
  <circle cx="37" cy="37" r="28" fill="url(#g-cyan)"/>
  <circle cx="83" cy="37" r="28" fill="url(#g-gold)"/>
  <circle cx="37" cy="83" r="28" fill="url(#g-ember)"/>
  <circle cx="83" cy="83" r="28" fill="url(#g-cyan)" opacity="0.4"/>
  <circle cx="37" cy="37" r="16" fill="#5CD6FF"/>
  <circle cx="83" cy="37" r="16" fill="#F4C75E"/>
  <circle cx="37" cy="83" r="16" fill="#FF8A3D"/>
  <circle cx="83" cy="83" r="16" fill="#EEF1F7"/>
</svg>
```

- [ ] **Step 3: Create atom-family-icon.svg (molecular A logo)**

This recreates the approved molecular A-frame logo from the PNG source. The structure: an A-shaped frame of 3D-rendered white/silver tubes connecting 4 glowing spheres (blue top, white center-crossbar, orange bottom-left, cyan bottom-right).

Create `brands/atom-family/1.0.0/assets/atom-family-icon.svg`:

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 400 400">
  <defs>
    <!-- Sphere gradients for 3D effect -->
    <radialGradient id="s-blue" cx="38%" cy="32%" r="60%">
      <stop offset="0%" stop-color="#9ad8ff"/>
      <stop offset="40%" stop-color="#3b9fd4"/>
      <stop offset="100%" stop-color="#0a4a7a"/>
    </radialGradient>
    <radialGradient id="s-white" cx="38%" cy="32%" r="60%">
      <stop offset="0%" stop-color="#ffffff"/>
      <stop offset="50%" stop-color="#c8d0dc"/>
      <stop offset="100%" stop-color="#7a8090"/>
    </radialGradient>
    <radialGradient id="s-orange" cx="38%" cy="32%" r="60%">
      <stop offset="0%" stop-color="#ffcc88"/>
      <stop offset="40%" stop-color="#e87020"/>
      <stop offset="100%" stop-color="#7a2800"/>
    </radialGradient>
    <radialGradient id="s-cyan" cx="38%" cy="32%" r="60%">
      <stop offset="0%" stop-color="#aaeeff"/>
      <stop offset="40%" stop-color="#3aaedd"/>
      <stop offset="100%" stop-color="#0a4a6a"/>
    </radialGradient>
    <!-- Tube gradient (silver/white) -->
    <linearGradient id="tube-h" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" stop-color="#f0f0f0"/>
      <stop offset="40%" stop-color="#d0d4da"/>
      <stop offset="100%" stop-color="#8890a0"/>
    </linearGradient>
    <!-- Glow filters -->
    <filter id="glow-blue" x="-50%" y="-50%" width="200%" height="200%">
      <feGaussianBlur stdDeviation="8" result="blur"/>
      <feComposite in="SourceGraphic" in2="blur" operator="over"/>
    </filter>
    <filter id="glow-orange" x="-50%" y="-50%" width="200%" height="200%">
      <feGaussianBlur stdDeviation="10" result="blur"/>
      <feComposite in="SourceGraphic" in2="blur" operator="over"/>
    </filter>
    <filter id="glow-cyan" x="-50%" y="-50%" width="200%" height="200%">
      <feGaussianBlur stdDeviation="8" result="blur"/>
      <feComposite in="SourceGraphic" in2="blur" operator="over"/>
    </filter>
  </defs>

  <!-- Background -->
  <rect width="400" height="400" fill="#000000"/>

  <!-- A-frame tubes: left arm (orange-bottom to white-center) -->
  <line x1="80" y1="310" x2="200" y2="220" stroke="url(#tube-h)" stroke-width="22" stroke-linecap="round"/>
  <!-- Right arm (white-center to cyan-bottom) -->
  <line x1="200" y1="220" x2="320" y2="310" stroke="url(#tube-h)" stroke-width="22" stroke-linecap="round"/>
  <!-- Left upper arm (white-center to blue-top) -->
  <line x1="200" y1="220" x2="135" y2="95" stroke="url(#tube-h)" stroke-width="22" stroke-linecap="round"/>
  <!-- Right upper arm (white-center to blue-top via right) -->
  <line x1="200" y1="220" x2="265" y2="95" stroke="url(#tube-h)" stroke-width="22" stroke-linecap="round"/>

  <!-- Glow halos -->
  <circle cx="200" cy="80" r="48" fill="#2255cc" opacity="0.35" filter="url(#glow-blue)"/>
  <circle cx="80" cy="310" r="48" fill="#cc5500" opacity="0.4" filter="url(#glow-orange)"/>
  <circle cx="320" cy="310" r="48" fill="#0088cc" opacity="0.35" filter="url(#glow-cyan)"/>

  <!-- Spheres (on top of tubes) -->
  <!-- Blue top -->
  <circle cx="200" cy="80" r="40" fill="url(#s-blue)"/>
  <!-- White center (crossbar junction) -->
  <circle cx="200" cy="220" r="30" fill="url(#s-white)"/>
  <!-- Orange bottom-left -->
  <circle cx="80" cy="310" r="38" fill="url(#s-orange)"/>
  <!-- Cyan bottom-right -->
  <circle cx="320" cy="310" r="38" fill="url(#s-cyan)"/>
</svg>
```

- [ ] **Step 4: Create atom-family-wordmark.svg (icon + ATOMS text)**

Create `brands/atom-family/1.0.0/assets/atom-family-wordmark.svg`:

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 600 480">
  <defs>
    <radialGradient id="sw-blue" cx="38%" cy="32%" r="60%">
      <stop offset="0%" stop-color="#9ad8ff"/>
      <stop offset="40%" stop-color="#3b9fd4"/>
      <stop offset="100%" stop-color="#0a4a7a"/>
    </radialGradient>
    <radialGradient id="sw-white" cx="38%" cy="32%" r="60%">
      <stop offset="0%" stop-color="#ffffff"/>
      <stop offset="50%" stop-color="#c8d0dc"/>
      <stop offset="100%" stop-color="#7a8090"/>
    </radialGradient>
    <radialGradient id="sw-orange" cx="38%" cy="32%" r="60%">
      <stop offset="0%" stop-color="#ffcc88"/>
      <stop offset="40%" stop-color="#e87020"/>
      <stop offset="100%" stop-color="#7a2800"/>
    </radialGradient>
    <radialGradient id="sw-cyan" cx="38%" cy="32%" r="60%">
      <stop offset="0%" stop-color="#aaeeff"/>
      <stop offset="40%" stop-color="#3aaedd"/>
      <stop offset="100%" stop-color="#0a4a6a"/>
    </radialGradient>
    <linearGradient id="sw-tube" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" stop-color="#f0f0f0"/>
      <stop offset="40%" stop-color="#d0d4da"/>
      <stop offset="100%" stop-color="#8890a0"/>
    </linearGradient>
  </defs>

  <rect width="600" height="480" fill="#000000"/>

  <!-- Icon (scaled down and centered horizontally) -->
  <g transform="translate(100, 20) scale(0.8)">
    <line x1="80" y1="310" x2="200" y2="220" stroke="url(#sw-tube)" stroke-width="22" stroke-linecap="round"/>
    <line x1="200" y1="220" x2="320" y2="310" stroke="url(#sw-tube)" stroke-width="22" stroke-linecap="round"/>
    <line x1="200" y1="220" x2="135" y2="95" stroke="url(#sw-tube)" stroke-width="22" stroke-linecap="round"/>
    <line x1="200" y1="220" x2="265" y2="95" stroke="url(#sw-tube)" stroke-width="22" stroke-linecap="round"/>
    <circle cx="200" cy="80" r="40" fill="url(#sw-blue)"/>
    <circle cx="200" cy="220" r="30" fill="url(#sw-white)"/>
    <circle cx="80" cy="310" r="38" fill="url(#sw-orange)"/>
    <circle cx="320" cy="310" r="38" fill="url(#sw-cyan)"/>
  </g>

  <!-- ATOMS wordmark -->
  <text
    x="300" y="430"
    font-family="Inter, -apple-system, BlinkMacSystemFont, sans-serif"
    font-weight="300"
    font-size="72"
    fill="#ffffff"
    letter-spacing="18"
    text-anchor="middle"
  >ATOMS</text>
</svg>
```

- [ ] **Step 5: Verify SVG files are valid**

```bash
for f in brands/atom-family/1.0.0/assets/*.svg; do
  python3 -c "import xml.etree.ElementTree as ET; ET.parse('$f'); print('OK:', '$f')"
done
```

Expected: `OK: brands/atom-family/1.0.0/assets/favicon.svg` (×4)

- [ ] **Step 6: Commit**

```bash
git add brands/atom-family/1.0.0/assets/
git commit -m "feat(brand): add atom-family SVG assets — favicon, mark, icon, wordmark"
```

---

## Task 4: Author atoms-catalog.css

**Files:** Create `brands/atom-family/1.0.0/ui/atoms-catalog.css`

This is the shared CSS that all *-atoms catalog sites will link. It uses `var(--*)` references resolved by `tokens.css`.

- [ ] **Step 1: Create atoms-catalog.css**

Create `brands/atom-family/1.0.0/ui/atoms-catalog.css`:

```css
/* atoms-catalog.css — Shared layout and component system for *-atoms catalog sites.
 * Requires: tokens.css loaded first (provides CSS custom properties).
 * Version: atom-family@1.0.0
 * Do not edit inline — update in brand-atoms and bump the version.
 */

@import url('https://fonts.googleapis.com/css2?family=Inter:ital,opsz,wght@0,14..32,100..900;1,14..32,100..900&display=swap');

/* ── Base ─────────────────────────────────────────────────────────── */

* { box-sizing: border-box; }

html, body {
  margin: 0;
  padding: 0;
  background: var(--color-role-background, #07090F);
  color: var(--color-role-text-primary, #EEF1F7);
}

body {
  font-family: var(--font-body, "Inter", system-ui, sans-serif);
  font-size: 1.05rem;
  line-height: 1.65;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

a {
  color: var(--color-role-primary, #5CD6FF);
  text-decoration: none;
}
a:hover {
  color: var(--color-role-primary-hover, #8DE4FF);
  text-decoration: underline;
}

code {
  font-family: "JetBrains Mono", "Fira Code", ui-monospace, monospace;
  background: var(--color-role-surface-elevated, #11182C);
  border: 1px solid rgba(255,255,255,0.08);
  padding: 0.15em 0.45em;
  border-radius: 3px;
  font-size: 0.875em;
}

pre {
  font-family: "JetBrains Mono", "Fira Code", ui-monospace, monospace;
  background: var(--color-role-surface, #0B1020);
  border: 1px solid rgba(255,255,255,0.08);
  border-radius: 6px;
  padding: 1.25rem;
  overflow-x: auto;
  line-height: 1.55;
}
pre code { background: none; border: none; padding: 0; font-size: 0.875rem; }

/* ── Shell layout ─────────────────────────────────────────────────── */

.shell {
  display: grid;
  grid-template-columns: 1fr 220px;
  min-height: 100vh;
  max-width: 1320px;
  margin: 0 auto;
}

.content {
  min-width: 0;
  padding: 32px;
}

.sidenav {
  position: sticky;
  top: 0;
  height: 100vh;
  padding: 32px 24px;
  border-left: 1px solid rgba(255,255,255,0.08);
  display: flex;
  flex-direction: column;
  gap: 32px;
  overflow-y: auto;
}

/* ── Brand mark (2×2 dot grid) ────────────────────────────────────── */

.mark {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 3px;
  width: 32px;
  height: 32px;
  padding: 5px;
  background: var(--color-role-surface, #0B1020);
  border-radius: 8px;
  flex-shrink: 0;
}

.dot {
  width: 100%;
  height: 100%;
  border-radius: 50%;
}

.dot-1 { background: var(--brand-color-mark, #5CD6FF); }
.dot-2 { background: var(--color-role-accent, #F4C75E); }
.dot-3 { background: var(--color-role-warning, #FF8A3D); }
.dot-4 { background: var(--color-role-text-primary, #EEF1F7); }

/* ── Navigation ───────────────────────────────────────────────────── */

.brand {
  display: inline-flex;
  align-items: center;
  gap: 12px;
  text-decoration: none;
  color: var(--color-role-text-primary, #EEF1F7);
}
.brand:hover { text-decoration: none; color: var(--color-role-text-primary, #EEF1F7); }

.brand-text {
  font-weight: 800;
  font-size: 15px;
  letter-spacing: -0.02em;
  line-height: 1.1;
}

.nav-link {
  display: block;
  padding: 7px 10px;
  border-radius: 6px;
  color: var(--color-role-text-secondary, #A4ADBF);
  text-decoration: none;
  font-size: 13px;
  font-weight: 500;
  transition: background 0.12s ease, color 0.12s ease;
}
.nav-link:hover {
  background: var(--color-role-surface, #0B1020);
  color: var(--color-role-text-primary, #EEF1F7);
  text-decoration: none;
}
.nav-link.active {
  background: var(--color-role-surface, #0B1020);
  color: var(--color-role-primary, #5CD6FF);
  font-weight: 600;
}

.aside-meta {
  margin-top: auto;
  padding-top: 16px;
  border-top: 1px solid rgba(255,255,255,0.08);
}

.meta-link {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  color: var(--color-role-text-tertiary, #7D8699);
  font-family: "JetBrains Mono", "Fira Code", ui-monospace, monospace;
  font-size: 11px;
  text-decoration: none;
}
.meta-link:hover { color: var(--color-role-primary, #5CD6FF); }

/* ── Page sections ────────────────────────────────────────────────── */

.hero { padding: 48px 0 40px; max-width: 680px; }

.lede {
  font-size: 1.05rem;
  color: var(--color-role-text-secondary, #A4ADBF);
  margin: 0 0 20px;
  max-width: 520px;
  line-height: 1.6;
}

.status {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  font-size: 12px;
  font-family: "JetBrains Mono", "Fira Code", ui-monospace, monospace;
  color: var(--color-role-text-tertiary, #7D8699);
  background: var(--color-role-surface, #0B1020);
  padding: 7px 14px;
  border-radius: 999px;
}

.status-dot {
  width: 7px;
  height: 7px;
  background: var(--color-role-primary, #5CD6FF);
  border-radius: 50%;
  animation: af-pulse 2.4s ease-in-out infinite;
}

@keyframes af-pulse {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.3; }
}

/* ── Shared UI patterns ───────────────────────────────────────────── */

.breadcrumb {
  color: var(--color-role-text-tertiary, #7D8699);
  font-size: 0.8rem;
  margin-bottom: 1.75rem;
}
.breadcrumb a { color: var(--color-role-primary, #5CD6FF); }
.breadcrumb a:hover { color: var(--color-role-primary-hover, #8DE4FF); }

.badge {
  display: inline-block;
  background: var(--color-role-surface-elevated, #11182C);
  border: 1px solid rgba(255,255,255,0.08);
  border-radius: 3px;
  padding: 0.2em 0.6em;
  font-size: 0.75rem;
  font-family: "JetBrains Mono", "Fira Code", ui-monospace, monospace;
  color: var(--color-role-text-secondary, #A4ADBF);
}
.badge.draft   { border-color: rgba(244,199,94,0.3); color: var(--color-role-accent, #F4C75E); }
.badge.published { border-color: rgba(92,214,255,0.3); color: var(--color-role-primary, #5CD6FF); }
.badge.adopted  { border-color: rgba(92,214,255,0.4); color: var(--color-role-primary-hover, #8DE4FF); }
.badge.historic { border-color: rgba(255,255,255,0.08); color: var(--color-role-text-tertiary, #7D8699); }

.section-label {
  font-size: 0.68rem;
  font-weight: 700;
  letter-spacing: 0.32em;
  text-transform: uppercase;
  color: var(--color-role-text-tertiary, #7D8699);
  margin: 0 0 12px;
}

.meta-table {
  width: 100%;
  border-collapse: collapse;
  margin-bottom: 2rem;
  font-size: 0.85rem;
}
.meta-table td {
  padding: 0.4rem 0;
  vertical-align: top;
  border-bottom: 1px solid rgba(255,255,255,0.08);
}
.meta-table tr:last-child td { border-bottom: none; }
.meta-table td:first-child {
  color: var(--color-role-text-tertiary, #7D8699);
  width: 7rem;
  padding-right: 1rem;
  font-family: "JetBrains Mono", "Fira Code", ui-monospace, monospace;
  font-size: 0.8rem;
}

/* ── Prose (markdown rendering) ───────────────────────────────────── */

.prose { color: var(--color-role-text-primary, #EEF1F7); }
.prose h1, .prose h2, .prose h3, .prose h4 {
  font-weight: 700;
  letter-spacing: -0.02em;
  margin: 2rem 0 0.75rem;
  color: var(--color-role-text-primary, #EEF1F7);
}
.prose h1 { font-size: 1.6rem; }
.prose h2 {
  font-size: 1.25rem;
  border-bottom: 1px solid rgba(255,255,255,0.08);
  padding-bottom: 0.4rem;
}
.prose h3 { font-size: 1.05rem; }
.prose p { margin: 0 0 1rem; }
.prose ul, .prose ol { padding-left: 1.5rem; margin: 0 0 1rem; }
.prose li { margin-bottom: 0.3rem; }
.prose a { color: var(--color-role-primary, #5CD6FF); }
.prose a:hover { color: var(--color-role-primary-hover, #8DE4FF); }
.prose blockquote {
  border-left: 3px solid var(--color-role-accent, #F4C75E);
  margin: 0 0 1rem;
  padding: 0.5rem 1rem;
  background: var(--color-role-surface, #0B1020);
  color: var(--color-role-text-secondary, #A4ADBF);
}
.prose table { width: 100%; border-collapse: collapse; margin: 0 0 1rem; font-size: 0.875rem; }
.prose th {
  background: var(--color-role-surface-elevated, #11182C);
  padding: 0.5rem 0.75rem;
  text-align: left;
  border: 1px solid rgba(255,255,255,0.08);
  color: var(--color-role-text-tertiary, #7D8699);
  font-weight: 600;
  font-size: 0.75rem;
  letter-spacing: 0.04em;
  text-transform: uppercase;
}
.prose td {
  padding: 0.5rem 0.75rem;
  border: 1px solid rgba(255,255,255,0.08);
}

/* ── Responsive ───────────────────────────────────────────────────── */

@media (max-width: 880px) {
  .shell { grid-template-columns: 1fr; }
  .sidenav {
    position: static;
    height: auto;
    border-left: none;
    border-bottom: 1px solid rgba(255,255,255,0.08);
    flex-direction: row;
    align-items: center;
    padding: 16px 24px;
    gap: 20px;
    overflow-y: visible;
  }
  .aside-meta { display: none; }
  .content { padding: 24px; }
}
```

- [ ] **Step 2: Commit**

```bash
git add brands/atom-family/1.0.0/ui/
git commit -m "feat(brand): add atoms-catalog.css shared layout system"
```

---

## Task 5: Extend build.ts to copy assets/ and ui/ directories

**Files:** Modify `tools/build.ts`

The existing build loop only runs emitters. Add a step after the emitter loop to copy the brand's `assets/` and `ui/` directories (if they exist) into the dist output.

- [ ] **Step 1: Add cpSync import and asset copy to build.ts**

In `tools/build.ts`, add `cpSync` to the fs import at line 2:

```typescript
import { cpSync, existsSync, mkdirSync, writeFileSync } from 'node:fs';
```

After the emitter loop (after the `writtenFiles` loop, before the `totalBrands++` line), add:

```typescript
    // Copy static subdirectories (assets/, ui/) from the brand source directory.
    // These contain hand-authored files not produced by emitters.
    const brandSourceDir = wantedBrands.find(
      (b) => b.slug === resolved.id && b.version === resolved.version
    )?.versionDir;

    if (brandSourceDir) {
      for (const staticSubdir of ['assets', 'ui']) {
        const srcDir = join(brandSourceDir, staticSubdir);
        if (existsSync(srcDir)) {
          const destDir = join(brandOutDir, staticSubdir);
          mkdirSync(destDir, { recursive: true });
          cpSync(srcDir, destDir, { recursive: true });
          writtenFiles.push(`${staticSubdir}/ (static copy)`);
        }
      }
    }
```

The `BrandRecord` type already has a `versionDir` field (confirmed in `loader.ts`). The `wantedBrands` array contains `BrandRecord` objects. The `resolveBrand` call returns `resolved` with `resolved.id` matching `b.slug`.

- [ ] **Step 2: Run build and verify assets appear in dist**

```bash
pnpm build --brand atom-family@1.0.0
ls dist/brands/atom-family/1.0.0/
```

Expected: `assets/  css/  figma/  json/  kotlin/  markdown/  scss/  swift/  tailwind/  ui/  w3c/`

```bash
ls dist/brands/atom-family/1.0.0/assets/
```

Expected: `atom-family-icon.svg  atom-family-wordmark.svg  favicon.svg  mark.svg`

```bash
ls dist/brands/atom-family/1.0.0/ui/
```

Expected: `atoms-catalog.css`

- [ ] **Step 3: Run tests to make sure nothing broke**

```bash
pnpm test
```

Expected: all pass

- [ ] **Step 4: Verify convergent-systems brand still builds correctly**

```bash
pnpm build --brand convergent-systems@1.0.0
ls dist/brands/convergent-systems/1.0.0/
```

Expected: same as before (css/ json/ scss/ etc.) — no crash if there's no assets/ dir in that brand

- [ ] **Step 5: Commit**

```bash
git add tools/build.ts
git commit -m "feat(build): copy assets/ and ui/ static subdirs alongside emitter output"
```

---

## Task 6: Create logo atom files in brand-atoms

**Files:** Create `logo/atom-family-icon/1.0.0/atom.toml` and `logo/atom-family-wordmark/1.0.0/atom.toml`

- [ ] **Step 1: Create directories**

```bash
mkdir -p logo/atom-family-icon/1.0.0
mkdir -p logo/atom-family-wordmark/1.0.0
```

- [ ] **Step 2: Create icon atom.toml**

Create `logo/atom-family-icon/1.0.0/atom.toml`:

```toml
id          = "brand-atoms/logo/atom-family-icon"
version     = "1.0.0"
content_hash = ""
lifecycle   = "draft"
created_at  = "2026-05-25T00:00:00Z"

[logo]
brand        = "atom-family"
variant      = "icon"
theme        = "dark"
format       = "svg"
asset        = "atom-family-icon.svg"
```

- [ ] **Step 3: Copy asset into logo atom directory**

```bash
cp brands/atom-family/1.0.0/assets/atom-family-icon.svg logo/atom-family-icon/1.0.0/
```

- [ ] **Step 4: Create wordmark atom.toml**

Create `logo/atom-family-wordmark/1.0.0/atom.toml`:

```toml
id          = "brand-atoms/logo/atom-family-wordmark"
version     = "1.0.0"
content_hash = ""
lifecycle   = "draft"
created_at  = "2026-05-25T00:00:00Z"

[logo]
brand        = "atom-family"
variant      = "wordmark"
theme        = "dark"
format       = "svg"
asset        = "atom-family-wordmark.svg"
```

- [ ] **Step 5: Copy asset**

```bash
cp brands/atom-family/1.0.0/assets/atom-family-wordmark.svg logo/atom-family-wordmark/1.0.0/
```

- [ ] **Step 6: Commit**

```bash
git add logo/
git commit -m "feat(logo): add atom-family-icon and atom-family-wordmark logo atoms"
```

---

## Task 7: Deploy brand-atoms and verify CDN URLs

- [ ] **Step 1: Open PR against main**

```bash
git push origin HEAD
gh pr create --repo convergent-systems-co/brand-atoms \
  --title "feat: add atom-family brand — CDN assets, atoms-catalog.css, logo atoms" \
  --body "Adds the atom-family product brand to the encyclopedia. Includes favicon, mark, molecular A logo, wordmark, shared atoms-catalog.css layout system, and two logo atoms. Extends build.ts to copy assets/ and ui/ dirs alongside emitter output."
```

- [ ] **Step 2: Merge PR and wait for deploy**

Merge the PR via GitHub UI or:
```bash
gh pr merge --merge --delete-branch
```

Wait for the Cloudflare Pages deploy (watch the Actions tab or `gh run watch`).

- [ ] **Step 3: Verify all CDN URLs return 200**

```bash
for url in \
  "https://brand-atoms.com/dist/brands/atom-family/1.0.0/css/tokens.css" \
  "https://brand-atoms.com/dist/brands/atom-family/1.0.0/ui/atoms-catalog.css" \
  "https://brand-atoms.com/dist/brands/atom-family/1.0.0/assets/favicon.svg" \
  "https://brand-atoms.com/dist/brands/atom-family/1.0.0/assets/mark.svg" \
  "https://brand-atoms.com/dist/brands/atom-family/1.0.0/assets/atom-family-icon.svg" \
  "https://brand-atoms.com/dist/brands/atom-family/1.0.0/assets/atom-family-wordmark.svg"; do
  status=$(curl -s -o /dev/null -w "%{http_code}" "$url")
  echo "$status  $url"
done
```

Expected: all `200`

- [ ] **Step 4: Verify tokens.css contains expected variables**

```bash
curl -s https://brand-atoms.com/dist/brands/atom-family/1.0.0/css/tokens.css | grep -E 'frost-cyan|solar-gold|deep-space' | head -5
```

Expected: CSS custom property lines for the atom-family palette

---

## Task 8: Migrate schema-atoms to CDN

**Repo:** `/Users/itsfwcp/workspace/convergent-system-co/atoms/src/schema-atoms`

Work on a feature branch.

- [ ] **Step 1: Create worktree**

```bash
cd /Users/itsfwcp/workspace/convergent-system-co/atoms/src/schema-atoms
git fetch origin main
git worktree add .worktrees/feat/cdn-migration -b feat/atom-family-cdn main
git -C .worktrees/feat/cdn-migration reset --hard origin/main
```

- [ ] **Step 2: Update index.astro — replace local brand.css with CDN links**

In `.worktrees/feat/cdn-migration/web/src/pages/index.astro`, replace:
```html
    <link rel="icon" type="image/svg+xml" href="/favicon.svg" />
    <link rel="stylesheet" href="/brand.css" />
```
with:
```html
    <link rel="icon" type="image/svg+xml" href="https://brand-atoms.com/dist/brands/atom-family/1.0.0/assets/favicon.svg" />
    <link rel="preconnect" href="https://brand-atoms.com" />
    <link rel="stylesheet" href="https://brand-atoms.com/dist/brands/atom-family/1.0.0/css/tokens.css" />
    <link rel="stylesheet" href="https://brand-atoms.com/dist/brands/atom-family/1.0.0/ui/atoms-catalog.css" />
```

Also update inline CSS in `<style>` to remove any CSS custom property declarations that duplicate `tokens.css` (colors, fonts). Keep only page-specific layout styles.

- [ ] **Step 3: Update [class]/index.astro with same CDN links**

Apply the identical `<link>` change to:
- `web/src/pages/[class]/index.astro`
- `web/src/pages/[class]/[slug]/index.astro`
- `web/src/pages/[class]/[slug]/[version]/index.astro`

In each file: remove the `<link href="/brand.css">` line and add the three CDN links. Remove any duplicated CSS custom property `:root` blocks from inline `<style>` tags.

- [ ] **Step 4: Delete local brand files**

```bash
rm .worktrees/feat/cdn-migration/web/public/brand.css
rm .worktrees/feat/cdn-migration/web/public/mark.svg
```

- [ ] **Step 5: Update mark image reference in index.astro**

In `web/src/pages/index.astro`, find:
```html
<img src="/mark.svg" alt="schema-atoms mark" class="hero-mark" />
```
Replace with:
```html
<img src="https://brand-atoms.com/dist/brands/atom-family/1.0.0/assets/atom-family-icon.svg" alt="atom-family mark" class="hero-mark" />
```

- [ ] **Step 6: Build and verify**

```bash
cd .worktrees/feat/cdn-migration/web
npm ci
npm run build
```

Expected: builds clean, 65 pages

- [ ] **Step 7: Quick visual smoke test**

```bash
npm run preview &
sleep 2
curl -s http://localhost:4321 | grep -c 'brand-atoms.com'
```

Expected: count > 0 (CDN links are in the HTML)

Kill the preview server: `kill %1`

- [ ] **Step 8: Commit**

```bash
git -C /Users/itsfwcp/workspace/convergent-system-co/atoms/src/schema-atoms/.worktrees/feat/cdn-migration add web/src/pages/ web/public/
git -C /Users/itsfwcp/workspace/convergent-system-co/atoms/src/schema-atoms/.worktrees/feat/cdn-migration commit -m "feat(web): migrate to atom-family CDN — replace local brand.css with CDN links

Removes web/public/brand.css and web/public/mark.svg.
All 4 page templates now load tokens + layout CSS from:
  brand-atoms.com/dist/brands/atom-family/1.0.0/css/tokens.css
  brand-atoms.com/dist/brands/atom-family/1.0.0/ui/atoms-catalog.css
Favicon and mark also served from CDN."
```

- [ ] **Step 9: Push and open PR**

```bash
git -C /Users/itsfwcp/workspace/convergent-system-co/atoms/src/schema-atoms/.worktrees/feat/cdn-migration push -u origin feat/atom-family-cdn
gh pr create --repo convergent-systems-co/schema-atoms \
  --title "feat(web): migrate to atom-family CDN brand" \
  --body "Removes hardcoded brand.css. All 4 page templates load from brand-atoms.com/dist/brands/atom-family/1.0.0/. This is the reference migration for the other 24 catalog sites." \
  --head feat/atom-family-cdn
```

- [ ] **Step 10: Merge and tag v0.4.0**

```bash
gh pr merge --repo convergent-systems-co/schema-atoms <PR-number> --merge --admin
git fetch origin main
git tag v0.4.0 origin/main
git push origin v0.4.0
git -C /Users/itsfwcp/workspace/convergent-system-co/atoms/src/schema-atoms worktree remove .worktrees/feat/cdn-migration --force
```

---

## Verification Checklist

After both PRs merge and deploy:

- [ ] `https://brand-atoms.com/dist/brands/atom-family/1.0.0/css/tokens.css` returns `200` with CSS content
- [ ] `https://brand-atoms.com/dist/brands/atom-family/1.0.0/ui/atoms-catalog.css` returns `200`
- [ ] `https://brand-atoms.com/dist/brands/atom-family/1.0.0/assets/atom-family-icon.svg` returns `200`
- [ ] `https://schema-atoms.com` loads with correct brand (Deep Space background, 4-dot/molecular mark)
- [ ] `https://schema-atoms.com` page source contains `brand-atoms.com/dist/brands/atom-family/1.0.0/` links
- [ ] No local `/brand.css` reference remains in schema-atoms HTML output
