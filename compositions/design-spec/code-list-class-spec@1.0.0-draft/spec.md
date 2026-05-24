# Code-List Class Specification

**Class:** `code-list`
**Family:** taxonomy-spec (Family 6)
**Version:** 1.0.0-draft
**Lifecycle:** draft
**Conforms to:** `schema-atoms/design-spec/atom-spec@1.1.0`
**Authors:** convergent-systems-co

---

## 1. Purpose and Scope

The `code-list` class represents authority files derived from or conforming to an external standards body, governing organization, or well-established registry. Atoms of this class publish machine-readable enumerations that systems use for validation, display, and interchange — where the codes themselves are defined by an authority outside the publishing organization.

Code lists differ from controlled vocabularies in that their authoritative source is external (ISO, IANA, UN/LOCODE, etc.) and the atom is primarily a repackaging of that authority's publication. They differ from ontologies in that they define flat enumerations of codes with associated metadata rather than formal logical relationships between concepts.

Typical examples include: ISO 3166-1 alpha-2 country codes, ISO 4217 currency codes, IANA media types, UN/LOCODE port codes, BCP 47 language tags, and similar authority registries.

---

## 2. Asset Formats

An atom of class `code-list` MUST provide its code set in one of the following formats:

| Format | When to use |
|---|---|
| `.json` | Preferred for structured code lists with rich per-code metadata (labels, descriptions, parent codes) |
| `.csv` | Preferred for flat, tabular code lists where column names are the metadata schema |

The asset file path is declared in `atom.toml` under `[spec].asset`. Both formats MUST be UTF-8 encoded without BOM.

### JSON example structure

```json
{
  "class": "code-list",
  "id": "schema-atoms/code-list/iso-4217-currencies",
  "version": "2024.1",
  "authority": "ISO 4217",
  "codes": [
    { "code": "USD", "numeric": "840", "label": "US Dollar", "decimals": 2 },
    { "code": "EUR", "numeric": "978", "label": "Euro", "decimals": 2 },
    { "code": "JPY", "numeric": "392", "label": "Japanese Yen", "decimals": 0 }
  ]
}
```

### CSV example structure

```csv
code,numeric,label,decimals
USD,840,US Dollar,2
EUR,978,Euro,2
JPY,392,Japanese Yen,0
```

---

## 3. Required Envelope Fields

Every `code-list` atom MUST declare the following fields in its `atom.toml`:

| Field | Required value or constraint |
|---|---|
| `id` | `"schema-atoms/code-list/<slug>"` |
| `version` | SemVer string or authority edition (e.g., `"2024.1"`) |
| `content_hash` | SHA-256 of the asset file; empty string at draft stage |
| `lifecycle` | One of: `draft`, `stable`, `deprecated` |
| `created_at` | RFC 3339 UTC timestamp |
| `[spec].class` | `"code-list"` |
| `[spec].title` | Human-readable title including the authority name |
| `[spec].summary` | One-sentence description identifying the authority and coverage |
| `[spec].authors` | Non-empty array of author identifiers |
| `[spec].asset` | Relative path to the asset file (`.json` or `.csv`) |

A `[spec].provenance` block SHOULD be included when the code list is derived from an upstream authority, recording the source URL, retrieval date, and upstream license.

---

## 4. Normative Requirements

**MUST:** An atom of class `code-list` MUST include a `[spec].provenance` block or inline provenance comment when the codes originate from an external authority. Omitting provenance makes the atom's authoritative basis unverifiable.

**MUST:** Each code in the list MUST be unique within the same version of the atom. Duplicate codes produce ambiguous lookup results.

**SHOULD:** A `code-list` atom SHOULD declare the upstream authority's license in the `[spec].provenance` block so consumers can determine whether downstream use is permitted.

---

## 5. Example Atom Reference

The following illustrates a well-formed `code-list` atom at draft stage:

```
schema-atoms/code-list/iso-3166-1-alpha2@2024.1-draft
```

`atom.toml`:

```toml
id          = "schema-atoms/code-list/iso-3166-1-alpha2"
version     = "2024.1-draft"
content_hash = ""
lifecycle   = "draft"
created_at  = "2026-05-23T00:00:00Z"

[spec]
class       = "code-list"
title       = "ISO 3166-1 Alpha-2 Country Codes"
summary     = "Two-letter country codes as defined by ISO 3166-1 alpha-2, edition 2024."
authors     = ["convergent-systems-co"]
asset       = "countries.json"

[spec.provenance]
authority   = "ISO 3166 Maintenance Agency"
source_url  = "https://www.iso.org/iso-3166-country-codes.html"
retrieved   = "2026-05-23"
license     = "ISO copyright — free for reference use; redistribution subject to ISO terms"
```

`countries.json` (excerpt):

```json
{
  "class": "code-list",
  "id": "schema-atoms/code-list/iso-3166-1-alpha2",
  "version": "2024.1-draft",
  "codes": [
    { "code": "US", "numeric": "840", "label": "United States of America" },
    { "code": "GB", "numeric": "826", "label": "United Kingdom of Great Britain and Northern Ireland" },
    { "code": "DE", "numeric": "276", "label": "Germany" }
  ]
}
```

---

## 6. Changelog

- **1.0.0-draft** — Initial draft specification.
