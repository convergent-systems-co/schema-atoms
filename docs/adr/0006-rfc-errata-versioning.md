# 0006. Two-tier policy for RFC errata versioning

- Status: Accepted
- Date: 2026-05-24
- Closes: #113

## Context

RFC atoms (e.g., `schema-atoms/rfc/rfc-5646@1.0.0`) import a published RFC as
their asset. The IETF publishes official errata against RFCs after publication.
Errata fall into two categories:

- **Editorial errata** — typographical errors, formatting mistakes, incorrect
  cross-references that do not change normative requirements.
- **Technical errata** — errors in normative text, algorithm descriptions, or
  protocol behavior that do change what a correct implementation must do.

The atom-spec states atoms are immutable once published (`lifecycle = published`).
The question is how to handle errata without violating immutability or silently
introducing undisclosed normative changes into an atom consumers already depend on.

## Decision

Apply a two-tier policy based on errata type:

**Tier 1 — Editorial errata (typos, formatting):**
- If the atom is still at `lifecycle = draft`: update the asset file in place
  at the same version. Record the applied errata IDs in the `[rfc]` payload
  using a new optional `errata_ids` field.
- If the atom is at `lifecycle = published`: editorial-only errata do not
  warrant a new version. Create a corrigendum note in the atom's README or
  changelog, but do not bump the version. The errata are cosmetic.

**Tier 2 — Technical errata (normative changes):**
- Create a new atom version (e.g., `rfc-5646@1.1.0`) with:
  - `supersedes = "schema-atoms/rfc/rfc-5646@1.0.0"` in the atom header
  - `errata_ids` listing the applied errata numbers in `[rfc]`
  - `migration_notes` in the atom header explaining the normative change
- The prior version (`@1.0.0`) remains published and immutable.

The `errata_ids` field is added to the `[rfc]` payload schema as an optional
list of IETF errata ID integers. Example:

```toml
[rfc]
rfc_number  = 5646
errata_ids  = [3072, 4492]
```

## Consequences

- Consumers pinned to `@1.0.0` are not silently affected by normative errata;
  they must explicitly adopt `@1.1.0`.
- The `errata_ids` field provides traceability: given an atom, a reader can
  look up exactly which errata have been incorporated.
- Editorial errata at `published` lifecycle are not tracked in the atom version
  history; only the corrigendum note captures them. This is a deliberate
  tradeoff: preserving version stability for cosmetic fixes.
- The `[rfc]` payload schema must be updated to include `errata_ids` as an
  optional field (no breaking change to existing atoms).

## Alternatives considered

| Alternative | Verdict | Reason |
|---|---|---|
| Two-tier policy (editorial in-place, technical new version) | **Accepted** | Balances immutability with traceability; editorial errata do not warrant version churn |
| Always create a new version for any errata | Rejected | Editorial errata (typos) do not change normative content; version churn for cosmetic fixes is noise |
| Ignore errata entirely | Rejected | Technical errata change what a correct implementation must do; silently omitting them misleads consumers |
| Separate `rfc-errata` atom class | Rejected | Errata are properties of the RFC atom, not independent artifacts; scattering them across two atom types complicates lookup |
