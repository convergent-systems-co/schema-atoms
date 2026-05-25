# AI Discovery Interface — Update Prompt for Atom Repos

**Standard:** atom-spec Part XIV (v1.2.0)
**Reference implementation:** [brand-atoms](https://github.com/convergent-systems-co/branding-library)
**Introduced:** 2026-05-25

---

## What this prompt is

Use this prompt to bring any atom catalog site into compliance with atom-spec
Part XIV (AI Discovery Interface). Paste it — with the `[FILL IN]` values
completed — into your AI assistant in the context of the target repo.

---

## Prompt

```
You are implementing atom-spec Part XIV (AI Discovery Interface) for the
**[FILL IN: catalog name, e.g. "persona-atoms"]** catalog site.

Canonical domain: [FILL IN: e.g. "persona-atoms.com"]
Primary atom class: [FILL IN: e.g. "persona"]
Site framework: [FILL IN: e.g. "Astro 6 static" — or the actual framework]
Catalog description (one sentence): [FILL IN]

Reference implementation: https://github.com/convergent-systems-co/branding-library
  - Astro endpoint: web/src/pages/ai/index.json.ts
  - Layout changes: web/src/layouts/Layout.astro
  - robots.txt: web/public/robots.txt
  - JSON emitter: tools/emitters/json.ts

You need to add four things:

### 1. `/ai/index.json` endpoint

Generate at build time from live catalog data. Must return:

```json
{
  "version": "1",
  "site": "https://[canonical-domain]",
  "description": "[one-sentence description]",
  "catalog": {
    "index": "https://[canonical-domain]/dist/index.json",
    "[class]": ["slug1", "slug2"]
  },
  "endpoints": {
    "[class]": "https://[canonical-domain]/dist/[class]/{slug}/{version}/json/[class].json"
  },
  "workflow": ["step 1 ...", "step 2 ...", "step 3 ..."],
  "systemPromptPattern": "..."
}
```

Slug arrays must be generated from live catalog data, not hardcoded.

### 2. `<head>` link on every page

```html
<link rel="ai-index" href="/ai/index.json" type="application/json" />
```

### 3. `robots.txt` at site root

```
User-agent: *
Allow: /

# AI agents
AI-Index: https://[canonical-domain]/ai/index.json
```

### 4. Footer note on all pages

```
AI agents: machine-readable catalog and usage instructions at /ai/index.json
```

### 5. `_ai` block in built JSON atoms (if the catalog emits JSON)

Every built atom JSON file should include at the top level:

```json
{
  "_ai": {
    "docs": "https://[canonical-domain]/ai/index.json",
    "catalog": "https://[canonical-domain]/dist/index.json"
  }
}
```

Write a test for the JSON emitter change using the repo's existing test
framework before implementing.

Use the brand-atoms reference implementation as the exact pattern to follow.
Commit each of the four changes separately with `feat:` conventional commits.
```

---

## Checklist for the implementing engineer

After applying this prompt to a repo, verify:

- [ ] `https://[canonical-domain]/ai/index.json` returns valid JSON
- [ ] `catalog.[class]` array is populated (not empty)
- [ ] `view-source` of homepage includes `<link rel="ai-index">`
- [ ] `[canonical-domain]/robots.txt` contains `AI-Index:` line
- [ ] Footer note visible on homepage
- [ ] Built atom JSON contains `_ai` block (if applicable)
