# RFC Class Specification

**Class:** `rfc`
**Version:** 1.0.0-draft
**Lifecycle:** draft
**Conforms to:** `schema-atoms/design-spec/atom-spec@1.1.0`

---

## Purpose

The `rfc` class captures IETF Request for Comments documents — the canonical source of Internet protocol standards, best practices, and informational publications. RFCs define foundational protocols such as TCP/IP, HTTP, TLS, DNS, OAuth, and many others, as well as Best Current Practices (BCPs), Experimental specifications, and Informational documents.

Within schema-atoms, the `rfc` class specifically targets RFCs that are relevant to data schemas, security, identity, and protocol interoperability in the atoms ecosystem. Examples include:

- Address allocation and network topology (RFC 1918, RFC 4193)
- Transport security (RFC 8446 — TLS 1.3, RFC 9001 — QUIC-TLS)
- Identity and authorization (RFC 7519 — JWT, RFC 7636 — PKCE, RFC 6749 — OAuth 2.0)
- Data formats and serialization (RFC 8259 — JSON, RFC 4648 — Base64)
- DNS and naming (RFC 1035, RFC 4034 — DNSSEC)

An `rfc` atom is a versioned, citable reference to a single RFC document. It carries metadata from the RFC itself (number, title, authors, date, status, obsolescence relationships) plus provenance linking back to the authoritative source at rfc-editor.org.

---

## Naming Convention

Atom slugs follow the pattern `rfc-<number>` where `<number>` is the RFC number without leading zeros.

| RFC | Atom slug |
|---|---|
| RFC 1918 | `rfc-1918` |
| RFC 8446 | `rfc-8446` |
| RFC 6749 | `rfc-6749` |
| RFC 9001 | `rfc-9001` |

Full atom path example: `compositions/rfc/rfc-1918@1.0.0/`

---

## Required Envelope Fields

Every `rfc` atom MUST include the following top-level fields in its `atom.toml`:

```toml
id          = "schema-atoms/rfc/<slug>"
version     = "<semver>"
content_hash = "<sha256-hex-or-empty-at-draft>"
lifecycle   = "draft | stable | deprecated"
created_at  = "<RFC 3339 timestamp>"
```

---

## Payload Section: `[rfc]`

Every `rfc` atom MUST include an `[rfc]` section. The following table describes all fields:

| Field | Type | Required | Description |
|---|---|---|---|
| `rfc_number` | integer | MUST | The official RFC number (e.g., `1918`). No leading zeros. |
| `title` | string | MUST | The official RFC title as it appears in the document header. |
| `authors` | array of strings | MUST | RFC author names, in the order listed in the document header (e.g., `["Y. Rekhter", "B. Moskowitz"]`). |
| `published_date` | string | MUST | Publication date. Format: `YYYY-MM` (preferred) or `YYYY-MM-DD` when the day is known and significant. |
| `status` | string | MUST | IETF document status. One of: `STANDARDS TRACK`, `INFORMATIONAL`, `EXPERIMENTAL`, `BCP`, `HISTORIC`. |
| `obsoletes` | array of strings | MAY | RFC identifiers obsoleted by this document (e.g., `["RFC 1597", "RFC 1627"]`). Omit if empty. |
| `obsoleted_by` | array of strings | MAY | RFC identifiers that supersede this document (e.g., `["RFC 4632"]`). Omit if empty. |
| `asset` | string | MUST | Filename of the RFC text asset bundled in this atom directory. |

### Status Values

| Value | Meaning |
|---|---|
| `STANDARDS TRACK` | Proposed Standard, Draft Standard, or Internet Standard on the IETF Standards Track |
| `BCP` | Best Current Practice — operational guidance widely adopted by the Internet community |
| `INFORMATIONAL` | Informational document; no IETF consensus required |
| `EXPERIMENTAL` | Experimental specification; not intended for widespread deployment |
| `HISTORIC` | Replaced by a newer standard or no longer recommended |

---

## Protocol Section: `[protocol]`

Every `rfc` atom MUST include a `[protocol]` section with the following fields:

| Field | Type | Required | Description |
|---|---|---|---|
| `provenance` | string | MUST | URL and descriptive citation pointing to the authoritative source at rfc-editor.org. Format: `"<url> — <citation>"` |
| `license` | string | MUST | Must be `"IETF Trust"` for all IETF-published RFCs. |

The `provenance` URL MUST point to `https://www.rfc-editor.org/rfc/rfc<number>`.

---

## Accepted Asset Formats

| Format | Extension | When to use |
|---|---|---|
| Plain-text RFC | `.txt` | Canonical IETF format; preferred for faithful representation of the original document |
| Markdown | `.md` | Acceptable for markdown-converted or summarized versions annotated for schema-atoms use |

The `asset` field in `[rfc]` MUST name exactly one file present in the atom directory.

For `.txt` assets, the content SHOULD preserve the RFC header block (Network Working Group, Request for Comments number, BCP number if applicable, Category, Date, Authors) and the essential normative sections. Appendices and editorial boilerplate MAY be omitted with a note at the truncation point.

---

## Normative Requirements

1. An `rfc` atom MUST contain exactly one asset file matching the `asset` field value.
2. The `rfc_number` MUST match the number in the `id` slug (e.g., `id = "schema-atoms/rfc/rfc-1918"` requires `rfc_number = 1918`).
3. The `title` MUST be the official title of the RFC as published, not a paraphrase.
4. The `authors` array MUST list authors in the order given in the RFC document header.
5. The `published_date` MUST reflect the RFC's official publication date, not any revision or errata date.
6. The `status` MUST match the IETF status as of the RFC's original publication. If the document has since been placed on the IETF Historic track, `obsoleted_by` SHOULD also be populated.
7. The `obsoletes` and `obsoleted_by` fields, when present, MUST use the string format `"RFC <number>"` with a space between `RFC` and the number.
8. The `[protocol]` section MUST be present; an `rfc` atom without provenance is incomplete.

---

## Complete `atom.toml` Example

The following illustrates a complete, valid `rfc` atom for RFC 1918:

```toml
id          = "schema-atoms/rfc/rfc-1918"
version     = "1.0.0"
content_hash = ""
lifecycle   = "draft"
created_at  = "2026-05-24T00:00:00Z"

[rfc]
rfc_number    = 1918
title         = "Address Allocation for Private Internets"
authors       = ["Y. Rekhter", "B. Moskowitz", "D. Karrenberg", "G. J. de Groot", "E. Lear"]
published_date = "1996-02"
status        = "BCP"
obsoletes     = ["RFC 1597", "RFC 1627"]
asset         = "rfc1918.txt"

[protocol]
provenance = "https://www.rfc-editor.org/rfc/rfc1918 — RFC 1918, February 1996, Rekhter et al."
license    = "IETF Trust"
```

Atom directory layout:

```
compositions/rfc/rfc-1918@1.0.0/
├── atom.toml       ← envelope + [rfc] metadata + [protocol]
├── rfc1918.txt     ← normative RFC text
└── spec.yaml       ← structured extract for AI/application use
```

---

## AI and Application Consumption

### Structured Fields in `[rfc]`

The `[rfc]` payload section is the primary machine-readable interface for applications and AI agents. Key fields for programmatic use:

| Field | AI / Application Use |
|---|---|
| `rfc_number` | Canonical lookup key; resolves cross-references in `obsoletes` / `obsoleted_by` |
| `title` | Display label; use in citations and context summaries |
| `status` | Filter by normative weight — `BCP` and `STANDARDS TRACK` carry stronger obligations than `INFORMATIONAL` |
| `published_date` | Temporal ordering; detecting whether a newer version exists |
| `obsoletes` / `obsoleted_by` | Dependency graph traversal; detecting superseded references |
| `asset` | Filename of the normative text for full-content loading |

### The `spec.yaml` Structured Extract

RFC text assets (`.txt`) are human-readable prose. For AI agents and applications that need structured normative data without parsing free text, an `rfc` atom SHOULD include a `spec.yaml` alongside the text asset.

The `spec.yaml` captures the normative data points in a form directly consumable by code or AI context:

```yaml
rfc_number: 1918
title: "Address Allocation for Private Internets"
status: BCP
normative_requirements:
  - "Private address blocks MUST NOT be forwarded by Internet backbone routers"
  - "Route information about private networks MUST NOT be propagated on inter-enterprise links"
key_definitions:
  private internet: "An enterprise network using TCP/IP that does not require globally unique addresses"
address_blocks:
  - cidr: "10.0.0.0/8"
    range: "10.0.0.0 - 10.255.255.255"
    name: "24-bit block"
  - cidr: "172.16.0.0/12"
    range: "172.16.0.0 - 172.31.255.255"
    name: "20-bit block"
  - cidr: "192.168.0.0/16"
    range: "192.168.0.0 - 192.168.255.255"
    name: "16-bit block"
references:
  - rfc: 1597
    relationship: obsoletes
  - rfc: 1627
    relationship: obsoletes
```

The `spec.yaml` schema is not rigidly fixed — include the fields that are most useful for the RFC's subject matter. `normative_requirements` and any structured data tables (address blocks, algorithm parameters, status codes) are the highest-value fields.

### Loading an RFC Atom

The recommended consumption pattern for AI agents and applications:

1. Parse `atom.toml` for identity and metadata (`rfc_number`, `title`, `status`, `authors`, `published_date`)
2. If `spec.yaml` exists, load it for structured normative content — address blocks, requirements lists, definitions
3. Load the `.txt` asset only when complete normative prose is required

An AI agent asked "what are the private IP address ranges?" resolves `schema-atoms/rfc/rfc-1918@1.0.0`, reads `spec.yaml.address_blocks`, and returns the three CIDR blocks directly — no text parsing required.

Atom citation format: `schema-atoms/rfc/rfc-<number>@<version>`

---

## Relationship to Other Classes

| Related class | Relationship |
|---|---|
| `ebnf-grammar` | An RFC MAY define a formal grammar (e.g., RFC 5234 — ABNF); the grammar itself is captured as a separate `ebnf-grammar` atom that references the RFC. |
| `json-schema` | Data format RFCs (e.g., RFC 8259 — JSON) define the schema contract; a `json-schema` atom captures the machine-readable schema while the `rfc` atom carries the normative text. |
| `controlled-vocabulary` | Status values for `rfc.status` are drawn from the IETF document status vocabulary. |
| `design-spec` | This document is itself a `design-spec` atom that specifies the `rfc` class. |
