# Plan: TL Language-Spec Class Specifications — Issues #135, #136, #137, #138

**Owner:** TL (language-spec)
**Issues:** #135 (ebnf-grammar), #136 (language-reference), #137 (query-language-spec), #138 (regex-spec)
**Branch:** feat/tl-lang-class-specs
**Date:** 2026-05-23

## Objective

Author four class specification design-spec atoms for Family 5 (language-spec) under `compositions/design-spec/`, each with a valid `atom.toml` envelope and normative `spec.md`.

## Alternatives Table

| Alternative | Pros | Cons | Verdict |
|---|---|---|---|
| One PR per class | Isolated blast radius | Four branches, four PRs, more merge overhead | Rejected — all four are leaf atoms with no inter-dependencies |
| Single branch, all four in one PR | One review, one merge, closes all four issues atomically | Slightly larger diff | **Chosen** — no shared state, no sequential dependencies |
| Draft spec.md as stub + follow-up | Faster first commit | Leaves normative content incomplete; violates Honesty Test | Rejected |

## Scope

**Create (4 directories, 8 files total):**
- `compositions/design-spec/ebnf-grammar-class-spec@1.0.0-draft/atom.toml`
- `compositions/design-spec/ebnf-grammar-class-spec@1.0.0-draft/spec.md`
- `compositions/design-spec/language-reference-class-spec@1.0.0-draft/atom.toml`
- `compositions/design-spec/language-reference-class-spec@1.0.0-draft/spec.md`
- `compositions/design-spec/query-language-spec-class-spec@1.0.0-draft/atom.toml`
- `compositions/design-spec/query-language-spec-class-spec@1.0.0-draft/spec.md`
- `compositions/design-spec/regex-spec-class-spec@1.0.0-draft/atom.toml`
- `compositions/design-spec/regex-spec-class-spec@1.0.0-draft/spec.md`

**Also create:**
- `.artifacts/tests/tl-lang/test-class-specs.sh` — TDD test script (4 checks)

**Touch nothing else.**

## Approach

1. Write plan → `.artifacts/plans/tl-lang-class-specs.md` (this file)
2. Post plan-ready comment on issues #135–#138
3. Write TDD test script — 4 checks for atom.toml existence; must exit 1 now (before implementation)
4. Post TDD-ready comment on issues #135–#138
5. Create branch `feat/tl-lang-class-specs`
6. Create all 4 atom directories in parallel:
   - Each: mkdir, write atom.toml, write spec.md
   - Pull-rebase before each commit to avoid divergence
7. Post coding-complete on issues #135–#138
8. Run adversarial test pass: valid TOML, correct paths, no stray files
9. Push branch, open PR closing all four issues

## Atom Content Summary

| Class | Asset formats | Normative MUST |
|---|---|---|
| ebnf-grammar | .ebnf, .txt (bnf-grammar: .bnf) | Asset MUST be a complete, self-contained grammar defining a single syntactic system |
| language-reference | .md, .html | Asset MUST cover syntax, type system, and built-in operators/functions for the target language |
| query-language-spec | .md, .yaml | Asset MUST define all supported clauses, operators, and data types for the query language |
| regex-spec | .md | Asset MUST specify the regex flavor, engine, and all supported syntax constructs |

## Testing Strategy

`.artifacts/tests/tl-lang/test-class-specs.sh` checks:
1. `compositions/design-spec/ebnf-grammar-class-spec@1.0.0-draft/atom.toml` exists
2. `compositions/design-spec/language-reference-class-spec@1.0.0-draft/atom.toml` exists
3. `compositions/design-spec/query-language-spec-class-spec@1.0.0-draft/atom.toml` exists
4. `compositions/design-spec/regex-spec-class-spec@1.0.0-draft/atom.toml` exists

Script MUST exit 1 before implementation (TDD gate).

## Risk Assessment

| Risk | Mitigation |
|---|---|
| Directory name must match `<slug>@<version>` exactly | Use literal `@` in directory name; verified by test script |
| TOML syntax error breaks catalog scanner | Validate with `python3 -c "import tomllib"` in tester pass |
| Stray files (e.g., .DS_Store) land in owned directories | .gitignore already covers .DS_Store; verify with git status |

## Dependencies

None. `compositions/design-spec/` already exists (has `.gitkeep`). All four atoms are independent.

## Backward Compatibility

Purely additive. No existing files modified.
