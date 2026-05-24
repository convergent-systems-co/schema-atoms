# Plan: Issue #122 — Astro URL Routes for per-class/per-atom/per-version

**Status:** plan-ready  
**TL:** TL-4  
**Date:** 2026-05-23  
**Branch:** feat/task-122-url-routes

## Objective

Implement the four URL patterns from spec Part VI as static Astro routes, reading compositions/ at build time. All 24 class dirs are currently empty — routes must handle zero atoms gracefully.

## Alternatives Table

| Alternative | Pros | Cons | Verdict |
|---|---|---|---|
| Hardcode 24 class names in catalog.ts | Simple, no yaml parser dependency | Fragile if ATOMS.yml class list changes | Chosen — matches issue instruction, no yaml dep needed for MVP |
| Read ATOMS.yml at build time via js-yaml | Single source of truth | Adds a devDependency, more complex | Rejected for MVP; can be revisited |
| SSR / server-side rendering | Dynamic, always fresh | Contradicts `output: 'static'` in astro.config.mjs | Rejected |

## Scope

**Files to create:**
- `web/src/lib/catalog.ts` — enumerates 24 classes and .toml files from compositions/
- `web/src/pages/[class]/index.astro` — class index page
- `web/src/pages/[class]/[slug]/index.astro` — atom slug / version history
- `web/src/pages/[class]/[slug]/[version]/index.astro` — atom version landing page

**Files NOT touched:**
- `web/src/pages/index.astro`
- Any existing pages

## Approach

1. Create `web/src/lib/` directory
2. Write `catalog.ts` with `ATOM_CLASSES` const array (24 names) and `getAtomsForClass()` that reads `../compositions/<class>/` for .toml files, returning `[]` if dir is empty or missing
3. Write `[class]/index.astro` — `getStaticPaths()` maps ATOM_CLASSES → params, renders list or "No atoms published yet"
4. Write `[class]/[slug]/index.astro` — `getStaticPaths()` flatMaps classes → atoms → slug params (returns empty array when all classes empty)
5. Write `[class]/[slug]/[version]/index.astro` — same pattern, parses version from .toml filename
6. Run `cd web && npm run check` — fix any TypeScript errors
7. Run `cd web && npm run build` — verify static generation succeeds with empty compositions/

## Testing Strategy

- TDD script: verify files exist and contain `getStaticPaths`
- `npm run check` — TypeScript clean
- `npm run build` — succeeds, proving empty-class handling works

## Risk Assessment

| Risk | Mitigation |
|---|---|
| process.cwd() wrong when Astro builds from web/ | Use `fileURLToPath(import.meta.url)` + relative path OR `join(process.cwd(), '..', 'compositions')` — test both via build |
| [slug] and [version] dynamic routes with empty paths cause Astro build errors | Return `[]` from getStaticPaths() — Astro handles empty arrays cleanly |
| TypeScript strict mode rejects `Astro.params.class` (reserved word) | Destructure as `{ class: atomClass }` |

## Dependencies

- None blocking. PRs #125/#126 already merged (compositions/ structure in place).

## Backward Compatibility

- No existing routes changed. Pure addition.
