# schema-atoms

Canonical JSON Schemas for the convergent-systems-co atoms ecosystem. One schema per top-level type — `agentic`, `prompt`, `skill`, `profile`, `brand`, `theme`, … — served at content-addressable `$id` URLs that downstream catalogs reference.

| | |
|---|---|
| **Type** | `schema` (this catalog's atoms are JSON Schema files) |
| **Site** | [`schema-atoms.com`](https://schema-atoms.com) (apex, Cloudflare-proxied) |
| **Schema URL pattern** | `https://schema-atoms.com/v1/<type>.schema.json` |
| **JSON Schema draft** | 2020-12 (mandated for all schemas; see taxonomy spec §3) |
| **Ecosystem** | Federated under `xdao.co` |

## Status

Bootstrap state. Repo + site scaffold are in place, no schemas authored yet. Schemas land in `schemas/v1/` per the [v0.1 type taxonomy spec](https://github.com/convergent-systems-co/atoms/blob/main/docs/superpowers/specs/2026-05-23-atoms-type-taxonomy-design.md).

## Layout

```
schemas/
└── v1/                          ← schemas authored here; each $id pins /v1/<type>.schema.json
    ├── agentic.schema.json      (TBD — discriminates actor/reviewer via subtype const)
    ├── prompt.schema.json       (TBD)
    ├── skill.schema.json        (TBD)
    ├── profile.schema.json      (TBD)
    ├── brand.schema.json        (TBD)
    ├── theme.schema.json        (TBD)
    └── common.defs.json         (shared $defs: SemVer, name slug, timestamp, signed_by)
web/                             Astro static site → schema-atoms.com (serves the schemas)
infra/terraform/                 Cloudflare Pages + DNS via core-infra v0.1.0 pages-project module
ATOMS.yml                        catalog manifest (conforms to atoms-spec/v1)
```

## Relationship to atoms-spec

| Repo | Governs | Example |
|---|---|---|
| [`atoms-spec`](https://github.com/convergent-systems-co/atoms-spec) | Shape of `ATOMS.yml` (the catalog manifest) | every catalog declares `spec: atoms-spec/v1` |
| `schema-atoms` (this repo) | Shape of **instance files within a catalog** | `persona-atoms/agentic/coder.md` frontmatter validates against `https://schema-atoms.com/v1/agentic.schema.json` |

Two layers of the same validation concern, separated by what they validate. See open question #4 in the taxonomy spec.

## License

Apache-2.0. See [LICENSE](LICENSE).
