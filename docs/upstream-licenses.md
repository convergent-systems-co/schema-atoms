# Upstream License Handling

This document describes how schema-atoms handles licensing for atoms imported from external standards bodies.

## Overview

Atoms authored by Convergent Systems Co are licensed under CC-BY-4.0 (data) and Apache-2.0 (code), per `ATOMS.yml`. Atoms imported from external standards bodies retain their upstream license, declared in the `[protocol].license` field of each atom's `atom.toml`.

## License Values by Class

| Class | Upstream Source | License | Notes |
|---|---|---|---|
| `rfc` | IETF | `IETF Trust` | IETF RFCs are © IETF Trust. Reproduction is permitted for standards implementation and commentary. Full terms: https://trustee.ietf.org/license-info |
| `fips` | NIST | `public-domain` | NIST publications are US government works in the public domain under 17 U.S.C. § 105 |
| `w3c-spec` | W3C | `W3C` | W3C specifications are subject to the W3C Document License. Permissive for implementation. Full terms: https://www.w3.org/Consortium/Legal/2015/doc-license |
| `iso-spec` | ISO | `ISO` | ISO standards are proprietary; reproduction is restricted. Only normative excerpts and abstracts are included. Full standards must be purchased from ISO. |
| `internal-protocol` | Internal | varies | Internal protocols authored by Convergent Systems Co use Apache-2.0 unless otherwise noted |

## What Is Included in Imported Atoms

For `rfc`, `fips`, and `w3c-spec` class atoms: the atom asset MAY contain the full normative text, converted to markdown for readability. The original source document is preserved as `asset_source` where applicable.

For `iso-spec` class atoms: the atom asset MUST NOT contain the full standard text. Only a normative summary (abstract, key requirements, version identifiers) is included. Consumers requiring the full text must obtain it from ISO directly.

## The `[protocol]` Section

Every imported atom MUST include a `[protocol]` section:

```toml
[protocol]
provenance = "<source-url> — <citation>"
license    = "<license-value>"
```

The `provenance` field MUST begin with `https://` and include a human-readable citation. The `license` field MUST be one of the values in the table above.

## Validation

`scripts/validate_atoms.py` enforces:

- Protocol-spec classes (`rfc`, `fips`, `w3c-spec`, `iso-spec`, `internal-protocol`) MUST have a `[protocol]` section.
- `provenance` MUST be present and start with `https://` (or `http://`).
- `license` MUST be a recognized value from the table above.

Violations cause the validator to exit non-zero, which blocks CI.
