# JSON Schema Class Specification

**Class:** `json-schema`
**Version:** 1.0.0-draft
**Conforms to:** `schema-atoms/design-spec/atom-spec@1.1.0`

## What This Class Covers

The `json-schema` class represents JSON Schema documents — vocabulary definitions for validating JSON data. A `json-schema` atom captures a single JSON Schema document at a specific version, along with its metadata and provenance.

## Accepted Asset Formats

- `.json` — JSON-serialized JSON Schema document (preferred)
- `.yaml` — YAML-serialized JSON Schema document

## Required `[spec]` Section Fields

A `json-schema` atom MUST include a `[spec]` section with the following fields:

| Field | Type | Description |
|---|---|---|
| `class` | string | Must be `"json-schema"` |
| `schema_version` | string | JSON Schema draft version: `"draft-04"`, `"draft-06"`, `"draft-07"`, `"2019-09"`, or `"2020-12"` |
| `root_schema_id` | string | The `$id` URI of the root schema document |
| `asset` | string | Filename of the schema asset (e.g., `schema.json`) |

## Normative Requirements

- A `json-schema` atom MUST contain a single asset file (`.json` or `.yaml`) whose root object is a valid JSON Schema.
- The `$id` field in the schema asset MUST equal the value of `spec.root_schema_id` in the `atom.toml`.
- The `$schema` field in the schema asset MUST be consistent with `spec.schema_version`:

| `schema_version` | Expected `$schema` URI |
|---|---|
| `draft-04` | `http://json-schema.org/draft-04/schema#` |
| `draft-06` | `http://json-schema.org/draft-06/schema#` |
| `draft-07` | `http://json-schema.org/draft-07/schema#` |
| `2019-09` | `https://json-schema.org/draft/2019-09/schema` |
| `2020-12` | `https://json-schema.org/draft/2020-12/schema` |

- The atom MUST NOT bundle multiple schema documents; use separate atoms for each.
- The atom MUST NOT inline referenced schemas; use `$ref` URIs pointing to other schema-atoms.

## Example Atom Reference

```
schema-atoms/json-schema/agent-envelope@1.0.0
├── atom.toml   (class = "json-schema", schema_version = "2020-12")
└── schema.json
```

This atom would contain the JSON Schema 2020-12 document for validating an agent envelope object.
