# JSON-RPC Spec Class Specification

**Class:** `json-rpc-spec`
**Version:** 1.0.0-draft
**Conforms to:** `schema-atoms/design-spec/atom-spec@1.1.0`

## What This Class Covers

The `json-rpc-spec` class represents JSON-RPC 2.0 method contracts expressed as structured specification documents. It captures method names, parameter schemas, result schemas, error codes, and notification definitions that together describe a JSON-RPC 2.0 API surface.

## Accepted Asset Formats

- `.yaml` — YAML-serialized JSON-RPC method specification document (preferred for human authorship)
- `.json` — JSON-serialized JSON-RPC method specification document

## Normative Requirements

- A `json-rpc-spec` atom MUST contain a single asset file that declares a `jsonrpc` key with the value `"2.0"` at its root, identifying compliance with the JSON-RPC 2.0 specification.
- The asset MUST define at least one method entry with a `name`, `params` schema, and `result` schema.
- The atom MUST NOT include transport-layer configuration (HTTP, WebSocket, stdio) or server implementation; it describes the method contract only.

## Example Atom Reference

```
schema-atoms/api-spec/wallet-jsonrpc@1.0.0
├── atom.toml   (class = "json-rpc-spec")
└── methods.yaml
```

This atom would declare the JSON-RPC 2.0 method contracts for a wallet service, including `wallet_getBalance`, `wallet_sendTransaction`, and their respective parameter and result schemas.
