# Atom Cache Spec

**Atom ID:** `schema-atoms/design-spec/atom-cache-spec`
**Version:** 1.0.0-draft
**Lifecycle:** draft
**Conforms to:** `schema-atoms/design-spec/atom-spec@1.1.0`

## Purpose

The Atom Cache Spec defines how atoms are cached locally by consumers — Olympus, ai-constitution tooling, atoms-tools, and any other system that resolves atom IDs — and how the cache is validated, expired, and purged.

The cache is a content-addressed local store. Its immutability contract ensures that a cached atom is never silently modified. Its TTL rules reflect the lifecycle of the atom: draft atoms are volatile; published and adopted atoms are permanent.

## Cache Key

The cache key is the full atom ID including version:

```
<catalog>/<class>/<slug>@<version>
```

Examples:

```
schema-atoms/design-spec/ai-constitution-spec@1.0.0-draft
schema-atoms/design-spec/atom-spec@1.1.0
```

The version string is part of the key. Two atoms with the same slug but different versions occupy separate cache entries and MUST NOT interfere with each other.

## Cache Storage Location

Cached atoms are stored on the local filesystem at:

```
~/.atoms/cache/<catalog>/<class>/<slug>@<version>/
```

Each cache entry is a directory containing the atom's files as fetched from the source:

```
~/.atoms/cache/schema-atoms/design-spec/atom-spec@1.1.0/
├── atom.toml
└── atom-spec@1.1.0.md
```

The directory structure mirrors the atom's layout at the source. No additional wrapper files are created by the cache layer.

### Configurable Root

The cache root defaults to `~/.atoms/cache` but MAY be overridden in `~/.atoms/config.toml`:

```toml
[cache]
path = "~/.atoms/cache"
```

System-wide deployments (e.g., CI runners) SHOULD override the cache root to a shared, read-only path to avoid redundant downloads across users.

## Immutability Contract

A cached atom MUST NOT be mutated after it is written. If a consumer requires a different version of an atom, it resolves and caches that version as a separate entry. The existing entry is not modified.

This contract ensures:

- Cache hits are always consistent. A read of a cache entry returns the same bytes every time.
- `content_hash` verification is reliable. The hash computed at cache-write time matches any future verification against the same entry.
- Concurrent consumers can read the same cache entry without locking.

The only permitted write operations on a cache entry are:

- Initial write when the entry does not yet exist.
- Purge (deletion of the entry directory).

Partial writes MUST NOT leave a corrupt entry. The write protocol is: write to a temporary directory, verify `content_hash`, then atomically rename the temporary directory to the final cache path.

## Cache Validation

### On Cache Hit

When a cache hit is detected, validation behavior depends on the atom's lifecycle:

| Lifecycle | Validation on cache hit |
|---|---|
| `draft` | Skip hash validation (draft atoms are mutable by definition) |
| `published` | Verify `content_hash` against the cached `atom.toml` |
| `adopted` | Verify `content_hash` against the cached `atom.toml` |
| `deprecated` | Verify `content_hash`; emit a deprecation warning |
| `retired` | Reject. Retired atoms MUST NOT be served from cache. |

If `content_hash` verification fails on a `published` or `adopted` atom, the cache entry is considered corrupt. The tool:

1. Logs a cache corruption warning to stderr.
2. Purges the corrupt entry.
3. Re-fetches the atom from the canonical source.
4. Verifies the freshly fetched atom's hash before writing it to cache.

If re-fetch and verification succeed, the operation continues. If they fail, the operation fails with exit code 1.

### content_hash Format

The `content_hash` field in `atom.toml` is a SHA-256 digest of the atom's canonical bytes, encoded as a lowercase hex string prefixed with `sha256:`:

```
content_hash = "sha256:e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
```

The canonical bytes are computed by `atoms canonicalize` — they are the sorted, whitespace-normalized concatenation of all asset file bytes in the atom directory, excluding `atom.toml` itself.

## TTL Rules

### Draft Atoms

Draft atoms have a default TTL of **1 hour**. After the TTL expires, the next access triggers a re-fetch from the canonical source. The TTL ensures that draft consumers pick up updates without requiring explicit cache purges during development.

The draft TTL is configurable:

```toml
[cache]
draft_ttl_seconds = 3600   # 1 hour default
```

Set `draft_ttl_seconds = 0` to disable draft TTL (always re-fetch). Set to `-1` to cache indefinitely (treat draft atoms as immutable for the session).

### Published and Adopted Atoms

Published and adopted atoms have **no TTL**. They are content-addressed and immutable: once a version is published, its content never changes. A cache hit for a `published` or `adopted` atom is permanent. Re-fetch is only triggered by:

- Cache corruption (failed `content_hash` verification).
- Explicit purge by the operator.

### Deprecated Atoms

Deprecated atoms inherit their previous TTL (none if they were published when deprecated). The deprecation warning is emitted on cache hit but does not trigger re-fetch.

## Mirror Resolution

When the canonical domain for a catalog is unreachable (DNS failure, HTTP 5xx, timeout), the cache layer consults `/mirror.toml` at the repo root for alternative sources:

```toml
[[mirror]]
catalog = "schema-atoms"
url     = "https://mirror.example.com/atoms/"
priority = 1

[[mirror]]
catalog = "schema-atoms"
url     = "https://cdn.example.net/schema-atoms/"
priority = 2
```

Mirrors are tried in ascending priority order. The first mirror that returns a valid, verifiable response is used. The fetched atom is validated (hash, signature) before being written to cache.

If no mirror is reachable, the operation fails with exit code 3 (network error).

Mirrors MUST serve atoms byte-for-byte identical to the canonical source. A mirror that serves a modified atom fails hash verification and is skipped. Persistent mirror failures MAY be reported to the catalog maintainer.

## Cache Purge

### Purge a Specific Entry

```bash
atoms cache purge <atom-id>
```

Removes the cache directory for the specified atom ID. If the entry does not exist, the command succeeds silently (idempotent).

Examples:

```bash
atoms cache purge schema-atoms/design-spec/atom-spec@1.1.0
atoms cache purge schema-atoms/design-spec/ai-constitution-spec@1.0.0-draft
```

### Purge All Entries

```bash
atoms cache purge --all
```

Removes the entire cache root directory and recreates it as an empty directory. This operation requires explicit confirmation when run interactively. In non-interactive mode (CI, scripts), `--yes` is required:

```bash
atoms cache purge --all --yes
```

### Purge by Lifecycle

```bash
atoms cache purge --lifecycle draft
```

Removes all cached entries whose `atom.toml` declares the specified lifecycle. Useful for clearing stale draft atoms during development without discarding published or adopted entries.

## Cache Inspection

```bash
atoms cache list
```

Lists all cache entries with their lifecycle, cached-at timestamp, and TTL status (fresh, expired, permanent). Output is structured (JSON with `--json`, human-readable table by default).

```bash
atoms cache inspect <atom-id>
```

Prints the full cache metadata for a specific entry: path, lifecycle, `content_hash`, cached-at, TTL status, and the result of the last hash verification.
