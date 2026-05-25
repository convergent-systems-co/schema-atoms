# Profile Catalog Specification

**Catalog:** `profile-atoms.com`
**Version:** 1.0.0-draft
**Conforms to:** `schema-atoms/design-spec/atom-spec@1.1.0`

## Purpose

The profile catalog holds structured user and system profile definitions — declarative descriptions of identity attributes, preferences, capability declarations, and configuration for human users and non-human systems. Each atom encodes a profile as a portable artifact so that services, agents, and workflows can consume profile data without querying a live identity store at runtime.

Profile atoms are the stable, versioned projection of identity into the atoms ecosystem. They complement identity atoms (which govern authentication and credentials) by providing application-layer attributes.

## Atom Classes

| Class | Description |
|---|---|
| `user-profile` | Attributes and preferences for a human user, including display name, locale, and tool preferences |
| `system-profile` | Attributes for a non-human system actor, including capabilities, rate limits, and contact information |
| `organization-profile` | Organizational identity attributes including name, domain, and tier classification |
| `capability-declaration` | A structured declaration of what a user or system is authorized or able to do |

## Consumers

- `agent-atoms` — agents may load a user profile atom to personalize responses and apply capability constraints
- `workflow-atoms` — workflow steps reference profile atoms to resolve actor identity and permissions
- `policy-atoms` — access policies evaluate capability declarations from profile atoms at authorization time
- Olympus runtime — loads profile atoms to contextualize session identity without live directory calls

## Relationship to Other Catalogs

- **identity-atoms:** identity atoms govern authentication and credential management; profile atoms carry application-layer attributes. An identity atom proves who you are; a profile atom describes what you are.
- **persona-atoms:** a persona is an AI's presented identity; a profile is a user's or system's factual identity — related in direction (both describe an actor) but distinct in origin and purpose.
- **policy-atoms:** access policies reference capability-declarations from profile atoms to gate resource access.
