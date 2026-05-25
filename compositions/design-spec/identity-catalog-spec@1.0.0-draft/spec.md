# Identity Catalog Specification

**Catalog:** `identity-atoms.com`
**Version:** 1.0.0-draft
**Conforms to:** `schema-atoms/design-spec/atom-spec@1.1.0`

## Purpose

The identity catalog holds structured identity artifacts — authentication provider configurations, OAuth client registrations, cryptographic key declarations, and identity federation specifications. Each atom encodes an identity configuration as a portable, verifiable artifact so that services, agents, and pipelines can resolve authentication and authorization dependencies without embedding credentials or provider-specific logic in code.

Identity atoms govern the authentication layer. They declare what providers are trusted, how credentials are obtained, and what cryptographic keys are authoritative — but they never contain key material or secrets themselves.

## Atom Classes

| Class | Description |
|---|---|
| `auth-provider` | An authentication provider definition including OIDC discovery URL, client ID scope, and token endpoint |
| `oauth-client` | An OAuth 2.0 client registration including grant types, redirect URIs, and scope declarations |
| `cryptographic-key-ref` | A reference to a cryptographic key in an external keystore, including key ID and algorithm |
| `identity-federation` | A trust federation definition linking two identity providers with attribute mapping rules |

## Consumers

- `service-atoms` — service atoms reference identity atoms to declare their authentication requirements
- `policy-atoms` — access policies evaluate identity atom-declared roles and attributes at authorization time
- `profile-atoms` — user profile atoms reference identity atoms to establish the authentication context for a user
- Olympus runtime — loads identity atoms to configure authentication for agent-to-service calls

## Relationship to Other Catalogs

- **profile-atoms:** identity atoms handle authentication (proving identity); profile atoms handle the application-layer attributes of the authenticated actor — distinct layers of the same concern.
- **service-atoms:** services declare their auth requirements by referencing identity atoms; the identity atom describes the provider, the service atom describes the endpoint.
- **policy-atoms:** policy evaluation depends on identity resolution; identity atoms provide the trust anchors that policy atoms reference when expressing access conditions.
