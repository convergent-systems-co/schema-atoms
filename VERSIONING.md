# Schema Versioning Policy

All grammar atoms in this repository follow [Semantic Versioning 2.0.0](https://semver.org/spec/v2.0.0.html).

## Version Format

```
MAJOR.MINOR.PATCH
```

## Increment Rules

| Increment | Trigger |
|-----------|---------|
| **MAJOR** | Breaking field removal or rename; incompatible constraint change (e.g., a previously optional field becomes required, an enum loses a value, a type changes) |
| **MINOR** | New optional field; new constraint that is backward-compatible (e.g., a new enum value, a new optional field with a default) |
| **PATCH** | Doc fix; clarification; example addition; whitespace/formatting only |

## Starting Version

All grammar atoms start at `1.0.0`. This baseline was established when the initial
grammar catalog (T1–T4) was merged to `main` (see `CHANGELOG.md`).

## Change Process

1. Open a PR with the atom change(s).
2. Identify the correct increment (MAJOR / MINOR / PATCH) per the table above.
3. Update the `version` field in the affected `.toml` file(s).
4. Add a `CHANGELOG.md` entry under `## [Unreleased]` describing what changed.
5. Include migration notes in the PR description for any MAJOR bump:
   - What field or constraint changed.
   - How consumers should update their usage.
   - Whether a compatibility shim or deprecation window applies.

## Policy Notes

- A single PR MAY bump multiple atoms, but each atom's version MUST be incremented
  independently according to its own change severity.
- MAJOR bumps require explicit sign-off from a CODEOWNER before merge.
- Deprecation before removal is strongly preferred: mark a field as deprecated
  (add a `deprecated = true` annotation and a `deprecation_notice` string) for at
  least one MINOR release before removing it in a MAJOR bump.
- The `version` field in each `.toml` file is the authoritative record; the
  `CHANGELOG.md` is the human-readable narrative.
