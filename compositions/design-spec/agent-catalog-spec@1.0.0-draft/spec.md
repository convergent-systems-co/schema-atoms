# Agent Catalog Specification

**Catalog:** `agent-atoms.com`
**Version:** 1.0.0-draft
**Conforms to:** `schema-atoms/design-spec/atom-spec@1.1.0`

## Purpose

The agent catalog holds structured definitions of AI agents — the named, deployable configurations that bind a model, persona, prompt, skill set, and channel bindings into a complete runtime unit. Each atom specifies what an agent is, what it can do, and how it is deployed so that instantiation is reproducible and auditable from a single atom reference.

Agent atoms are the primary composition surface of the ecosystem. They do not contain novel logic; they assemble atoms from other catalogs into a coherent, versioned agent configuration.

## Atom Classes

| Class | Description |
|---|---|
| `agent` | Complete agent definition including model binding, persona reference, skill declarations, and channel bindings |
| `agent-template` | A parameterized agent base that can be instantiated into concrete agents with environment-specific values |
| `agent-fleet` | A declaration of multiple agent instances operating in coordinated roles |

## Consumers

- Olympus runtime — the primary consumer; resolves agent atoms and instantiates agent processes from them
- `workflow-atoms` — workflow steps may invoke a named agent atom as an executor
- `pipeline-atoms` — CI/CD pipelines may include agent invocation steps referencing agent atoms
- Evaluation harnesses — agent atoms supply the complete agent configuration for reproducible eval runs

## Relationship to Other Catalogs

- **model-atoms:** every agent atom references a model atom to select the underlying LLM; model and agent are separate concerns — model describes capabilities, agent describes the configured runtime.
- **persona-atoms:** agents bind persona atoms to establish identity; swapping a persona atom changes the agent's presented identity without altering its capabilities.
- **skill-atoms:** agents declare their skill set by referencing skill atoms; the agent is the host, the skill is the transferable capability.
