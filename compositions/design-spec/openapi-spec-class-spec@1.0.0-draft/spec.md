# OpenAPI Spec Class Specification

**Class:** `openapi-spec`
**Version:** 1.0.0-draft
**Conforms to:** `schema-atoms/design-spec/atom-spec@1.1.0`

## What This Class Covers

The `openapi-spec` class represents REST/HTTP API contracts expressed as OpenAPI 3.x documents. It captures the complete interface surface of an HTTP API: paths, operations, request/response schemas, security schemes, and server definitions.

## Accepted Asset Formats

- `.yaml` — YAML-serialized OpenAPI document (preferred for human authorship)
- `.json` — JSON-serialized OpenAPI document

## Normative Requirements

- An `openapi-spec` atom MUST contain a single asset file whose root object includes an `openapi` key declaring a version string of the form `3.x.y` (OpenAPI 3.x).
- The asset MUST be valid against the OpenAPI 3.x JSON Schema.
- The atom MUST NOT bundle implementation code; it describes the contract only.

## Example Atom Reference

```
schema-atoms/api-spec/payments-api-openapi@1.2.0
├── atom.toml   (class = "openapi-spec")
└── openapi.yaml
```

This atom would declare the HTTP contract for a payments API, including all paths, request bodies, and response schemas, in a single OpenAPI 3.x document.
