# Channel Catalog Specification

**Catalog:** `channel-atoms.com`
**Version:** 1.0.0-draft
**Conforms to:** `schema-atoms/design-spec/atom-spec@1.1.0`

## Purpose

The channel catalog holds structured definitions of communication channels — the named, configured delivery paths through which agents, services, and workflows send and receive messages. Each atom specifies a channel's transport type, authentication configuration, payload constraints, and delivery semantics so that consumers can bind channels without embedding configuration in code.

Channel atoms are the single source of truth for how the ecosystem communicates outward and inward — email, Slack, webhooks, push notifications, and any other transport are all represented as channel atoms.

## Atom Classes

| Class | Description |
|---|---|
| `slack-channel` | Configuration for a Slack workspace channel or DM target, including bot token binding and mention rules |
| `email-channel` | SMTP or API-based email delivery configuration, including sender identity and template bindings |
| `webhook-channel` | HTTP webhook endpoint definition, including URL, signing secret, and retry policy |
| `push-channel` | Mobile or desktop push notification channel configuration |
| `sms-channel` | SMS delivery channel configuration via a gateway provider |

## Consumers

- `workflow-atoms` — workflow steps bind a channel atom to specify notification or escalation paths
- `event-atoms` — event subscriptions reference channel atoms for delivery targets
- `agent-atoms` — agents declare output channels for reporting results or requesting human-in-the-loop input
- Olympus runtime — resolves channel atoms at dispatch time to deliver messages without hardcoded config

## Relationship to Other Catalogs

- **event-atoms:** events are the what; channels are the where — event atoms specify the schema, channel atoms specify the delivery path.
- **workflow-atoms:** workflow notification steps reference channel atoms for their delivery targets.
- **service-atoms:** some channels are thin wrappers over external services; service atoms capture the API contract while channel atoms capture the intent-oriented delivery configuration.
