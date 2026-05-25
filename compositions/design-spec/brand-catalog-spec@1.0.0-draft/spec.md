# Brand Catalog Specification

**Catalog:** `brand-atoms.com`
**Version:** 1.0.0-draft
**Conforms to:** `schema-atoms/design-spec/atom-spec@1.1.0`

## Purpose

The brand catalog holds structured brand identity artifacts — logos, color systems, typography systems, and design tokens that represent the visual and symbolic identity of an organization or product. Each atom encodes a brand element as a portable, versioned artifact so it can be referenced consistently across surfaces without duplication or drift.

Brand atoms are the authoritative source for design-level identity decisions. They express what a brand is at the asset and token level, leaving environment-specific rendering to theme atoms.

## Atom Classes

| Class | Description |
|---|---|
| `logo` | Logo asset definition including file references, safe zones, and usage constraints |
| `color-system` | Named color palette with semantic roles (primary, secondary, accent, surface, error) |
| `typography-system` | Font family, scale, weight, and usage rules for a brand's typographic identity |
| `design-token-set` | Platform-agnostic design tokens (spacing, radius, shadow, motion) for a brand |
| `brand-guidelines` | Prose and constraint specification for correct brand application across contexts |

## Consumers

- `theme-atoms` — theme atoms translate color-system and typography-system atoms into environment-specific rendering configurations
- Documentation systems — logo and brand-guideline atoms supply canonical assets for generated docs
- Web and mobile frontends — design-token-set and color-system atoms are compiled into platform-specific variables (CSS custom properties, Swift tokens, etc.)
- Marketing and design tooling — brand atoms serve as the single source of truth for Figma libraries, print systems, and motion design

## Relationship to Other Catalogs

- **theme-atoms:** brand atoms express the canonical design intent; theme atoms express how that intent is rendered in a specific environment (terminal, web, editor).
- **profile-atoms:** organization profiles may reference a brand atom to associate an identity with its visual system.
- **plugin-atoms:** brand-injection plugins apply brand atoms to surfaces that do not natively load them.
