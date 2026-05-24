# AsyncAPI Spec Class Specification

**Class:** `asyncapi-spec`
**Version:** 1.0.0-draft
**Conforms to:** `schema-atoms/design-spec/atom-spec@1.1.0`

## What This Class Covers

The `asyncapi-spec` class represents event-driven API contracts expressed as AsyncAPI 2.x or 3.x documents. It captures the channels, messages, bindings, and server definitions that describe how producers and consumers interact over message brokers and event streams.

## Accepted Asset Formats

- `.yaml` — YAML-serialized AsyncAPI document (preferred for human authorship)
- `.json` — JSON-serialized AsyncAPI document

## Normative Requirements

- An `asyncapi-spec` atom MUST contain a single asset file whose root object includes an `asyncapi` key declaring a version string of the form `2.x.y` or `3.x.y` (AsyncAPI 2.x or 3.x).
- The asset MUST be valid against the corresponding AsyncAPI JSON Schema for the declared version.
- The atom MUST NOT bundle broker configuration or consumer/producer implementation code; it describes the message contract only.

## Example Atom Reference

```
schema-atoms/api-spec/order-events-asyncapi@2.0.0
├── atom.toml   (class = "asyncapi-spec")
└── asyncapi.yaml
```

This atom would declare the event contract for an order-events channel, specifying message schemas for `OrderPlaced`, `OrderShipped`, and `OrderCancelled` events.
