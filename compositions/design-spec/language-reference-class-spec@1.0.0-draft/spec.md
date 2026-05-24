# Language Reference Class Specification

**Class:** `language-reference`
**Version:** 1.0.0-draft
**Lifecycle:** draft
**Conforms to:** schema-atoms/design-spec/atom-spec@1.1.0

---

## Purpose

The `language-reference` class captures the normative specification of a programming language — its syntax, type system, built-in operators, standard library surface, and semantic rules. Atoms of this class are the authoritative reference document for a language or language version, suitable for consumption by tooling authors, language-server implementors, and documentation generators.

Typical subjects include programming languages (Python, TypeScript, Rust, Go), markup languages (HTML, Markdown dialects), templating languages (Jinja2, Liquid), and domain-specific languages (HCL, CUE) that do not already fit a more specific class (e.g., `query-language-spec` or `ebnf-grammar`).

---

## Accepted Asset Formats

| Format | Extension | When to use |
|---|---|---|
| Markdown | `.md` | Preferred for human-authored specifications and community-maintained references |
| HTML | `.html` | Use when the authoritative specification is published as an HTML document and a rendered snapshot is needed |

The `asset` field in `atom.toml` MUST point to exactly one file of one of the above formats. Multi-file specifications (e.g., a reference distributed across many chapters) MUST be consolidated into a single asset or split into multiple atoms with distinct `id` values, one per chapter or module.

---

## Required Envelope Fields

Every `language-reference` atom MUST include the following fields in its `atom.toml`:

```toml
id          = "schema-atoms/language-reference/<slug>"
version     = "<semver>"
content_hash = "<sha256-hex-or-empty-at-draft>"
lifecycle   = "draft | stable | deprecated"
created_at  = "<RFC 3339 timestamp>"

[spec]
class       = "language-reference"
title       = "<human-readable title, e.g. 'Python 3.12 Language Reference'>"
summary     = "<one-sentence description of the language and version covered>"
authors     = ["<org-or-person>"]
conforms_to = "schema-atoms/design-spec/atom-spec@1.1.0"
asset       = "<filename>.<md|html>"
```

Additional fields MAY appear under `[spec]` to identify the language version (e.g., `language_version = "Python 3.12"`) or the upstream source (e.g., `source_url = "https://docs.python.org/3.12/reference/"`).

---

## Normative Requirements

**MUST:** The asset MUST cover, at minimum, the target language's syntax, type system, and built-in operators or functions. A reference that omits any of these three areas is incomplete and MUST be published with `lifecycle = "draft"` until the gap is addressed or explicitly scoped out in a `[spec.scope]` annotation.

**SHOULD:** The asset SHOULD be structured so that each major language feature has its own heading, enabling consumers to extract subsections via heading-level parsing.

**SHOULD:** The asset SHOULD include at least one minimal, runnable code example per major language construct (function definition, conditional, loop, error handling) to make the reference useful for tooling that generates documentation.

**MUST NOT:** The asset MUST NOT duplicate content already captured in an associated `ebnf-grammar` atom for the same language. Where a formal grammar exists as a separate atom, the `language-reference` asset MUST reference it by `id` rather than restating the grammar inline.

---

## Example Atom Reference

The following is an illustrative atom for the TypeScript 5.x language reference:

```
compositions/language-reference/typescript-5-reference@1.0.0/
├── atom.toml
└── typescript-5-reference.md
```

`atom.toml`:
```toml
id          = "schema-atoms/language-reference/typescript-5-reference"
version     = "1.0.0"
content_hash = "b7e2..."
lifecycle   = "stable"
created_at  = "2026-02-01T00:00:00Z"

[spec]
class           = "language-reference"
title           = "TypeScript 5 Language Reference"
summary         = "Normative reference for TypeScript 5.x syntax, type system, and built-in utilities."
authors         = ["convergent-systems-co"]
conforms_to     = "schema-atoms/design-spec/atom-spec@1.1.0"
asset           = "typescript-5-reference.md"
language_version = "TypeScript 5.x"
source_url      = "https://www.typescriptlang.org/docs/handbook/"
```
