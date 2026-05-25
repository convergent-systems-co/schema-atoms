# Atom Key Spec

**Atom ID:** `schema-atoms/design-spec/atom-key-spec`
**Version:** 1.0.0-draft
**Lifecycle:** draft
**Conforms to:** `schema-atoms/design-spec/atom-spec@1.1.0`

## Purpose

The Atom Key Spec defines how ML-DSA keypairs are generated, stored, rotated, and used to sign atoms in schema-atoms catalogs. It is the normative reference for key management in the atoms-tools signing workflow.

Every published atom carries a signature block that links it to a key whose identity and role are declared in the catalog manifest (`ATOMS.yml`). This spec governs the full lifecycle of those keys.

## Key Types

Three roles participate in the signing workflow, as declared in the catalog's `ATOMS.yml` quorum rules:

| Role | Purpose |
|---|---|
| `catalog-maintainer` | Owns the catalog. Signs any atom in the catalog. Required for all quorum rules. |
| `editor` | Authors atoms within the catalog. Co-signs atoms in classes with elevated quorum requirements (e.g., `design-spec`). |
| `ratifier` | External reviewer or stakeholder. Used in quorum rules requiring third-party endorsement. |

A key is associated with exactly one role per catalog. A person or system MAY hold keys in multiple roles across different catalogs, but role scoping is per-catalog.

## Algorithm

### Required

**ML-DSA-65** (FIPS 204, formerly known as Dilithium3) is the required algorithm for all new signing keys. ML-DSA is a lattice-based digital signature algorithm standardized by NIST as quantum-resistant.

### Accepted Alternatives

The following algorithms are accepted for existing keys and for environments with hardware constraints:

| Algorithm | NIST designation | Notes |
|---|---|---|
| ML-DSA-44 | FIPS 204 (Level 2) | Shorter signatures; lower security margin |
| ML-DSA-87 | FIPS 204 (Level 5) | Larger keys and signatures; highest security margin |

Classic algorithms (RSA, ECDSA, Ed25519) are NOT accepted for atom signing. Migration of any catalog using classic keys MUST be completed before the catalog reaches `adopted` lifecycle for its first atom.

## Key Storage

### Requirements

Keys MUST be stored in a hardware-backed keystore or a secrets manager with audit logging. Acceptable backends:

- **Hardware Security Module (HSM)** — YubiHSM, SafeNet, AWS CloudHSM
- **OS keystore** — macOS Secure Enclave (for keys flagged non-exportable), Windows DPAPI-backed CNG
- **Secrets manager** — HashiCorp Vault (Transit engine or KV with HSM-backed unseal), AWS Secrets Manager with KMS CMK, Azure Key Vault

Keys MUST NOT be stored in:

- Plaintext files on disk
- Environment variables
- Source code or configuration committed to a repository
- The atom catalog itself

The `atoms-tools` CLI reads key material only via the configured backend; it never writes key bytes to stdout or to any artifact.

### Key Metadata

Each key MUST be registered in the catalog's `ATOMS.yml` with:

```yaml
keys:
  - id: "key-<short-fingerprint>"
    role: catalog-maintainer
    algorithm: ML-DSA-65
    fingerprint: "<hex-encoded public key fingerprint>"
    created_at: "2026-05-24T00:00:00Z"
    expires_at: null          # null = no expiry; ISO-8601 if bounded
    revoked: false
    backend: "macos-keychain" # or "vault", "hsm", "aws-secrets-manager", etc.
```

The `ATOMS.yml` entry is the canonical identity of a key. The signing backend is the custody location.

## Signing Workflow

### Command

```bash
atoms sign <atom-path> --key <key-id>
```

Where `<key-id>` matches the `id` field in `ATOMS.yml`. The tool:

1. Resolves the key backend from the catalog's `ATOMS.yml`.
2. Fetches the private key material from the backend (never logging the key bytes).
3. Canonicalizes the atom (computes `content_hash` if not already set).
4. Produces a detached signature over the canonical atom bytes using ML-DSA.
5. Writes the signature block to `atom.toml` under a `[signature.<key-id>]` table.

### Signature Block

```toml
[signature."key-abc123"]
algorithm   = "ML-DSA-65"
fingerprint = "<hex>"
signed_at   = "2026-05-24T12:00:00Z"
value       = "<base64-encoded signature bytes>"
```

Multiple signatures are supported — each key that signs an atom appends its own `[signature.<key-id>]` block.

## Verification

### Command

```bash
atoms verify <atom-path>
```

The tool:

1. Reads the catalog's quorum rules from `ATOMS.yml` for the atom's class.
2. Checks that the required number and roles of valid signatures are present.
3. Verifies each present signature's `value` against the atom's canonical bytes using the public key identified by `fingerprint`.
4. Returns exit code 0 if all quorum requirements are met; exit code 5 if verification fails.

Verification does not require access to the signing backend. Public key fingerprints are sufficient and are embedded in `ATOMS.yml`.

## Quorum Rules

Quorum rules are declared per atom class in `ATOMS.yml`. Default rules:

| Class | Quorum requirement |
|---|---|
| All classes (default) | 1 signature from `catalog-maintainer` |
| `design-spec` | 1 from `catalog-maintainer` AND 1 from `editor` |

Custom quorum rules are expressed as:

```yaml
quorum_rules:
  design-spec:
    - role: catalog-maintainer
      count: 1
    - role: editor
      count: 1
```

The `count` field specifies the minimum number of distinct keys of that role required. Two signatures from the same key do not satisfy a `count: 2` requirement.

## Key Rotation

### When to Rotate

Keys MUST be rotated when:

- A key is suspected of compromise.
- The key holder's access is revoked (personnel change, role change).
- The key reaches its declared `expires_at` date.

Keys SHOULD be rotated every 2 years for long-lived catalogs, even without a specific trigger.

### Rotation Procedure

1. Generate a new keypair in the signing backend.
2. Register the new key in `ATOMS.yml` with `revoked: false`.
3. Mark the old key in `ATOMS.yml` with `revoked: true` and add a `revoked_at` timestamp.
4. Re-sign all atoms in the catalog that carry only the revoked key's signature. Atoms with sufficient surviving quorum signatures do not require re-signing.
5. Commit the updated `ATOMS.yml` and updated atom files as a single signed commit. The commit MUST itself be signed with the new key.
6. Announce the rotation in the catalog's CHANGELOG.

### Revocation Effects

A revoked key's signatures are not counted toward quorum. An atom that relied solely on a revoked key's signature fails verification and MUST be re-signed before it can be deployed.

Revoked keys are retained in `ATOMS.yml` (with `revoked: true`) for audit purposes. They are never removed.

## Configuration

Key backend defaults are declared in `~/.atoms/config.toml`:

```toml
[keys]
default_key     = "key-abc123"          # key-id used when --key is omitted
default_backend = "macos-keychain"      # backend for the default key
```

Per-catalog overrides may appear in the catalog's own `ATOMS.yml`.
