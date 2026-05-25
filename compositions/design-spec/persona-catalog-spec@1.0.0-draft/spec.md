# Persona Catalog Specification

**Catalog:** `persona-atoms.com`
**Version:** 1.0.0-draft
**Conforms to:** `schema-atoms/design-spec/atom-spec@1.1.0`

## Purpose

The persona catalog holds structured definitions of AI personas — the named, voiced, role-bearing identities that AI agents present to users and systems. Each atom specifies a persona's name, behavioral constraints, communication style, and role boundaries so that agents can be assembled with consistent, auditable identity configurations.

Persona atoms are the authoritative source for how an AI agent represents itself. They decouple persona design from agent deployment, enabling a single persona to be applied across multiple agent instances, models, or channels without drift.

## Atom Classes

| Class | Description |
|---|---|
| `persona` | A complete persona definition including name, voice, role description, and behavioral constraints |
| `persona-template` | A parameterized persona base that other personas extend or instantiate |
| `persona-fragment` | A partial persona trait (e.g., a tone modifier or domain specialization) that composes into full personas |

## Consumers

- `agent-atoms` — agent definitions bind a persona atom to configure agent identity
- Olympus runtime — loads persona atoms at agent instantiation to enforce behavioral constraints
- `prompt-atoms` — system prompts may reference a persona atom to produce role-consistent framing
- Evaluation harnesses — persona atoms supply ground-truth expectations for persona-alignment testing

## Relationship to Other Catalogs

- **agent-atoms:** an agent definition references a persona atom; persona and agent are separate concerns — the persona is who, the agent is how.
- **prompt-atoms:** system prompts are frequently derived from or constrained by persona definitions; persona governs tone and role, prompt governs instruction structure.
- **profile-atoms:** a profile describes a user or system identity; a persona describes an AI's presented identity — related but inverse in direction.
