# Plan: T2 Grammar Atoms — identity, service, channel, context, model

**Branch:** feat/grammar-atoms-t2
**Date:** 2026-05-26
**Author:** Thomas Polliard (via agent)

## Objective

Add 5 grammar atoms to `schema-atoms` that define the structural contract for each T2 group catalog's primary atom class: identity, service, channel, context, and model.

## Rationale

| Alternative | Pros | Cons | Verdict |
|---|---|---|---|
| Add grammar atoms now (this plan) | Establishes contract before catalog impls ship; validators and tooling can reference them | Schema drift if catalog impls diverge before 1.0 | Chosen |
| Wait until first catalog atom ships | More grounded in real usage | Delays contract clarity; catalog devs have no reference | Rejected |
| Inline into ATOMS.yml only | No file duplication | No machine-readable field-level contract | Rejected |

## Scope

Files to create (all in `.artifacts/plans/` + worktree `atoms/`):

- `atoms/identity.toml` — grammar for identity-atoms catalog
- `atoms/service.toml` — grammar for service-atoms catalog
- `atoms/channel.toml` — grammar for channel-atoms catalog
- `atoms/context.toml` — grammar for context-atoms catalog
- `atoms/model.toml` — grammar for model-atoms catalog

## Approach

1. Use `atoms/persona.toml` as canonical structural template.
2. Write each TOML file with: universal envelope, grammar discriminators, `[[fields]]`, `[[references]]`, `[[constraints]]`, `[[signatures]]`.
3. Run `python3 scripts/validate_atoms.py` to confirm existing atoms still pass.
4. Commit, push, PR, merge.

## Testing Strategy

- `python3 scripts/validate_atoms.py` must pass for all existing atoms after the new files are added.
- Grammar atoms themselves define new types; validator coverage will come with a future validator update. Failure to validate grammar atoms as a new class is expected and acceptable for this PR.

## Risk Assessment

- **Schema drift:** Low risk — these are draft-lifecycle atoms. Revision path is documented.
- **Validator failure on new class:** Expected — new `kind = "grammar"` atoms are not yet in the validator's known-types list. Will not block merge.

## Dependencies

- None. This PR stands alone.

## Backward Compatibility

- Additive only. No existing files modified.
