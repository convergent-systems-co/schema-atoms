# 0005. Defer the legal-spec atom class

- Status: Accepted
- Date: 2026-05-24
- Closes: #112

## Context

The ecosystem handles licensing today through SPDX identifiers recorded in
`ATOMS.yml` (`licensing.code`, `licensing.data`) and in per-atom
`protocol.license` fields. A proposed `legal-spec` class would hold legal
artifacts as atoms: license texts, contract templates, regulatory requirements
(e.g., GDPR article references), and compliance obligations.

The motivation is to make legal constraints machine-consumable so that a future
compliance-atoms catalog or policy-atoms catalog can reference them directly.
However, legal text has properties that resist the atom model: full contract
and license text is long, jurisdiction-specific, legally sensitive, and the
authoritative source is always external (SPDX, official regulation, governing
body). Embedding it as atom content adds overhead without proportionate benefit.

## Decision

Defer the `legal-spec` class. Do not add it to `ATOMS.yml` or the catalog now.

Rationale:

1. **License identity is already solved.** SPDX identifiers are string values
   that uniquely identify licenses. No atom is needed to represent "Apache-2.0";
   the identifier is the reference.

2. **Full legal text is impractical as atoms.** Legal documents are
   jurisdiction-specific and change through amendment, errata, and court
   interpretation in ways that do not map cleanly to the atom versioning model.
   The authoritative text lives upstream; importing it adds maintenance burden.

3. **No concrete consumer requirement yet.** The compliance-atoms catalog does
   not exist. Building a class for a catalog that does not yet have requirements
   is premature.

If and when compliance-atoms is scoped, `legal-spec` should be revisited with
concrete requirements in hand. At that point, the class should be narrowly scoped
to structured compliance *requirements* (e.g., GDPR Article 17 as a structured
obligation with fields: jurisdiction, article, summary, effective-date) — not
full contract text or license prose.

## Consequences

- No `legal-spec` class is added. SPDX identifiers continue to cover license
  identity needs.
- A future compliance-atoms initiative must revisit this ADR before creating
  legal-spec atoms.
- Any interim need to reference a specific license or regulation is satisfied
  by citing the external identifier or URL in atom metadata.

## Alternatives considered

| Alternative | Verdict | Reason |
|---|---|---|
| Defer (revisit when compliance-atoms is scoped) | **Accepted** | No concrete consumer requirement; SPDX identifiers already handle license identity |
| Accept `legal-spec` for full license/contract text | Rejected | Full legal text is jurisdiction-specific, mutable through interpretation, and impractical to maintain as atoms |
| Accept `legal-spec` scoped to structured compliance requirements only | Rejected (for now) | The right scope, but premature without a concrete consuming catalog — defer until compliance-atoms provides real requirements |
| Use `controlled-vocabulary` for license identifiers | Rejected | SPDX is an external controlled vocabulary; wrapping it in a local CV atom adds redundancy without benefit |
