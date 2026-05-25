# 0007. Always use external asset files for controlled-vocabulary atoms

- Status: Accepted
- Date: 2026-05-24
- Closes: #114

## Context

`controlled-vocabulary` atoms currently store their value lists in a separate
`values.yaml` asset file, referenced via the `asset` field in `atom.toml`. The
question is whether small vocabularies (fewer than 10 values, under 500 chars
total) should be permitted to inline their values directly in `atom.toml` as a
TOML array, to avoid the overhead of a separate file.

Three existing controlled-vocabulary atoms use the `asset` pattern:
`atom-lifecycle-states`, `persona-domains`, and `signer-roles`. The catalog
tooling (validators, site generator) reads the `asset` field and resolves the
file path. Content hash validation is applied to the asset file.

## Decision

External asset files are the standard and default for all controlled-vocabulary
atoms. The `asset` field in `[controlled_vocabulary]` always points to a
separate file (typically `values.yaml`).

Rationale:

1. **Consistency.** All three existing atoms use `asset`. Introducing inline
   values creates two code paths in every tool that reads controlled vocabularies.
2. **Content hash integrity.** The atom-spec content hash covers the asset file.
   Inline TOML values in `atom.toml` would require hashing the whole `atom.toml`,
   which mixes metadata and content — a structural problem.
3. **Tooling path is established.** The site generator, validator, and CLI all
   follow `asset → file → parse`. This path is tested and stable.

**Exception — opt-in `inline_values`:** If a vocabulary has **5 or fewer values**
AND each value carries no description field (name only, no `description`, `label`,
or additional properties), an `inline_values` field in `[controlled_vocabulary]`
is permitted as an explicit opt-in alternative:

```toml
[controlled_vocabulary]
name          = "boolean-flags"
description   = "Simple yes/no vocabulary."
inline_values = ["true", "false"]
```

When `inline_values` is present, `asset` must be absent. Tooling must handle
both fields, treating `inline_values` as the vocabulary content when present.
This exception is narrow and intentionally limited to the simplest possible
case: a flat name list with no metadata per value.

## Consequences

- Existing atoms are unaffected; all use `asset` already.
- New atoms with 5 or fewer plain-name values MAY use `inline_values`; all
  others MUST use `asset`.
- Tooling (validator, site generator, CLI) must be updated to handle the
  `inline_values` field as an alternative to `asset` in the
  `[controlled_vocabulary]` payload.
- Content hash for atoms using `inline_values` covers `atom.toml` itself
  (since there is no separate asset file); this must be specified in the
  controlled-vocabulary class spec atom.

## Alternatives considered

| Alternative | Verdict | Reason |
|---|---|---|
| Always external asset file (with narrow inline exception) | **Accepted** | Maximizes consistency and preserves content hash integrity; exception covers trivial vocabularies |
| Always external asset file (no exception) | Considered, not adopted | The exception has zero migration cost and reduces file overhead for simple boolean-style vocabularies |
| Allow inline for any vocabulary under 500 chars | Rejected | No clear boundary; opens the door to gradually larger inline blobs; two code paths without a principled cutoff |
| Always inline in `atom.toml` | Rejected | Breaks content hash integrity; forces tooling rewrite; inconsistent with all existing atoms |
