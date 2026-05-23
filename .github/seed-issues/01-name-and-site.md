---
title: "Set site name, URL, and repo identity"
labels: ["kind/chore", "area/core", "priority/high", "status/triage"]
---

## Context

The template ships with placeholder values that need to be replaced before
the first deploy.

## Acceptance criteria

- [ ] `web/package.json` — `"name"` reflects the real site slug
- [ ] `web/astro.config.mjs` — `site:` set to the real production URL (drives sitemap, canonical, OG/Twitter Cards)
- [ ] `web/src/pages/index.astro` — title + description replaced with real content
- [ ] README.md H1 is the project's real name
- [ ] `npm install && npm run check && npm run build` succeed from `web/`
