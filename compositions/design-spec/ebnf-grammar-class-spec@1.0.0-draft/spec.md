# EBNF Grammar Class Specification

**Class:** `ebnf-grammar`
**Version:** 1.0.0-draft
**Lifecycle:** draft
**Conforms to:** schema-atoms/design-spec/atom-spec@1.1.0

---

## Purpose

The `ebnf-grammar` class captures formal grammars expressed in Extended Backus-Naur Form (EBNF) or plain Backus-Naur Form (BNF). Atoms of this class serve as the canonical, machine-readable definition of a language's syntactic structure, independent of any particular parser implementation.

This class covers two closely related notations:

| Notation | Extension | Notes |
|---|---|---|
| EBNF | `.ebnf` or `.txt` | W3C-style or ISO 14977 EBNF with grouping, repetition, and option operators |
| BNF | `.bnf` | Classic Backus-Naur Form without extension operators; subsumed by this class |

Consumers of `ebnf-grammar` atoms include parser generators, documentation systems, language-server tooling, and schema validators that derive parsers from grammar source.

---

## Accepted Asset Formats

| Format | Extension | When to use |
|---|---|---|
| EBNF source | `.ebnf` | Preferred for grammars using ISO 14977 or W3C-style notation |
| Plain text EBNF | `.txt` | Acceptable when the grammar is embedded in a plain-text specification document |
| BNF source | `.bnf` | Use for grammars expressed in original BNF notation without EBNF extensions |

The `asset` field in `atom.toml` MUST point to exactly one file of one of the above formats.

---

## Required Envelope Fields

Every `ebnf-grammar` atom MUST include the following fields in its `atom.toml`:

```toml
id          = "schema-atoms/ebnf-grammar/<slug>"
version     = "<semver>"
content_hash = "<sha256-hex-or-empty-at-draft>"
lifecycle   = "draft | stable | deprecated"
created_at  = "<RFC 3339 timestamp>"

[spec]
class       = "ebnf-grammar"
title       = "<human-readable title>"
summary     = "<one-sentence description of what language or fragment this grammar covers>"
authors     = ["<org-or-person>"]
conforms_to = "schema-atoms/design-spec/atom-spec@1.1.0"
asset       = "<filename>.<ebnf|txt|bnf>"
```

Additional fields MAY appear under `[spec]` to record the grammar notation standard (e.g., `notation = "ISO-14977"`) or the target language version (e.g., `language_version = "SQL:2023"`).

---

## Normative Requirements

**MUST:** The asset MUST be a complete, self-contained grammar defining a single syntactic system. It MUST NOT split production rules across multiple files referenced by the asset. If a grammar is too large for a single file, partition it by subsystem, each as its own `ebnf-grammar` atom with distinct `id` values and a `[spec.extends]` reference to the root grammar atom.

**SHOULD:** The asset SHOULD identify the notation standard it follows (ISO 14977, W3C, ANTLR, PEG, etc.) in a leading comment or a `notation` field in `atom.toml`, so consumers can select an appropriate parser.

**MUST NOT:** The asset MUST NOT embed prose explanations or commentary as running text between rules. Explanatory prose belongs in an associated `language-reference` atom; the grammar asset is a formal artifact, not a tutorial.

---

## Example Atom Reference

The following is an illustrative atom for a hypothetical SQL SELECT fragment grammar:

```
compositions/ebnf-grammar/sql-select-fragment@1.0.0/
├── atom.toml
└── sql-select-fragment.ebnf
```

`atom.toml`:
```toml
id          = "schema-atoms/ebnf-grammar/sql-select-fragment"
version     = "1.0.0"
content_hash = "a3f9..."
lifecycle   = "stable"
created_at  = "2026-01-15T00:00:00Z"

[spec]
class       = "ebnf-grammar"
title       = "SQL SELECT Fragment Grammar"
summary     = "EBNF grammar covering the SELECT statement for the SQL:2016 dialect."
authors     = ["convergent-systems-co"]
conforms_to = "schema-atoms/design-spec/atom-spec@1.1.0"
asset       = "sql-select-fragment.ebnf"
notation    = "W3C-EBNF"
language_version = "SQL:2016"
```

`sql-select-fragment.ebnf` (excerpt):
```ebnf
select_statement ::= "SELECT" select_list "FROM" table_reference
select_list      ::= "*" | column_reference ("," column_reference)*
column_reference ::= identifier | table_name "." identifier
```
