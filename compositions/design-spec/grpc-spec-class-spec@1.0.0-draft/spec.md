# gRPC Spec Class Specification

**Class:** `grpc-spec`
**Version:** 1.0.0-draft
**Conforms to:** `schema-atoms/design-spec/atom-spec@1.1.0`

## What This Class Covers

The `grpc-spec` class represents gRPC service contracts expressed as Protocol Buffer (Protobuf) service definition files. It captures service definitions, RPC method signatures, request/response message types, and streaming modalities (unary, server-streaming, client-streaming, bidirectional) for gRPC APIs.

## Accepted Asset Formats

- `.proto` — Protocol Buffer IDL file containing service and message definitions

## Normative Requirements

- A `grpc-spec` atom MUST contain a single asset file with a `.proto` extension that is a valid Protocol Buffers definition parseable under `proto3` syntax (declared via `syntax = "proto3";`).
- The asset MUST define at least one `service` block containing at least one `rpc` method.
- The atom MUST NOT include generated code, server implementation, or client stubs; it describes the service contract only.

## Example Atom Reference

```
schema-atoms/api-spec/inventory-grpc@1.0.0
├── atom.toml   (class = "grpc-spec")
└── inventory.proto
```

This atom would declare the gRPC service contract for an inventory management service, including `rpc GetItem`, `rpc ListItems`, and associated `Item` message types in proto3.
