# Plan: Issue #120 — Scaffold compositions/ directory with per-class layout

**TL:** TL-2
**Issue:** #120
**Closes:** #43, #45
**Parent:** Epic #28 / Feature #42
**Date:** 2026-05-23

---

## Objective

Create the `compositions/` directory with 24 per-class subdirectories (each containing a `.gitkeep`) as declared in `ATOMS.yml`, and remove the now-superseded `schemas/` directory.

---

## Alternatives Table

| Alternative | Pros | Cons | Verdict |
|---|---|---|---|
| Create `compositions/` with 24 subdirs + remove `schemas/` | Matches ATOMS.yml `composition_dir: compositions/` declaration from PR #125; clean removal of dead tree | Requires careful enumeration of all 24 atom_types | **Chosen** |
| Keep `schemas/` as archive alongside new `compositions/` | Preserves old structure | Contradicts acceptance criteria; leaves dead tree; confuses consumers | Rejected |
| Do nothing | Zero risk | Issue remains open; pipeline blocked | Rejected |

---

## Scope

**Create:**
- `compositions/design-spec/.gitkeep`
- `compositions/openapi-spec/.gitkeep`
- `compositions/asyncapi-spec/.gitkeep`
- `compositions/graphql-schema/.gitkeep`
- `compositions/grpc-spec/.gitkeep`
- `compositions/json-rpc-spec/.gitkeep`
- `compositions/json-schema/.gitkeep`
- `compositions/protobuf-schema/.gitkeep`
- `compositions/avro-schema/.gitkeep`
- `compositions/xml-schema/.gitkeep`
- `compositions/toml-schema/.gitkeep`
- `compositions/rfc/.gitkeep`
- `compositions/w3c-spec/.gitkeep`
- `compositions/iso-spec/.gitkeep`
- `compositions/fips/.gitkeep`
- `compositions/internal-protocol/.gitkeep`
- `compositions/bnf-grammar/.gitkeep`
- `compositions/ebnf-grammar/.gitkeep`
- `compositions/language-reference/.gitkeep`
- `compositions/query-language-spec/.gitkeep`
- `compositions/regex-spec/.gitkeep`
- `compositions/ontology/.gitkeep`
- `compositions/controlled-vocabulary/.gitkeep`
- `compositions/code-list/.gitkeep`

**Remove:**
- `schemas/` (contains only `schemas/v1/.gitkeep` — empty placeholder, safe to delete)

**Do not touch:** all other files and directories.

---

## Approach

1. Checkout branch `feat/task-120-compositions-scaffold` from `main`.
2. `mkdir -p` all 24 subdirectories under `compositions/`.
3. `touch` a `.gitkeep` in each subdirectory.
4. `git rm -r schemas/` to remove the dead tree and stage the deletion.
5. `git add compositions/` to stage new files.
6. Commit: `chore(core): scaffold compositions/ per-class layout, remove schemas/`
7. Push branch; open PR targeting `main`.

---

## Testing Strategy

Shell script at `.artifacts/tests/tl2-wave2/test-issue-120.sh`:
- Asserts `compositions/` directory exists.
- Spot-checks three representative class dirs (design-spec, rfc, code-list).
- Asserts all 24 class dirs exist (loop over expected names).
- Asserts all 24 `.gitkeep` files exist.
- Asserts `schemas/` directory is absent.

Script must exit 1 on current state (pre-fix) and exit 0 after fix.

---

## Risk Assessment

| Risk | Likelihood | Mitigation |
|---|---|---|
| Typo in a class directory name | Low | Enumerate names from ATOMS.yml; cross-check list |
| `git rm -r schemas/` fails if schemas/ already removed | Low | Verify current state before running |
| Missing `.gitkeep` causes test failure | Low | Explicit touch for each dir |

---

## Dependencies

- #119 merged (confirmed) — prerequisite met.
- PR #125 merged — `ATOMS.yml` declares `composition_dir: compositions/` (confirmed).

---

## Backward Compatibility

- `schemas/` contained only an empty `.gitkeep` placeholder (no real content). Removal is non-breaking.
- `compositions/` is a net-new directory; no existing consumers reference it.
