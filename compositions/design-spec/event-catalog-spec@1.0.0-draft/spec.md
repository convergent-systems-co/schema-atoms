# Event Catalog Specification

**Catalog:** `event-atoms.com`
**Version:** 1.0.0-draft
**Conforms to:** `schema-atoms/design-spec/atom-spec@1.1.0`

## Purpose

The event catalog holds structured definitions of domain events — the named, versioned occurrences that represent meaningful state changes in the ecosystem. Each atom captures an event's schema, producer context, consumer expectations, and delivery semantics so that producers and consumers can evolve independently while staying schema-compatible.

Event atoms are the authoritative source for what events exist and what they carry. They decouple producers from consumers and make the event contract explicit, versioned, and auditable.

## Atom Classes

| Class | Description |
|---|---|
| `domain-event` | A named business event with a structured payload schema and producer declaration |
| `webhook-payload` | An inbound webhook event definition including expected headers, payload schema, and signature verification rules |
| `message-schema` | A message format definition for a message queue or event broker topic |
| `event-subscription` | A declaration of interest in an event type, including filter conditions and delivery channel reference |

## Consumers

- `channel-atoms` — event subscriptions reference channel atoms for delivery targets
- `workflow-atoms` — workflows declare the events that trigger them by referencing event atoms
- `pipeline-atoms` — pipeline trigger definitions reference event atoms (e.g., a push event schema)
- `service-atoms` — services declare which events they produce and consume by referencing event atoms
- Schema validation tooling — event atoms supply the canonical schema for runtime payload validation

## Relationship to Other Catalogs

- **channel-atoms:** events are the what; channels are the where — event atoms define the schema and semantics, channel atoms define the delivery path.
- **workflow-atoms:** events trigger workflows; the event atom defines the trigger contract, the workflow atom defines the response process.
- **service-atoms:** services produce and consume events; service atoms declare service-level dependencies, event atoms define the event-level contracts those services honor.
