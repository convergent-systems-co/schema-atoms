# Model Catalog Specification

**Catalog:** `model-atoms.com`
**Version:** 1.0.0-draft
**Conforms to:** `schema-atoms/design-spec/atom-spec@1.1.0`

## Purpose

The model catalog holds structured definitions of AI models — the named, versioned identifiers for large language models and other ML models used across the ecosystem. Each atom captures a model's canonical ID, provider, capability flags, context window size, pricing tier, and known limitations so that agent and service configuration can reference models by atom rather than by hardcoded string.

Model atoms make model selection explicit, versioned, and auditable. They enable safe model transitions — retiring a model atom triggers a defined deprecation path rather than a silent breakage across all consumers.

## Atom Classes

| Class | Description |
|---|---|
| `llm` | A large language model definition including provider, model ID, context window, and capability flags |
| `embedding-model` | An embedding model definition including dimensionality, supported input types, and provider |
| `image-model` | An image generation or understanding model definition |
| `speech-model` | A speech-to-text or text-to-speech model definition |

## Consumers

- `agent-atoms` — agent definitions reference an llm atom to select the underlying model; model rotation is a model-atom update, not an agent-atom change
- `service-atoms` — services that invoke models directly reference model atoms to declare their dependency
- Cost governance tooling — model atoms carry pricing information consumed by budget enforcement and cost reporting
- Evaluation harnesses — model atoms specify which model to target in an eval run for reproducibility

## Relationship to Other Catalogs

- **agent-atoms:** agents bind model atoms; the model atom describes what the model can do, the agent atom describes how it is configured for a specific purpose.
- **service-atoms:** services that act as model inference proxies declare their upstream model atom dependencies.
- **prompt-atoms:** prompt atoms may declare compatibility constraints against specific model atoms (e.g., context window requirements or required capability flags).
