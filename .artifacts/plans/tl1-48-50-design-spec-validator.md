# Plan: TL-1 — design-spec Validator (Issues #48, #49, #50)

**Owner:** TL-1 (design-spec-impl)
**Issues:** #48 ([spec] parser/validator), #49 ([[spec.amendments]] log support), #50 (conforms_to chain resolution)
**Branch:** feature/48-50-design-spec-validator
**Date:** 2026-05-24

## Objective

Implement a standalone Python validation script (`scripts/validate_atoms.py`) that validates design-spec atom.toml files against the class rules derived from Part IV of the Atom Schema Spec. Wire it into the CI `validate` job to replace the current echo placeholder.

## Alternatives Table

| Alternative | Pros | Cons | Verdict |
|---|---|---|---|
| Wait for atoms-tools binary | Clean separation | Blocks indefinitely; atoms-tools has no release timeline | Rejected |
| Shell script | Simple, no dependencies | TOML parsing is fragile in bash | Rejected |
| Python script (tomllib, stdlib only) | Portable, testable, no pip deps; Python 3.11 already on GitHub runners | Slightly more setup than bash | **Chosen** |
| JSON Schema for atom.toml | Machine-readable schema | Doesn't support cross-atom resolution (conforms_to chain) | Rejected as sole approach; may complement later |

## Acceptance Criteria

- [ ] `scripts/validate_atoms.py` exists and is executable
- [ ] Script validates `[spec]` required fields: class, title, summary, authors (non-empty list), conforms_to (non-empty string), asset (non-empty string) — closes #48
- [ ] Script validates `[[spec.amendments]]` entries when present: each entry must have date (ISO-8601), author, summary fields — closes #49
- [ ] Script resolves `conforms_to` value to a real file in `compositions/` (format: `schema-atoms/<class>/<slug>@<version>`) — closes #50
- [ ] CI `validate` job runs the script and exits non-zero on any violation
- [ ] `.artifacts/tests/tl1/test-design-spec-validator.sh` passes after implementation

## Scope

**Create:**
- `scripts/validate_atoms.py` — Python 3.11+ validator using stdlib `tomllib`
- `.artifacts/tests/tl1/test-design-spec-validator.sh` — TDD test runner
- `.artifacts/plans/tl1-48-50-design-spec-validator.md` — this file

**Modify:**
- `.github/workflows/ci.yml` — replace echo stub with `python3 scripts/validate_atoms.py` call

**Touch nothing else.**

## Sub-tasks (single coder, sequential)

### T1 — All in one coder pass

**Owns:**
- `scripts/validate_atoms.py`
- `.github/workflows/ci.yml`

**Work:**
1. Create `scripts/validate_atoms.py`:
   - Walk all `compositions/*/` directories for `atom.toml` files
   - Parse each with `tomllib`
   - For `class == "design-spec"` atoms: validate `[spec]` section required fields (#48)
   - For `class == "design-spec"` atoms: if `[[spec.amendments]]` present, validate each entry has `date`, `author`, `summary` (#49)
   - For any atom: resolve `spec.conforms_to` to `compositions/<class>/<slug>@<version>/atom.toml`, fail if the file doesn't exist (#50)
   - Report all violations; exit 1 if any found
2. Update `.github/workflows/ci.yml` validate step:
   - Replace `echo 'atoms validate: pending...'` with `python3 scripts/validate_atoms.py`
3. Commit with: `feat(ci): implement design-spec atom validator (#48 #49 #50)`

## Validator Logic Detail

```
validate_atoms.py
├── find_atom_files() → generator of Path to atom.toml files
├── validate_envelope(path, data) → check id, version, lifecycle, created_at
├── validate_design_spec(path, data) → [spec] + [[spec.amendments]] checks
├── resolve_conforms_to(root, ref) → check compositions/<class>/<slug>@<ver>/atom.toml exists
└── main() → collect violations, print, sys.exit(1 if any)
```

`conforms_to` format: `schema-atoms/<class>/<slug>@<version>`
→ maps to: `compositions/<class>/<slug>@<version>/atom.toml`
→ example: `schema-atoms/design-spec/atom-spec@1.1.0` → `compositions/design-spec/atom-spec@1.1.0/atom.toml`

## Test Strategy

`.artifacts/tests/tl1/test-design-spec-validator.sh`:
1. Run `python3 scripts/validate_atoms.py` on the real `compositions/` tree — must exit 0 (all existing atoms valid)
2. Create a temp atom.toml missing `spec.title` — run validator — must exit 1
3. Create a temp atom.toml with `conforms_to` pointing to a nonexistent atom — must exit 1
4. Create a temp atom.toml with a malformed `[[spec.amendments]]` entry (missing `date`) — must exit 1

Script MUST exit 1 before implementation (TDD gate: scripts/validate_atoms.py doesn't exist yet).

## Risk Assessment

| Risk | Mitigation |
|---|---|
| Existing atoms may have missing fields | Run validator against real atoms first; fix any violations before adding CI gate |
| tomllib available only in Python 3.11+ | GitHub Actions ubuntu-latest ships Python 3.12; verified via `python3 --version` check in script |
| conforms_to points outside this catalog | Log as warning, not error; cross-catalog resolution is out of scope |

## Dependencies

None. All existing atoms exist in `compositions/`. Python stdlib only.
