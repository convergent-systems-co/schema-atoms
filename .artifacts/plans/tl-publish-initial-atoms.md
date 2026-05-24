# Plan: Publish Initial Atoms (#142–#145)

**Tech Lead:** publish
**Date:** 2026-05-23
**Branch:** feat/tl-publish-initial-atoms
**Issues:** #142, #143, #144, #145

## Objective

Publish 4 atoms into the schema-atoms catalog: 3 controlled-vocabulary atoms and 1 ebnf-grammar atom. All directories currently contain only `.gitkeep` — these are the first concrete atom files.

## Scope

| Issue | Path | Files |
|---|---|---|
| #142 | `compositions/controlled-vocabulary/atom-lifecycle-states@1.0.0/` | `atom.toml`, `values.yaml` |
| #143 | `compositions/controlled-vocabulary/signer-roles@1.0.0/` | `atom.toml`, `values.yaml` |
| #144 | `compositions/controlled-vocabulary/persona-domains@1.0.0/` | `atom.toml`, `values.yaml` |
| #145 | `compositions/ebnf-grammar/toml-1-0@1.0.0/` | `atom.toml`, `grammar.ebnf` |

## Approach

1. Write this plan → `.artifacts/plans/tl-publish-initial-atoms.md`
2. Post plan-ready comment on #142–#145
3. Write TDD test script → `.artifacts/tests/tl-publish/test-publish.sh` (exits 1 — red)
4. Post TDD-ready comment on #142–#145
5. Branch: `feat/tl-publish-initial-atoms`
6. Write all 4 atoms in parallel (each in own subdir, conventional commit per atom)
7. Post coding-complete comment on #142–#145
8. Run tester: validate test script, YAML lint, TOML lint
9. Push branch + open PR closing all 4 issues

## Alternatives Considered

| Alternative | Pros | Cons | Verdict |
|---|---|---|---|
| One commit per atom | Clean isolation, each commit traceable to one issue | 4 commits vs 1 | **Chosen** — matches Git Commit Isolation rule |
| Single mega-commit | Simpler | Violates Code.md §11.2 | Rejected |
| Separate branches per atom | Maximum isolation | Merge overhead, no parallel path | Rejected |

## Testing Strategy

`test-publish.sh` checks:
- Each `atom.toml` exists and is valid TOML (via `python3 -c "import tomllib"`)
- Each asset file (`values.yaml` or `grammar.ebnf`) exists
- YAML files are valid (via `python3 -c "import yaml"`)
- No stub/placeholder text remains (no `TODO`, `FIXME`, `YOUR_CWD`)

## Risk Assessment

| Risk | Mitigation |
|---|---|
| TOML 1.0 ABNF upstream unavailable | Fetch from raw.githubusercontent.com; fallback to representative excerpt with clear source attribution |
| content_hash field empty | Intentional for draft lifecycle — hashing tooling is separate concern |

## Dependencies

- None upstream; this is the first atom content.
- Downstream: catalog export generation, web routes (existing `feat(web)` commits) will pick these up automatically.

## Backward Compatibility

No existing atoms exist — no breaking changes possible.
