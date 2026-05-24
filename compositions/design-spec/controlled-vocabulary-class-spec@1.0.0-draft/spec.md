# Controlled-Vocabulary Class Specification

**Class:** `controlled-vocabulary`
**Family:** taxonomy-spec (Family 6)
**Version:** 1.0.0-draft
**Lifecycle:** draft
**Conforms to:** `schema-atoms/design-spec/atom-spec@1.1.0`
**Authors:** convergent-systems-co

---

## 1. Purpose and Scope

The `controlled-vocabulary` class represents enumerated value sets where each member has a defined meaning within a specific domain. Atoms of this class publish authoritative lists of permitted values — with optional labels, definitions, and metadata — so that downstream systems can validate, document, and render those values consistently.

Controlled vocabularies differ from code lists in that their members are curated by the publishing authority rather than derived from an external standards body. They differ from ontologies in that they describe flat or shallow hierarchies of terms, not formal logical axioms or class relationships.

Typical examples include: status enumerations (`draft`, `active`, `deprecated`), severity levels (`low`, `medium`, `high`, `critical`), content categories, or any domain-specific enumerated type.

---

## 2. Asset Formats

An atom of class `controlled-vocabulary` MUST provide its value set in one of the following formats:

| Format | When to use |
|---|---|
| `.yaml` with inline `values` array | Preferred for small-to-medium vocabularies (under ~200 entries) authored directly in the atom |
| `.json` with inline `values` array | Equivalent to YAML; prefer when consumers are JSON-native |
| `.yaml` or `.json` with an external asset file reference | Use when the value set is large, machine-generated, or managed by a separate tool |

The asset file path is declared in `atom.toml` under `[spec].asset`.

### Inline example structure (YAML)

```yaml
class: controlled-vocabulary
id: schema-atoms/controlled-vocabulary/severity-levels
version: 1.0.0
values:
  - value: low
    label: Low
    definition: The issue has minimal impact and does not block operation.
  - value: medium
    label: Medium
    definition: The issue degrades operation but a workaround exists.
  - value: high
    label: High
    definition: The issue significantly impairs operation; no workaround.
  - value: critical
    label: Critical
    definition: The issue causes complete failure or data loss.
```

---

## 3. Required Envelope Fields

Every `controlled-vocabulary` atom MUST declare the following fields in its `atom.toml`:

| Field | Required value or constraint |
|---|---|
| `id` | `"schema-atoms/controlled-vocabulary/<slug>"` |
| `version` | SemVer string (e.g., `"1.0.0"`) |
| `content_hash` | SHA-256 of the asset file; empty string at draft stage |
| `lifecycle` | One of: `draft`, `stable`, `deprecated` |
| `created_at` | RFC 3339 UTC timestamp |
| `[spec].class` | `"controlled-vocabulary"` |
| `[spec].title` | Human-readable title |
| `[spec].summary` | One-sentence description of the value set |
| `[spec].authors` | Non-empty array of author identifiers |
| `[spec].asset` | Relative path to the asset file (`.yaml` or `.json`) |

---

## 4. Normative Requirements

**MUST:** An atom of class `controlled-vocabulary` MUST include at least two distinct values in its value set. A single-value vocabulary is not a vocabulary; use a boolean field or a constant instead.

**SHOULD:** Each value SHOULD include a `definition` field providing a plain-language description of what the value means and when it applies. Definitions without definitions are lookup tables, not vocabularies.

**MUST NOT:** A `controlled-vocabulary` atom MUST NOT duplicate value codes within the same version. Duplicate codes produce ambiguous validation results.

---

## 5. Example Atom Reference

The following illustrates a well-formed `controlled-vocabulary` atom at draft stage:

```
schema-atoms/controlled-vocabulary/issue-priority@1.0.0-draft
```

`atom.toml`:

```toml
id          = "schema-atoms/controlled-vocabulary/issue-priority"
version     = "1.0.0-draft"
content_hash = ""
lifecycle   = "draft"
created_at  = "2026-05-23T00:00:00Z"

[spec]
class       = "controlled-vocabulary"
title       = "Issue Priority Vocabulary"
summary     = "Permitted priority values for issues in the convergent-systems tracking system."
authors     = ["convergent-systems-co"]
asset       = "values.yaml"
```

`values.yaml`:

```yaml
class: controlled-vocabulary
id: schema-atoms/controlled-vocabulary/issue-priority
version: 1.0.0-draft
values:
  - value: p0
    label: Critical
    definition: Production is down or data is at risk. Requires immediate response.
  - value: p1
    label: High
    definition: Major feature broken with no workaround. Address within 24 hours.
  - value: p2
    label: Medium
    definition: Degraded experience; workaround exists. Address in current sprint.
  - value: p3
    label: Low
    definition: Minor issue or polish item. Schedule at discretion.
```

---

## 6. Changelog

- **1.0.0-draft** — Initial draft specification.
