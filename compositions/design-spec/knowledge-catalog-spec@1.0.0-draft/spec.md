# Knowledge Catalog Specification

**Catalog:** `knowledge-atoms.com`
**Version:** 1.0.0-draft
**Conforms to:** `schema-atoms/design-spec/atom-spec@1.1.0`

## Purpose

The knowledge catalog holds structured knowledge base artifacts — curated facts, reference data, domain glossaries, and structured knowledge in forms consumable by AI agents at inference time. Each atom captures a coherent unit of knowledge with its provenance, currency date, and applicable domain so that retrieval and grounding are reproducible and auditable.

Knowledge atoms are the authoritative source for what the ecosystem knows as structured, versioned data — distinct from unstructured document corpora and from the model's pretrained weights. They make knowledge explicit, attributable, and evolvable.

## Atom Classes

| Class | Description |
|---|---|
| `fact-set` | A curated collection of verifiable facts with source citations and validity dates |
| `domain-glossary` | Structured terminology definitions for a specific domain, including preferred terms and synonyms |
| `reference-table` | A tabular reference dataset (code lists, lookup tables, classification hierarchies) |
| `knowledge-graph-fragment` | A structured set of entity-relationship triples representing a domain subgraph |

## Consumers

- `skill-atoms` — retrieval skills load knowledge atoms as their primary data source
- `agent-atoms` — agents may declare knowledge atom bindings to inject domain knowledge at inference time
- `prompt-atoms` — few-shot example sets may reference knowledge atoms for grounding
- Evaluation harnesses — knowledge atoms supply ground-truth for factual accuracy evaluation

## Relationship to Other Catalogs

- **skill-atoms:** retrieval skills are the primary interface through which agents access knowledge atoms; the skill provides the query interface, the knowledge atom provides the data.
- **prompt-atoms:** knowledge from knowledge atoms can be injected into prompts at inference time; the knowledge atom is the source, the prompt atom is the vehicle.
- **schema-atoms:** knowledge atoms may conform to schemas defined in schema-atoms (e.g., JSON Schema, controlled vocabulary) for structural validation.
