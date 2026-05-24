# Atom Spec

**Version:** 1.1.0
**Lifecycle:** draft
**Authors:** convergent-systems-co
**Catalog:** schema-atoms

---

## 1. Purpose

The Atom Spec defines the universal structure for all atoms in the schema-atoms catalog and any catalog that conforms to the `atoms-spec` standard. An atom is the smallest independently publishable, versioned, and signable unit of schema knowledge.

Every atom in the catalog — whether it carries a JSON Schema, an OpenAPI contract, an EBNF grammar, a controlled vocabulary, or a design specification — shares the same envelope defined here. The envelope provides identity, provenance, lifecycle state, and signing metadata. The payload section carries class-specific content.

---

## 2. Atom Identity

Every atom has a globally unique identifier of the form:

```
<catalog-name>/<class>/<slug>@<version>
```

| Component | Description | Example |
|---|---|---|
| `catalog-name` | The catalog this atom belongs to | `schema-atoms` |
| `class` | The atom class (see §6) | `controlled-vocabulary` |
| `slug` | A kebab-case name, unique within the class | `atom-lifecycle-states` |
| `version` | A SemVer string | `1.0.0`, `2.3.1`, `1.0.0-draft` |

**Full example:** `schema-atoms/controlled-vocabulary/atom-lifecycle-states@1.0.0`

References to other atoms in TOML fields use this full identifier form. The `@version` suffix is always required in stored references; omitting it is an error.

---

## 3. Directory Layout

Each atom occupies a dedicated directory within the catalog's `compositions/` tree:

```
compositions/
└── <class>/
    └── <slug>@<version>/
        ├── atom.toml       ← envelope + payload section
        └── <asset-file>    ← the atom's content (format depends on class)
```

The directory name MUST be exactly `<slug>@<version>` — the same slug and version declared in the envelope `id` and `version` fields. A mismatch between the directory name and the envelope fields is a validation error.

---

## 4. The Atom Envelope

Every `atom.toml` begins with the universal envelope. All fields listed as **MUST** are required and must be non-empty.

```toml
id           = "schema-atoms/controlled-vocabulary/atom-lifecycle-states"
version      = "1.0.0"
content_hash = ""
lifecycle    = "draft"
created_at   = "2026-05-23T00:00:00Z"
```

| Field | Type | Required | Description |
|---|---|---|---|
| `id` | string | MUST | Globally unique atom identifier, without version suffix. Format: `<catalog>/<class>/<slug>`. |
| `version` | string | MUST | SemVer version string. Pre-release versions use the `-<label>` suffix (e.g. `1.0.0-draft`). |
| `content_hash` | string | MUST | SHA-256 hash of the asset file contents, hex-encoded. MUST be the empty string `""` when the asset has not yet been hashed. |
| `lifecycle` | string | MUST | Current lifecycle state. MUST be one of the values defined in `schema-atoms/controlled-vocabulary/atom-lifecycle-states`. |
| `created_at` | string | MUST | ISO-8601 UTC timestamp of initial authorship. Format: `YYYY-MM-DDTHH:MM:SSZ`. |
| `supersedes` | string | MAY | Full atom reference (`<id>@<version>`) of the atom this one replaces. Set when this atom is a migration of a prior atom. |
| `superseded_by` | string | MAY | Full atom reference of the newer atom that replaces this one. Set on historic atoms. |
| `migration_notes` | string | MAY | Human-readable guidance for consumers migrating from a superseded atom. |

### 4.1 Lifecycle States

Lifecycle state MUST be one of:

| Value | Meaning |
|---|---|
| `draft` | Under active development or review; not yet ratified. Breaking changes are permitted. |
| `published` | Passed quorum signing; approved for production use. Breaking changes require a new versioned atom. |
| `adopted` | Published and referenced by at least one downstream catalog or consumer. |
| `historic` | Superseded or retired. Retained for archival. SHOULD NOT be referenced in new compositions. |

### 4.2 Content Hash

The `content_hash` field records the SHA-256 digest of the asset file as a lowercase hex string. It is left as `""` during initial authorship and filled in by the `atoms canonicalize` tool before signing.

```toml
content_hash = "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
```

Verifiers MUST reject an atom whose `content_hash` does not match the asset file's current digest, unless they are explicitly operating in a draft-acceptance mode.

---

## 5. The Payload Section

Following the envelope, every atom MUST contain exactly one payload section. The section name is determined by the atom's class:

| Class | Section name |
|---|---|
| `design-spec` | `[spec]` |
| `controlled-vocabulary` | `[controlled_vocabulary]` |
| `ebnf-grammar` | `[ebnf_grammar]` |
| `json-schema` | `[json_schema]` |
| `openapi-spec` | `[openapi_spec]` |
| *(all other classes)* | `[<class_with_hyphens_replaced_by_underscores>]` |

The payload section MUST contain at least an `asset` field pointing to the content file.

```toml
[spec]
class       = "design-spec"
title       = "Atom Spec"
summary     = "The Atom Spec defines the universal atom envelope..."
authors     = ["convergent-systems-co"]
conforms_to = "schema-atoms/design-spec/atom-spec@1.1.0"
asset       = "atom-spec@1.1.0.md"
```

**Common payload fields (all classes):**

| Field | Type | Description |
|---|---|---|
| `class` | string | The atom class. MUST match the class directory in the atom's path. |
| `asset` | string | Filename of the content file, relative to the atom directory. |
| `name` | string | Short machine-readable name for the atom (often the slug). |
| `description` | string | One-sentence description of what this atom represents. |
| `title` | string | Human-readable display title (used by `design-spec` class). |
| `summary` | string | Longer description (used by `design-spec` class). |
| `authors` | array of strings | Authoring entities. |
| `conforms_to` | string | Full atom reference to the class specification this atom conforms to. |

Class-specific payload fields are defined in each class's design-spec atom.

---

## 6. Atom Classes

The schema-atoms catalog organizes atom classes into six families:

### Family 1 — design-spec
Normative specification documents. Class specs, API design specs, governance docs.
- `design-spec`

### Family 2 — api-spec
Machine-readable interface contracts for network APIs.
- `openapi-spec`, `asyncapi-spec`, `graphql-schema`, `grpc-spec`, `json-rpc-spec`

### Family 3 — data-schema
Schema languages for structured data validation.
- `json-schema`, `protobuf-schema`, `avro-schema`, `xml-schema`, `toml-schema`

### Family 4 — protocol-spec
Specifications imported from external standards bodies (IETF, W3C, ISO, NIST).
- `rfc`, `w3c-spec`, `iso-spec`, `fips`, `internal-protocol`

### Family 5 — language-spec
Formal language definitions: grammars, query languages, regular expressions.
- `bnf-grammar`, `ebnf-grammar`, `language-reference`, `query-language-spec`, `regex-spec`

### Family 6 — taxonomy-spec
Enumerated value sets, formal ontologies, and code lists.
- `controlled-vocabulary`, `code-list`, `ontology`

---

## 7. The Protocol Section

Atoms imported from external standards bodies MUST include a `[protocol]` section recording the upstream source and license:

```toml
[protocol]
provenance = "https://toml.io/en/v1.0.0 — TOML 1.0.0 specification by Tom Preston-Werner et al."
license    = "MIT"
```

| Field | Description |
|---|---|
| `provenance` | URL and human description of the upstream source. |
| `license` | SPDX license identifier for the upstream content. |

Convergent Systems-authored atoms (i.e., those with `authors = ["convergent-systems-co"]` and no external source) MUST NOT include a `[protocol]` section.

---

## 8. Versioning

Atoms follow Semantic Versioning (SemVer 2.0.0).

| Change type | Version bump |
|---|---|
| New content, backward-compatible additions | MINOR (`1.0.0` → `1.1.0`) |
| Breaking changes to payload structure or normative requirements | MAJOR (`1.0.0` → `2.0.0`) |
| Patch corrections (typos, formatting, metadata fixes) | PATCH (`1.0.0` → `1.0.1`) |
| Pre-release authorship | `-draft` pre-release suffix (`1.0.0-draft`) |

A `published` or `adopted` atom MUST NOT be edited in place. Breaking changes require a new atom with an incremented version; the old atom's `superseded_by` field is updated and its `lifecycle` is set to `historic`.

---

## 9. Signing

Atoms in the `published` lifecycle state MUST carry at least one valid ML-DSA signature in a `[signatures]` block (defined in a future amendment). Signing requirements are configured per-catalog in `ATOMS.yml`.

The default quorum rule for schema-atoms is `1 of role:catalog-maintainer`. The `design-spec` class requires `1 of role:catalog-maintainer + 1 of role:editor`.

Supported algorithms: `ml-dsa-65` (required), `ml-dsa-44`, `ml-dsa-87` (accepted).

Signing tooling is provided by `atoms-tools`. Draft atoms (`lifecycle = "draft"`) MAY be unsigned.

---

## 10. Catalog Manifest

Each catalog declares its atom types and configuration in `ATOMS.yml` at the repository root. The manifest conforms to `atoms-spec/v1.1.0` and declares:

- `spec_version` — the atoms-spec version this catalog targets
- `name` — the catalog identifier (used as the first segment of all atom IDs)
- `canonical_domain` — the domain where this catalog is published
- `atom_types` — the list of class names this catalog accepts
- `composition_dir` — the directory where atoms are stored (default: `compositions/`)
- `signing` — quorum rules and accepted algorithms
- `lifecycle` — current catalog lifecycle state
- `licensing` — default licenses for code and data content

---

## 11. AI and Application Consumption

Atoms are designed as the primary unit of knowledge for both AI agents and applications, not just human readers. The catalog exposes several access patterns.

### 11.1 Referencing Atoms

An atom is referenced by its full identifier: `<catalog>/<class>/<slug>@<version>`. This string is stable, globally unique, and usable as a cache key, context citation, or lookup token.

```
schema-atoms/rfc/rfc-1918@1.0.0
schema-atoms/design-spec/atom-spec@1.1.0
schema-atoms/controlled-vocabulary/atom-lifecycle-states@1.0.0
```

When an AI agent includes an atom in its context, it SHOULD cite the full identifier so that the reference can be resolved, updated, or audited later.

### 11.2 Catalog Discovery Endpoints

The catalog publishes machine-readable index files at build time under `/exports/`:

| Endpoint | Contents |
|---|---|
| `/exports/catalog.json` | Flat array of all atoms — `{class, slug, file}` per entry |
| `/exports/by-class.json` | Atoms grouped by class name |
| `/exports/by-lifecycle.json` | Atoms grouped by lifecycle state |
| `/mirror.toml` | Federation mirror declaration for this catalog |

An application discovering available atoms SHOULD fetch `/exports/catalog.json` rather than scraping the catalog directory.

### 11.3 The `atom.toml` as Machine-Readable Payload

The `atom.toml` file is the primary structured data surface for applications. Every field in the envelope and payload section is parseable from TOML. Applications and AI agents that need atom metadata (id, version, lifecycle, class-specific fields) SHOULD parse `atom.toml` directly.

The atom's content is in the `asset` file declared in the payload section. The asset type varies by class — `.md` for specification prose, `.yaml` or `.json` for structured data, `.ebnf` for grammars, `.txt` for plain-text documents.

### 11.4 Structured Extracts (`spec.yaml`)

For classes whose asset is not already machine-readable (e.g., plain-text RFC documents), atoms MAY include a `spec.yaml` alongside the primary asset. A `spec.yaml` is a structured YAML extract of the atom's normative content, intended for direct consumption by AI agents and applications without requiring text parsing.

```
compositions/rfc/rfc-1918@1.0.0/
├── atom.toml       ← envelope + [rfc] metadata
├── rfc1918.txt     ← normative text (human + AI readable)
└── spec.yaml       ← structured extract (machine/AI optimized)
```

The `spec.yaml` schema is class-specific. Class specification atoms SHOULD document their `spec.yaml` structure when a text asset is the primary format.

### 11.5 Loading an Atom into AI Context

The recommended pattern for loading a single atom into an AI agent's context window:

1. Resolve the atom ID to a directory: `compositions/<class>/<slug>@<version>/`
2. Parse `atom.toml` for structured metadata (id, version, lifecycle, payload fields)
3. Load the asset file for the atom's normative content
4. If a `spec.yaml` exists, prefer it over the text asset for structured queries

For bulk loading, use `/exports/by-class.json` to enumerate atoms by class, then load selectively.

---

## 12. Normative Requirements Summary

- An atom MUST have a unique `id` of the form `<catalog>/<class>/<slug>`.
- An atom MUST declare a SemVer `version`.
- An atom MUST have a `lifecycle` matching a value in `atom-lifecycle-states`.
- An atom MUST have a `created_at` in ISO-8601 UTC format.
- An atom MUST contain exactly one payload section whose name matches the class.
- An atom MUST declare an `asset` file in its payload section.
- The atom directory name MUST be `<slug>@<version>`.
- A `published` atom MUST have a non-empty `content_hash`.
- A `published` atom MUST carry valid ML-DSA signature(s) meeting the catalog quorum rule.
- A `historic` atom MUST have a `superseded_by` field.
- An atom importing external content MUST include a `[protocol]` section.
- An atom MUST NOT be edited in place once `published` or `adopted`; changes require a new versioned atom.
