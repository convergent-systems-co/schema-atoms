# JSON Schema Migration Inventory

*Spike #70 — produced 2026-05-24*

## Summary

Scanned all `convergent-systems-co/*-atoms` repositories for JSON schemas eligible for migration to `schema-atoms` as `json-schema` class atoms.

| Repo | File | $id | Status |
|---|---|---|---|
| agent-atoms | schemas/atom-v1.json | https://agent-atoms.com/schemas/atom-v1.json | **Ready to migrate** |
| agent-atoms | schemas/composition-v1.json | https://agent-atoms.com/schemas/composition-v1.json | **Ready to migrate** |
| agent-atoms | schemas/rule-v1.json | https://agent-atoms.com/schemas/rule-v1.json | **Ready to migrate** |
| theme-atoms | schemas/theme-v1.json | (check actual $id) | **Ready to migrate** |
| All other *-atoms repos | schemas/.gitkeep | — | Empty — no schemas yet |

## Schemas Referenced in Issues but Not Found

| Schema slug | Issue | Location |
|---|---|---|
| panels-config | #71 | Not found in any accessible repo — may be in private or unreleased tooling |
| project-config | #72 | Not found — likely in atoms-tools or DFG (not yet public) |
| agent-envelope | #73 | Not found — may be agent-atoms composition-v1.json or a separate unreleased schema |

## Migration Priority

1. **agent-atoms/atom-v1.json** — most foundational; defines the base atom structure for agent-atoms catalog
2. **agent-atoms/composition-v1.json** — agent assembly schema
3. **agent-atoms/rule-v1.json** — constraint/rule schema
4. **theme-atoms/theme-v1.json** — terminal theme schema

## Blocked Migrations (#71–73)

Issues #71–73 reference schemas (`panels-config`, `project-config`, `agent-envelope`) that were not found in any accessible repository. These issues should remain open until:
- The source repos are identified and accessible, OR
- The schemas are authored and published in their respective repos

**Recommendation:** Create GitHub issues in the source repos to track schema publication, then re-attempt migration once the schemas are accessible.

## Next Steps

- Open tracking issues against `agent-atoms` to confirm migration approval
- Migrate `agent-atoms` schemas in a follow-up wave (3 atoms)
- Migrate `theme-atoms/theme-v1.json` alongside or separately
- Revisit #71–73 when source schemas surface
