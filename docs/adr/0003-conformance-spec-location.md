# 0003. Conformance-spec class lives in schema-atoms

- Status: Accepted
- Date: 2026-05-24
- Closes: #110

## Context

The ecosystem may need atoms that define conformance test suites: structured
documents stating what an implementation must do (or produce) to be considered
compliant with a given spec. A `conformance-spec` atom would describe *what*
correct behavior looks like — not a runnable test suite, but the normative
definition of compliance requirements.

Two candidate homes exist: schema-atoms (canonical schemas, spec definitions,
reference data) and a hypothetical test-atoms catalog (validation artifacts,
runnable suites). The question is whether conformance specs belong with the
spec family or with the test-implementation family.

## Decision

The `conformance-spec` class will be added to schema-atoms as a first-class
atom type in the `spec` family.

Conformance specs are normative reference material. They define what compliant
behavior means — the same kind of artifact as `design-spec` atoms. A
`conformance-spec` atom answers "is this implementation correct?" at the
specification level, not at the execution level. Runnable test suites that
exercise an implementation are test *implementations* — those belong in a
future test-atoms catalog. The distinction is **spec** (normative definition of
compliance) vs. **implementation** (executable artifact that checks compliance).

This mirrors how standards bodies operate: the IETF publishes a conformance
requirements section inside the RFC (a spec artifact); a separate test harness
is a different artifact produced by a different body.

## Consequences

- schema-atoms gains a `conformance-spec` atom type alongside `design-spec`.
- The `ATOMS.yml` `atom_types` list is extended; the spec family grows.
- A future test-atoms catalog can reference `conformance-spec` atoms as the
  normative source of truth for which behaviors to test.
- Runnable test suites are explicitly out of scope for schema-atoms; this
  decision forecloses importing them here.

## Alternatives considered

| Alternative | Verdict | Reason |
|---|---|---|
| Keep in schema-atoms as a class | **Accepted** | Conformance specs are normative; they define compliance, not check it |
| Place in a future test-atoms catalog | Rejected | test-atoms holds executable test implementations, not normative specs |
| Fold into `design-spec` | Rejected | Conformance specs have a distinct payload shape (requirement assertions, compliance levels, test IDs); a separate class is more precise |
