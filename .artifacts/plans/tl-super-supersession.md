# Plan: spec→design-spec Supersession (Issues #146, #147, #149)

**Objective:** Execute spec Part IX supersession — publish design-spec/atom-spec@1.1.0 with supersedes lineage, mark spec/atom-spec@1.1.0 as historic, and verify no downstream consumers reference the old path.

## Alternatives Table

| Alternative | Pros | Cons | Verdict |
|---|---|---|---|
| Create both atom.toml files in a single commit | Simpler | Blurs task ownership; #147 depends on #146 per issue | Rejected |
| Sequential commits, one per issue | Clean task-to-commit mapping; testable independently | Requires two separate commit operations | Chosen |
| Squash into one merge commit | Fewer artifacts | Destroys per-issue commit history; forbidden per Code.md §11.2 | Rejected |

## Scope

Files to create:
- `compositions/design-spec/atom-spec@1.1.0/atom.toml` (issue #146)
- `compositions/spec/atom-spec@1.1.0/atom.toml` (issue #147)

Files to create (tooling only, not shipped as code):
- `.artifacts/plans/tl-super-supersession.md` (this file)
- `.artifacts/tests/tl-super/test-supersession.sh` (TDD writer output)

Files NOT touched: anything outside the above two compositions directories and .artifacts/.

## Approach

1. Write this plan → .artifacts/plans/tl-super-supersession.md ✓
2. Post plan-ready comment on #146, #147, #149
3. Write test → .artifacts/tests/tl-super/test-supersession.sh (must exit 1 before files exist)
4. Post TDD-ready comment on #146
5. Branch: feat/tl-super-spec-supersession
6. Coder 1: create compositions/design-spec/atom-spec@1.1.0/atom.toml, commit with conventional message
7. Coder 2: create compositions/spec/atom-spec@1.1.0/atom.toml, commit with conventional message
8. #149: search downstream repos inline, post findings, close if no matches
9. Post coding-complete on #146, #147
10. Run test suite — must exit 0
11. If PASS: push branch, open PR closing #146, #147 (and #149 if no matches)

## Testing Strategy

Shell script checks:
- Both atom.toml files exist at expected paths
- TOML is syntactically valid (python3 -c "import tomllib" or tomlq)
- design-spec/atom-spec@1.1.0/atom.toml: lifecycle=draft, supersedes set, id correct
- spec/atom-spec@1.1.0/atom.toml: lifecycle=historic, superseded_by set, id correct

## Risk Assessment

| Risk | Mitigation |
|---|---|
| spec/ dir doesn't exist — mkdir fails silently | Explicitly mkdir -p in coder step |
| TOML format error — silently wrong | Validate with python3 tomllib parse |
| Downstream consumer not found — false negative | Use gh search code per spec, document result |

## Dependencies

- #147 depends on #146 (superseded_by references the path created in #146)
- #149 depends on both #146 and #147

## Backward Compatibility

Old path `schema-atoms/spec/atom-spec@1.1.0` is being marked historic, not deleted. The atom.toml at that path carries `superseded_by` pointing consumers to the new path. No existing files are modified — new directories only.
