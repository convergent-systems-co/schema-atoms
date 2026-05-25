# Service Catalog Specification

**Catalog:** `service-atoms.com`
**Version:** 1.0.0-draft
**Conforms to:** `schema-atoms/design-spec/atom-spec@1.1.0`

## Purpose

The service catalog holds structured definitions of external and internal services — named API surfaces with declared endpoints, authentication schemes, SLA expectations, and dependency declarations. Each atom captures the contract and operational characteristics of a service so that agents, workflows, and skills can reference services by atom rather than embedding endpoint configuration in code.

Service atoms are the authoritative source for what a service is and how to reach it. They enable configuration-driven service binding and make service dependencies explicit, versionable, and auditable.

## Atom Classes

| Class | Description |
|---|---|
| `rest-service` | An HTTP/REST API service definition including base URL, authentication, and key endpoint declarations |
| `grpc-service` | A gRPC service definition referencing a proto schema and connection parameters |
| `event-service` | An event broker or message queue service definition (Kafka, SQS, Pub/Sub, etc.) |
| `data-service` | A database or data store service definition including connection parameters and schema reference |

## Consumers

- `skill-atoms` — tool skills reference service atoms to declare their external dependencies
- `agent-atoms` — agents declare service dependencies through their skill bindings
- `workflow-atoms` — workflow steps that call external services reference service atoms for endpoint resolution
- Olympus runtime — resolves service atoms at runtime to inject endpoint configuration without hardcoded URLs

## Relationship to Other Catalogs

- **skill-atoms:** skills wrap service calls; the skill atom provides the invocation interface, the service atom provides the underlying endpoint contract.
- **identity-atoms:** authentication schemes declared in service atoms reference identity atoms for credential resolution.
- **event-atoms:** event-service atoms host the brokers that carry the events defined in event atoms; the two catalogs cover transport (service) and schema (event) separately.
