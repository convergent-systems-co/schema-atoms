# Regex Spec Class Specification

**Class:** `regex-spec`
**Version:** 1.0.0-draft
**Lifecycle:** draft
**Conforms to:** schema-atoms/design-spec/atom-spec@1.1.0

---

## Purpose

The `regex-spec` class captures the normative specification of a regular expression flavor — the complete set of syntax constructs, engine semantics, match modes, and Unicode handling rules that define how a particular regex engine interprets patterns.

Different ecosystems ship meaningfully different regex engines (PCRE2, RE2, Python `re`, JavaScript `RegExp`, Java `java.util.regex`, POSIX ERE, etc.), and the differences matter for portability and correctness. Atoms of this class give tooling authors, linters, and documentation generators a single authoritative source for a given engine's behavior.

---

## Accepted Asset Format

| Format | Extension | When to use |
|---|---|---|
| Markdown | `.md` | Required — regex-spec assets are always Markdown prose |

The `asset` field in `atom.toml` MUST point to a single `.md` file. Regex specifications inherently require prose to describe match semantics, backtracking behavior, and Unicode category handling; a structured-data format alone is insufficient.

---

## Required Envelope Fields

Every `regex-spec` atom MUST include the following fields in its `atom.toml`:

```toml
id          = "schema-atoms/regex-spec/<slug>"
version     = "<semver>"
content_hash = "<sha256-hex-or-empty-at-draft>"
lifecycle   = "draft | stable | deprecated"
created_at  = "<RFC 3339 timestamp>"

[spec]
class       = "regex-spec"
title       = "<human-readable title, e.g. 'PCRE2 Regular Expression Specification'>"
summary     = "<one-sentence description of the regex flavor and engine covered>"
authors     = ["<org-or-person>"]
conforms_to = "schema-atoms/design-spec/atom-spec@1.1.0"
asset       = "<filename>.md"
```

Additional fields MAY appear under `[spec]` to identify the engine version (e.g., `engine_version = "PCRE2 10.42"`) or the upstream reference (e.g., `source_url = "https://www.pcre.org/current/doc/html/pcre2syntax.html"`).

---

## Normative Requirements

**MUST:** The asset MUST specify the regex flavor, the engine that implements it, and all supported syntax constructs. "Supported syntax constructs" means at minimum: literals, character classes, quantifiers, anchors, groups (capturing and non-capturing), alternation, and escape sequences. A specification that omits any of these MUST be published with `lifecycle = "draft"` until complete.

**SHOULD:** The asset SHOULD document match mode flags (case-insensitive, multiline, dotall, extended, Unicode) supported by the engine, including the flag syntax used to activate them.

**SHOULD:** The asset SHOULD include at least one example pattern per major construct category, annotated with a matching input string and the expected match result, so consumers can validate their own implementations against the specification.

**MUST NOT:** The asset MUST NOT conflate multiple regex engines or flavors in a single atom. Each engine and version combination that has materially different behavior MUST be its own atom with a distinct `id` value.

---

## Example Atom Reference

The following is an illustrative atom for the PCRE2 regular expression specification:

```
compositions/regex-spec/pcre2-10-42@1.0.0/
├── atom.toml
└── pcre2-10-42.md
```

`atom.toml`:
```toml
id          = "schema-atoms/regex-spec/pcre2-10-42"
version     = "1.0.0"
content_hash = "d9b3..."
lifecycle   = "stable"
created_at  = "2026-04-05T00:00:00Z"

[spec]
class          = "regex-spec"
title          = "PCRE2 10.42 Regular Expression Specification"
summary        = "Normative specification for the PCRE2 regex flavor at version 10.42, covering syntax, flags, and Unicode handling."
authors        = ["convergent-systems-co"]
conforms_to    = "schema-atoms/design-spec/atom-spec@1.1.0"
asset          = "pcre2-10-42.md"
engine_version = "PCRE2 10.42"
source_url     = "https://www.pcre.org/current/doc/html/pcre2syntax.html"
```

`pcre2-10-42.md` (excerpt):
```markdown
## Character Classes

`[abc]` — matches any single character in the set `a`, `b`, or `c`.
`[a-z]` — matches any character in the range a–z (Unicode code points, not bytes).
`[^abc]` — negated class; matches any character NOT in the set.

Example: pattern `[aeiou]+`, input `"hello"` → match `"e"`, then `"o"`.
```
