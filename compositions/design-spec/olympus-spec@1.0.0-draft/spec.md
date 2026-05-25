# Olympus Spec

**Atom ID:** `schema-atoms/design-spec/olympus-spec`
**Version:** 1.0.0-draft
**Lifecycle:** draft
**Conforms to:** `schema-atoms/design-spec/atom-spec@1.1.0`

## Purpose

Olympus is a platform runtime that consumes atoms from schema-atoms catalogs to drive deployment, configuration, and operational decisions across convergent-systems-co workloads. It treats atoms as the immutable unit of configuration: an Olympus environment is a composition of resolved atoms.

Olympus does not embed configuration values. It resolves atoms by ID, validates their signatures, and assembles deployment manifests from their content. This makes every deployed configuration traceable to a specific signed atom version.

## How Olympus Consumes Atoms

### Resolution

Olympus resolves atoms using the full atom ID, including version:

```
<catalog>/<class>/<slug>@<version>
```

Resolution proceeds in this order:

1. **Local cache** — check `~/.atoms/cache/<catalog>/<class>/<slug>@<version>/`. On a cache hit, verify `content_hash` if the atom is `published` or `adopted`.
2. **Canonical domain** — if not cached, fetch from the atom's canonical domain using the catalog's base URL declared in `ATOMS.yml`.
3. **Mirror fallback** — if the canonical domain is unreachable, check `/mirror.toml` for alternative sources.

Resolution fails with exit code 3 (network error) if no source is reachable. Olympus MUST NOT fall back to an unverified or unsigned atom.

### Signature Validation

Before an atom is used in any deployment manifest, Olympus validates its signature against the quorum rules declared in the catalog's `ATOMS.yml`. An atom that fails signature validation is rejected. Deployment halts; no partial manifests are applied.

For `draft` atoms, signature validation MAY be skipped in non-production environments, but MUST NOT be skipped in production. This relaxation MUST be declared explicitly in the environment configuration.

### Lifecycle Gating

Olympus enforces lifecycle gating per environment:

| Environment tier | Minimum atom lifecycle |
|---|---|
| Development | `draft` |
| Staging | `published` |
| Production | `adopted` |

Attempting to deploy a `draft` atom to a staging or production environment fails validation at plan time. The operator must either promote the atom or declare an explicit lifecycle override in the environment manifest, which is itself a gated action requiring approval.

## Atom Lifecycle Integration

### Tracking

Olympus maintains a deployment manifest per environment that records:

- The atom IDs and versions currently deployed
- The timestamp of each deployment
- The identity that authorized the deployment
- The signature validation result for each atom

The manifest is itself signed and stored as an atom in the `olympus-deployments` catalog.

### Lifecycle Transitions

Olympus participates in the atom lifecycle as a consumer signal:

- When an atom is resolved and deployed to production, Olympus records a `consumption` event against the atom version.
- Catalog maintainers MAY use consumption signals to inform the transition from `published` to `adopted`.
- When an atom is `deprecated`, Olympus emits a warning on next resolution but does not block deployment. A `retired` atom blocks deployment and requires explicit override.

### Version Pinning

Olympus manifests pin atoms to exact versions. Wildcards and ranges are not permitted. Version promotion (e.g., upgrading from `@1.0.0` to `@1.1.0`) requires an explicit manifest update and a new signed deployment.

## Configuration Model

### Atoms as Immutable Configuration Units

An Olympus environment is defined as a set of atom references. Each reference is:

```toml
[[atom]]
id      = "schema-atoms/design-spec/ai-constitution-spec"
version = "1.0.0-draft"
role    = "governance"
```

The `role` field is Olympus-specific and declares how the atom is used in the environment. Roles are defined per workload type and are not part of the atom spec itself.

### Manifest Assembly

Olympus assembles a deployment manifest by:

1. Resolving each referenced atom (cache → canonical → mirror).
2. Validating each atom's signature.
3. Applying lifecycle gating for the target environment tier.
4. Composing the resolved atom content into the manifest according to the workload's manifest template.
5. Signing the assembled manifest.
6. Writing the manifest to the `olympus-deployments` catalog.

Assembly is atomic: either the full manifest is assembled and signed, or no manifest is written.

### Conflict Resolution

When two atoms referenced in the same manifest define overlapping configuration keys, the manifest MUST declare an explicit resolution strategy: `last-wins`, `first-wins`, or `error`. The default is `error` — Olympus rejects manifests with unresolved conflicts at assembly time.

## Integration with atoms-tools CLI

Olympus delegates atom operations to `atoms-tools` rather than implementing resolution, signing, and verification itself. The integration surface is:

| Olympus operation | atoms-tools command |
|---|---|
| Resolve and cache an atom | `atoms validate <atom-path>` + cache write |
| Verify atom signature | `atoms verify <atom-path>` |
| Promote atom lifecycle | `atoms publish <atom-path>` |
| Compute content hash | `atoms canonicalize <atom-path>` |
| Purge stale cache entry | `atoms cache purge <atom-id>` |

The `atoms-tools` binary MUST be present and on `$PATH` for Olympus to function. The required minimum version is declared in the Olympus workload configuration.

## Environment Configuration

Olympus reads its runtime configuration from `~/.atoms/config.toml` (shared with atoms-tools) and from an environment-specific manifest file. Required fields:

```toml
[olympus]
environment   = "development"          # development | staging | production
catalog       = "schema-atoms"         # default catalog for resolution
cache_path    = "~/.atoms/cache"       # local cache root
atoms_tools   = "atoms"               # path or name of atoms-tools binary
```

Production environments MUST additionally declare:

```toml
[olympus.production]
require_adopted = true                 # enforce adopted lifecycle gate
require_signatures = true             # never skip signature validation
audit_log = "~/.atoms/audit/olympus.jsonl"
```

## Error Handling

Olympus uses structured exit codes consistent with atoms-tools:

| Code | Meaning |
|---|---|
| 0 | Success |
| 1 | Validation failure (atom malformed, lifecycle gate, conflict) |
| 2 | Signing failure (missing key, quorum not met) |
| 3 | Network error (canonical domain and all mirrors unreachable) |
| 4 | Manifest assembly failure (conflict, template error) |
| 5 | Signature verification failure |

All errors are logged as structured JSON to stderr and, in production, to the audit log.
