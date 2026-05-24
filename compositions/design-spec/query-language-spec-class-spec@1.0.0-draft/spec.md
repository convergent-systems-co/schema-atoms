# Query Language Spec Class Specification

**Class:** `query-language-spec`
**Version:** 1.0.0-draft
**Lifecycle:** draft
**Conforms to:** schema-atoms/design-spec/atom-spec@1.1.0

---

## Purpose

The `query-language-spec` class captures the normative specification of a query language — a language whose primary purpose is to select, filter, transform, or aggregate data from a structured source. Atoms of this class define the complete syntax, supported clauses, operators, data types, and evaluation semantics of a given query language dialect or version.

Typical subjects include SQL dialects (PostgreSQL SQL, SQLite, BigQuery SQL), path and expression languages (JSONPath, JMESPath, XPath), policy and rule languages (CEL — Common Expression Language, OPA/Rego), and purpose-built query languages for time-series or distributed stores (CQL — Cassandra Query Language, PromQL, InfluxQL).

The `query-language-spec` class is distinct from `ebnf-grammar`: grammar atoms capture formal syntax only; query-language-spec atoms capture operational semantics (type coercions, NULL handling, evaluation order) as normative prose, supplemented by a formal grammar reference where one exists.

---

## Accepted Asset Formats

| Format | Extension | When to use |
|---|---|---|
| Markdown | `.md` | Preferred for prose-heavy specifications that describe both syntax and evaluation semantics |
| YAML | `.yaml` | Use for machine-readable specifications that enumerate clauses, operators, and data types in a structured form suitable for codegen |

The `asset` field in `atom.toml` MUST point to exactly one file of one of the above formats. Specifications that require both prose and machine-readable structure SHOULD provide the prose form as the primary asset and reference the machine-readable form as a supplementary file via `[spec.supplements]`.

---

## Required Envelope Fields

Every `query-language-spec` atom MUST include the following fields in its `atom.toml`:

```toml
id          = "schema-atoms/query-language-spec/<slug>"
version     = "<semver>"
content_hash = "<sha256-hex-or-empty-at-draft>"
lifecycle   = "draft | stable | deprecated"
created_at  = "<RFC 3339 timestamp>"

[spec]
class       = "query-language-spec"
title       = "<human-readable title, e.g. 'PostgreSQL 16 SQL Dialect Specification'>"
summary     = "<one-sentence description of the query language and version covered>"
authors     = ["<org-or-person>"]
conforms_to = "schema-atoms/design-spec/atom-spec@1.1.0"
asset       = "<filename>.<md|yaml>"
```

Additional fields MAY appear under `[spec]` to identify the dialect version (e.g., `dialect_version = "PostgreSQL 16"`) or the upstream specification source (e.g., `source_url = "https://www.postgresql.org/docs/16/sql.html"`).

---

## Normative Requirements

**MUST:** The asset MUST define all supported clauses, operators, and data types for the query language. A specification that omits any of these three areas MUST be published with `lifecycle = "draft"` until the gap is addressed or explicitly scoped out via a `[spec.scope]` annotation naming the omitted area.

**SHOULD:** The asset SHOULD include at least one complete, executable query example per major clause type (e.g., SELECT/FROM/WHERE for SQL, filter/map/reduce for JSONPath) to validate that the specification is consistent and unambiguous.

**SHOULD:** Where an `ebnf-grammar` atom exists for the same language, the `query-language-spec` asset SHOULD reference it by atom `id` rather than restating the grammar inline.

**MUST NOT:** The asset MUST NOT conflate multiple SQL dialects or query language versions in a single atom. Each dialect version MUST be its own atom with a distinct `id` value. Shared constructs MAY be factored into a base atom referenced via `[spec.extends]`.

---

## Example Atom Reference

The following is an illustrative atom for the JSONPath specification (RFC 9535):

```
compositions/query-language-spec/jsonpath-rfc9535@1.0.0/
├── atom.toml
└── jsonpath-rfc9535.md
```

`atom.toml`:
```toml
id          = "schema-atoms/query-language-spec/jsonpath-rfc9535"
version     = "1.0.0"
content_hash = "c4a1..."
lifecycle   = "stable"
created_at  = "2026-03-10T00:00:00Z"

[spec]
class           = "query-language-spec"
title           = "JSONPath Specification (RFC 9535)"
summary         = "Normative specification for JSONPath as defined in RFC 9535, covering selectors, operators, and evaluation semantics."
authors         = ["convergent-systems-co"]
conforms_to     = "schema-atoms/design-spec/atom-spec@1.1.0"
asset           = "jsonpath-rfc9535.md"
dialect_version = "RFC 9535"
source_url      = "https://www.rfc-editor.org/rfc/rfc9535"
```
