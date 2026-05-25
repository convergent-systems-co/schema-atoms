# Compliance Catalog Specification

**Catalog:** `compliance-atoms.com`
**Version:** 1.0.0-draft
**Conforms to:** `schema-atoms/design-spec/atom-spec@1.1.0`

## Purpose

The compliance catalog holds structured compliance artifacts — audit records, control mappings, regulatory requirement declarations, and evidence packages that demonstrate adherence to governance obligations. Each atom captures a compliance artifact in a signed, versioned form so that audits and certifications are reproducible and traceable to the policy atoms and system states they reference.

Compliance atoms are the evidence layer of the governance system. They do not define rules (that is policy atoms); they record what was done, when, and against what standard, making the audit trail durable and machine-readable.

## Atom Classes

| Class | Description |
|---|---|
| `control-mapping` | A mapping of policy atoms or requirements to the technical controls that satisfy them |
| `audit-record` | A signed, timestamped record of a compliance check, review, or audit event |
| `regulatory-requirement` | A structured declaration of an external regulatory obligation with scope and applicability conditions |
| `evidence-package` | A collection of references to artifacts (logs, test results, attestations) that evidence control satisfaction |

## Consumers

- `policy-atoms` — compliance atoms reference policy atoms as the baseline against which compliance is assessed
- Audit tooling — compliance atoms are the primary input for automated compliance reporting and gap analysis
- Olympus governance plane — loads compliance atoms to produce compliance dashboards and alert on expired audit records
- External auditors — compliance atoms supply the structured evidence packages required for third-party certification

## Relationship to Other Catalogs

- **policy-atoms:** policy atoms define the rules; compliance atoms document adherence to them. The relationship is normative (policy) to evidentiary (compliance).
- **identity-atoms:** audit records reference identity atoms to attribute actions to authenticated actors.
- **workflow-atoms:** compliance review and approval processes are often encoded as workflow atoms; the workflow produces compliance atoms as its output artifacts.
