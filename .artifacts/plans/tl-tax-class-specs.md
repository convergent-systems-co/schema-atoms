# Plan: Issues #139, #140, #141 — Taxonomy-Spec Class Specifications

**TL:** TL-tax
**Issues:** #139 (controlled-vocabulary), #140 (code-list), #141 (ontology)
**Closes:** #139, #140, #141
**Parent:** Feature #95 (Epic #83)
**Date:** 2026-05-23

---

## Objective

Author three design-spec atom class specifications for the taxonomy-spec family:
- `controlled-vocabulary` — enumerated value sets with definitions
- `code-list` — authority files (country codes, currency codes, etc.)
- `ontology` — OWL/RDF ontologies and formal concept systems

Each delivers `atom.toml` (envelope) and `spec.md` (normative prose) under `compositions/design-spec/<class>-class-spec@1.0.0-draft/`.

---

## Alternatives Table

| Alternative | Pros | Cons | Verdict |
|---|---|---|---|
| Author all three class specs in parallel (chosen) | Maximum throughput; specs are independent; no shared state | Requires 3 separate working directories | **Chosen** |
| Author sequentially | Simpler coordination | Slower; no benefit since specs are structurally independent | Rejected |
| Defer to another TL | No benefit | Assigned OWNS are clear | Rejected |

---

## Scope

**Create (3 directories, 6 files total):**

```
compositions/design-spec/controlled-vocabulary-class-spec@1.0.0-draft/
  atom.toml
  spec.md
compositions/design-spec/code-list-class-spec@1.0.0-draft/
  atom.toml
  spec.md
compositions/design-spec/ontology-class-spec@1.0.0-draft/
  atom.toml
  spec.md
```

**Do NOT touch:** any other file in the repository.

---

## Approach

1. Validate issues #139, #140, #141 OPEN — done.
2. Write this plan — in progress.
3. Post plan-ready comment on all three issues.
4. Write TDD test script: `.artifacts/tests/tl-tax/test-class-specs.sh` — must exit 1 before implementation.
5. Post TDD-ready comment on all three issues.
6. Create branch: `feat/tl-tax-class-specs`.
7. Spawn 3 Coders in parallel (one per class) to create directories and files.
8. Post coding-complete comment.
9. Spawn Tester to validate TOML, no stray files, conventional commits.
10. If PASS: push branch + open PR closing #139, #140, #141.

---

## atom.toml Specification (per class)

Each `atom.toml` MUST contain:
- `id = "schema-atoms/design-spec/<class>-class-spec"`
- `version = "1.0.0-draft"`
- `content_hash = ""` (empty at draft stage)
- `lifecycle = "draft"`
- `created_at = "2026-05-23T00:00:00Z"` (RFC 3339)
- `[spec]` block: `class`, `title`, `summary`, `authors`, `conforms_to`, `asset`

## spec.md Specification (per class)

Each `spec.md` MUST include:
- Class purpose and scope
- Asset format(s) from spec Part II Family 6
- Required envelope fields for atoms of this class
- Example atom reference (illustrative/fictional at draft stage)
- At least one MUST normative requirement

---

## Testing Strategy

The TDD script (`test-class-specs.sh`) checks:
1. `atom.toml` exists in each of the 3 directories
2. `spec.md` exists in each of the 3 directories
3. `atom.toml` contains required keys (`id`, `version`, `lifecycle`, `[spec]`)

Script MUST exit 1 before implementation (directories don't exist yet), exit 0 after.

---

## Risk Assessment

| Risk | Likelihood | Mitigation |
|---|---|---|
| TOML parse error | Low | Validate with `python3 -c "import tomllib; tomllib.load(...)"` in test |
| Stray files | Low | Tester checks only owned paths |
| Branch conflict | Very low | New branch, no overlap with other TLs |

---

## Dependencies

- `compositions/design-spec/` directory already exists (`.gitkeep` present).
- No upstream merges required before starting.

---

## Backward Compatibility

These are new files only. No existing files are modified. No breaking changes.
