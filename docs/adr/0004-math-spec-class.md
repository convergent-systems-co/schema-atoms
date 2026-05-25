# 0004. Accept the math-spec atom class

- Status: Accepted
- Date: 2026-05-24
- Closes: #111

## Context

The schema-atoms catalog already includes `fips` atoms for FIPS standards such
as FIPS 204 (ML-DSA). The catalog's signing policy requires ML-DSA-65 and the
ecosystem consumes JWT, ML-KEM, and other cryptographic primitives. Formal
parameter sets for these primitives — algorithm constants, security level
definitions, polynomial ring parameters — are structured, machine-consumable
reference data that do not fit cleanly into any current atom class.

`design-spec` could absorb these, but design-spec is a general human-readable
spec type. Cryptographic parameter sets are formal mathematical objects with
structured fields (e.g., `q`, `k`, `eta`, `tau` for ML-DSA lattice parameters)
that tools can read and validate against directly.

## Decision

Accept `math-spec` as a new atom class in schema-atoms, scoped to:

- Formal cryptographic primitive definitions (algorithm parameters, security
  levels, polynomial ring constants)
- Statistical model definitions (distribution parameters, test thresholds)
- Formal protocol parameter sets where the values are mathematical objects

Scope is intentionally narrow. `math-spec` does not include general mathematics,
textbook theorems, or proofs. It targets structured parameter definitions that
are machine-consumable reference data in the same way that `controlled-vocabulary`
atoms are machine-consumable term lists.

A `math-spec` atom for ML-DSA parameter set III would be a structured artifact
alongside `fips-204`, giving tooling a first-class reference for the constants
without parsing the full FIPS PDF.

## Consequences

- schema-atoms gains a `math-spec` atom type in a new `math-spec` family (or
  folded into `protocol-spec` family alongside `fips`).
- Cryptographic primitive parameter sets become citable atoms; tools such as
  atoms-tools and ai-constitution can reference specific parameter versions.
- The scope boundary (formal parameter definitions only, not general math)
  must be documented in the `math-spec` class spec atom so authors know what
  belongs here.
- FIPS atoms and math-spec atoms will overlap in coverage for some primitives;
  the convention is that `fips` holds the normative FIPS document and `math-spec`
  holds the extracted structured parameter set.

## Alternatives considered

| Alternative | Verdict | Reason |
|---|---|---|
| Accept `math-spec` class (scoped) | **Accepted** | Cryptographic parameter sets are structured data distinct from human-readable specs; a dedicated class improves precision |
| Fold into `design-spec` | Rejected | `design-spec` is for human-readable architectural specs; conflating it with formal parameter data loses the machine-consumable distinction |
| Fold into `fips` | Rejected | `fips` is scoped to NIST FIPS documents; math-spec covers non-FIPS primitives (e.g., IETF-specified curves, X9.62 parameters) |
| Defer indefinitely | Rejected | Concrete use cases exist now (ML-DSA, ML-KEM parameters consumed by signing pipeline and ai-constitution) |
