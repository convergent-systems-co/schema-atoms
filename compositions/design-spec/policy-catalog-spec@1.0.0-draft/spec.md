# Policy Catalog Specification

**Catalog:** `policy-atoms.com`
**Version:** 1.0.0-draft
**Conforms to:** `schema-atoms/design-spec/atom-spec@1.1.0`

## Purpose

The policy catalog holds structured governance policy definitions — machine-readable rules that express access control, data handling, compliance obligations, and system-level behavioral constraints. Each atom encodes a single coherent policy so that enforcement engines, agents, and audit tools can consume policy as data rather than embedded logic.

Policy atoms are the normative source for what is permitted, required, or forbidden across the ecosystem. They are versioned and signed to ensure tamper-evidence and traceable supersession.

## Atom Classes

| Class | Description |
|---|---|
| `access-policy` | Role-based or attribute-based rules governing who can read, write, or invoke a resource |
| `data-policy` | Rules governing data retention, classification, handling, and disposal |
| `behavioral-policy` | Constraints on AI agent actions — what an agent may or may not do at runtime |
| `compliance-policy` | Policy atoms that map directly to a regulatory or contractual obligation |

## Consumers

- `compliance-atoms` — compliance artifacts reference policy atoms to establish the control baseline
- `agent-atoms` — agent definitions may bind behavioral policies to constrain runtime actions
- `identity-atoms` — access policies are evaluated against identity atoms at authorization time
- Olympus runtime — enforcement plane loads policy atoms to gate tool use and data access

## Relationship to Other Catalogs

- **compliance-atoms:** compliance artifacts document adherence to obligations; policy atoms define those obligations — policy is the rule, compliance is the evidence of following it.
- **identity-atoms:** access policies reference identity providers and roles defined in identity atoms.
- **workflow-atoms:** multi-step workflows may declare which policies apply at each stage, linking workflow and policy atoms by reference.
