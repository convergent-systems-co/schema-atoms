# GraphQL Schema Class Specification

**Class:** `graphql-schema`
**Version:** 1.0.0-draft
**Conforms to:** `schema-atoms/design-spec/atom-spec@1.1.0`

## What This Class Covers

The `graphql-schema` class represents GraphQL API type systems expressed in GraphQL Schema Definition Language (SDL). It captures types, queries, mutations, subscriptions, directives, and scalar definitions that together define the shape and capabilities of a GraphQL API.

## Accepted Asset Formats

- `.graphql` — GraphQL Schema Definition Language document (preferred)
- `.sdl` — Schema Definition Language document (alternate extension)

## Normative Requirements

- A `graphql-schema` atom MUST contain a single asset file that is a valid GraphQL SDL document parseable by a spec-compliant GraphQL parser (as defined by the June 2018 or later GraphQL specification).
- The schema MUST define at least one root operation type (`Query`, `Mutation`, or `Subscription`).
- The atom MUST NOT include resolver implementations or runtime configuration; it describes the type contract only.

## Example Atom Reference

```
schema-atoms/api-spec/catalog-graphql@1.0.0
├── atom.toml   (class = "graphql-schema")
└── schema.graphql
```

This atom would declare the type system for a product catalog GraphQL API, including `Query.products`, `Product` type, and associated input/enum types.
