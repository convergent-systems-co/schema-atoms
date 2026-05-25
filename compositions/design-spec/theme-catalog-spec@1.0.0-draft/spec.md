# Theme Catalog Specification

**Catalog:** `theme-atoms.com`
**Version:** 1.0.0-draft
**Conforms to:** `schema-atoms/design-spec/atom-spec@1.1.0`

## Purpose

The theme catalog holds structured definitions of visual and terminal themes — color palettes, typography scales, shell prompt styles, and syntax highlighting configurations. Each atom encodes a complete or partial theme as a portable artifact so it can be applied consistently across terminals, web surfaces, and development tools without drift.

Theme atoms are the authoritative source for the aesthetic layer of the ecosystem. They are distinct from brand atoms in that themes are environment-specific rendering configurations, while brand atoms express identity-level design decisions.

## Atom Classes

| Class | Description |
|---|---|
| `terminal-theme` | Complete terminal color scheme including foreground, background, and ANSI color definitions |
| `shell-prompt-theme` | Structured shell prompt configuration including segment definitions and glyphs |
| `syntax-theme` | Syntax highlighting color mappings for code editors and rendered code blocks |
| `web-color-scheme` | CSS custom property definitions for a light or dark web color scheme |

## Consumers

- `brand-atoms` — brand atoms may reference theme atoms to specify environment-appropriate renderings of brand colors
- Developer tooling — terminal emulators, editors, and shell frameworks consume theme atoms directly
- Documentation systems — web renderers apply web-color-scheme atoms for consistent code presentation
- Olympus CLI — the operator surface loads a terminal-theme atom for consistent output styling

## Relationship to Other Catalogs

- **brand-atoms:** brand atoms establish the canonical color system and identity; theme atoms translate that system into environment-specific rendering configurations.
- **profile-atoms:** user profiles may reference a preferred theme atom, enabling per-user theming without hardcoded preferences.
- **plugin-atoms:** theme-switching plugins may reference theme atoms as their configuration target.
