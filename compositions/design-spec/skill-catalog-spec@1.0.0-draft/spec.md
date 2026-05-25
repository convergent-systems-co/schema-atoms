# Skill Catalog Specification

**Catalog:** `skill-atoms.com`
**Version:** 1.0.0-draft
**Conforms to:** `schema-atoms/design-spec/atom-spec@1.1.0`

## Purpose

The skill catalog holds structured definitions of AI agent skills — the discrete, named capabilities that agents can acquire and invoke. Each atom specifies what a skill does, what tools or APIs it requires, what inputs it accepts, and what outputs it produces, enabling agents to be assembled from a library of auditable, versioned capabilities.

Skill atoms are the unit of agent capability extension. They decouple capability definition from agent configuration, so a skill can be adopted by multiple agents and evolved independently across catalog versions.

## Atom Classes

| Class | Description |
|---|---|
| `tool-skill` | A skill backed by a callable tool or API — specifies the tool schema and invocation pattern |
| `reasoning-skill` | A skill that encodes a reasoning pattern or chain-of-thought template without external tool calls |
| `retrieval-skill` | A skill that queries a knowledge source and synthesizes a response |
| `workflow-skill` | A skill that orchestrates a multi-step workflow as a single agent-callable action |

## Consumers

- `agent-atoms` — agent definitions declare which skills they have access to
- `prompt-atoms` — system prompts may include skill descriptions to inform the model of available capabilities
- Olympus runtime — resolves skill atoms at agent initialization and enforces declared tool access
- `knowledge-atoms` — retrieval skills depend on knowledge atoms as their data source

## Relationship to Other Catalogs

- **agent-atoms:** agents are the runtime host for skills; a skill is a transferable capability, an agent is the executor.
- **prompt-atoms:** skills surface to the model through prompt descriptions; the prompt atom and skill atom together define what the model knows it can do and how.
- **workflow-atoms:** workflow-skills wrap workflow atoms into agent-callable single actions, bridging the two catalogs.
