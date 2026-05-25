# Prompt Catalog Specification

**Catalog:** `prompt-atoms.com`
**Version:** 1.0.0-draft
**Conforms to:** `schema-atoms/design-spec/atom-spec@1.1.0`

## Purpose

The prompt catalog holds versioned, structured LLM prompt templates — system prompts, user prompt patterns, and few-shot example sets. Each atom encodes a prompt as a durable artifact so it can be referenced, validated, signed, and evolved independently of the agents or services that use it.

Prompt atoms decouple prompt engineering from deployment, enabling prompts to be tested, reviewed, and promoted through lifecycle stages before being bound to production agents. They are the authoritative source for what instructions a model receives at inference time.

## Atom Classes

| Class | Description |
|---|---|
| `system-prompt` | A complete system prompt intended to be injected at the start of an LLM conversation |
| `user-prompt-template` | A parameterized user-turn prompt with variable slots for runtime substitution |
| `few-shot-set` | A curated collection of example input/output pairs used for in-context learning |
| `prompt-fragment` | A reusable prompt snippet that composes into larger system or user prompts |

## Consumers

- `agent-atoms` — agent definitions reference system prompt atoms to configure model behavior
- `skill-atoms` — skill definitions may reference prompt templates as invocation patterns
- `persona-atoms` — persona definitions may constrain or extend system prompts
- Evaluation harnesses — prompt atoms supply reproducible test inputs for model evaluation runs

## Relationship to Other Catalogs

- **persona-atoms:** personas constrain the tone and role framing that system prompts must express; prompts are often derived from persona definitions.
- **agent-atoms:** agents bind a model atom and a system prompt atom — the agent is the composition of model, persona, and prompt.
- **skill-atoms:** skills encapsulate capabilities that prompts invoke; a prompt may reference skill descriptions to inform the model of available tools.
