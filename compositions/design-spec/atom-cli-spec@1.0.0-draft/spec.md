# Atom CLI Spec

**Atom ID:** `schema-atoms/design-spec/atom-cli-spec`
**Version:** 1.0.0-draft
**Lifecycle:** draft
**Conforms to:** `schema-atoms/design-spec/atom-spec@1.1.0`

## Purpose

`atoms-tools` is the command-line interface for creating, validating, signing, publishing, and importing atoms in schema-atoms catalogs. It is the primary operator-facing tool for atom lifecycle management and is the integration surface used by Olympus and other consumers for verification, canonicalization, and cache operations.

This spec defines the command surface, configuration model, and exit codes. It is normative for implementors of `atoms-tools` and for tooling (such as Olympus) that invokes it programmatically.

## Command Reference

### atoms validate

```
atoms validate [path]
```

Validates one or more `atom.toml` files against the atom-spec schema and any class-specific constraints.

- If `path` is a directory, validates all `atom.toml` files found recursively under it.
- If `path` is a file, validates that single `atom.toml`.
- If `path` is omitted, validates the current working directory.

Validation checks:

1. `atom.toml` is valid TOML.
2. Required fields (`id`, `version`, `lifecycle`, `created_at`, `[spec]`) are present and well-formed.
3. `id` matches the directory path relative to the catalog root.
4. `version` is a valid SemVer string, optionally suffixed with `-draft`.
5. `lifecycle` is one of: `draft`, `published`, `adopted`, `deprecated`, `retired`.
6. `[spec].class` is declared in the catalog's `ATOMS.yml`.
7. `[spec].asset` names a file that exists in the same directory as `atom.toml`.
8. `[spec].conforms_to` resolves to a known atom ID.
9. If `content_hash` is non-empty, it matches the hash of the atom's canonical bytes.

Exits 0 if all validated atoms pass. Exits 1 on any validation failure. Validation errors are written to stderr, structured as JSON with `--json`.

### atoms sign

```
atoms sign <atom-path> --key <key-id>
```

Signs the atom at `<atom-path>` using the key identified by `<key-id>`. The key MUST be registered in the catalog's `ATOMS.yml` and MUST NOT be revoked.

Procedure:

1. Runs `atoms validate` on the atom. Fails with exit code 1 if validation fails.
2. Runs `atoms canonicalize` to compute and write `content_hash` if it is empty.
3. Fetches the private key material from the configured backend (never logging key bytes).
4. Computes the ML-DSA signature over the atom's canonical bytes.
5. Appends a `[signature.<key-id>]` block to `atom.toml`.

If a `[signature.<key-id>]` block already exists for the specified key, the command fails with exit code 2 unless `--force` is passed, in which case the existing signature is replaced.

### atoms verify

```
atoms verify <atom-path>
```

Verifies that the atom at `<atom-path>` meets the quorum requirements declared in the catalog's `ATOMS.yml` for its class.

Procedure:

1. Reads the catalog's quorum rules for the atom's `[spec].class`.
2. For each `[signature.<key-id>]` block in `atom.toml`:
   a. Looks up the key's public fingerprint in `ATOMS.yml`.
   b. Checks that the key is not revoked.
   c. Verifies the signature `value` against the atom's canonical bytes.
3. Counts valid signatures by role.
4. Checks that each role's count meets or exceeds the quorum requirement.

Exits 0 if quorum is satisfied. Exits 5 if verification fails. Failure details (which signatures are invalid, which quorum requirements are unmet) are written to stderr.

### atoms publish

```
atoms publish <atom-path>
```

Transitions a `draft` atom to `published`. This is the only command that changes the `lifecycle` field.

Procedure:

1. Asserts the atom's current `lifecycle` is `draft`. Fails with exit code 1 otherwise.
2. Runs `atoms validate`.
3. Runs `atoms verify`. The atom MUST meet quorum before it can be published.
4. Sets `lifecycle = "published"` in `atom.toml`.
5. Sets `published_at = "<UTC ISO-8601 timestamp>"` in `atom.toml`.
6. Re-signs the atom with the catalog maintainer's default key (since `lifecycle` changed, the previous signature is now invalid).

The operator MUST commit the updated `atom.toml` to the catalog repository after publishing. `atoms publish` does not run `git commit`.

Transitioning from `published` to `adopted`, `deprecated`, or `retired` is performed by the catalog maintainer through direct `atom.toml` edits followed by re-signing. Future versions of this spec MAY introduce explicit subcommands for those transitions.

### atoms import

```
atoms import <url> [--class <class>] [--slug <slug>]
```

Downloads a protocol specification or standard from a known URL and assembles an atom around it.

Procedure:

1. Fetches the document at `<url>`.
2. Detects the document format (OpenAPI YAML/JSON, AsyncAPI, EBNF, etc.) from content type and file extension.
3. Infers `--class` from the detected format if not provided. Fails if the class cannot be inferred and `--class` is omitted.
4. Infers `--slug` from the URL path if not provided.
5. Creates the atom directory at the appropriate path under the catalog root.
6. Writes the downloaded document as the atom asset.
7. Writes a skeleton `atom.toml` with `lifecycle = "draft"`, `content_hash = ""`, and the inferred metadata.

The operator reviews and completes the skeleton `atom.toml`, then runs `atoms validate` and `atoms sign` before publishing.

`atoms import` MUST NOT write `content_hash` — that is the responsibility of `atoms canonicalize`.

### atoms canonicalize

```
atoms canonicalize <atom-path>
```

Computes the canonical bytes of the atom and writes the resulting SHA-256 hash to the `content_hash` field in `atom.toml`.

The canonical bytes are the sorted, whitespace-normalized concatenation of all asset file bytes in the atom directory, excluding `atom.toml` itself. Sorting is by filename, lexicographically ascending.

If `content_hash` is already set and matches the computed value, the command exits 0 without modifying the file. If `content_hash` is set and does not match, the command fails with exit code 1 unless `--force` is passed, in which case it overwrites the hash and logs a warning.

### atoms cache purge

```
atoms cache purge [<atom-id>] [--all] [--lifecycle <lifecycle>] [--yes]
```

Manages the local atom cache. See `atom-cache-spec@1.0.0-draft` for full semantics.

- `atoms cache purge <atom-id>` — removes the cache entry for the specified atom.
- `atoms cache purge --all` — clears the entire cache. Requires `--yes` in non-interactive mode.
- `atoms cache purge --lifecycle draft` — removes all cached entries with the specified lifecycle.

### atoms cache list

```
atoms cache list [--json]
```

Lists all cached atoms with their lifecycle, cached-at timestamp, and TTL status. See `atom-cache-spec@1.0.0-draft`.

### atoms cache inspect

```
atoms cache inspect <atom-id>
```

Prints full cache metadata for a specific atom. See `atom-cache-spec@1.0.0-draft`.

### atoms version

```
atoms version
```

Prints the `atoms-tools` version string to stdout in the form `atoms-tools <semver>`. Exits 0.

Example output:

```
atoms-tools 0.3.1
```

## Configuration

`atoms-tools` reads configuration from `~/.atoms/config.toml`. All fields are optional; the defaults below apply if the file does not exist.

```toml
[catalog]
default = "schema-atoms"        # default catalog when not specified by command
root    = "."                   # path to the local catalog repository root

[cache]
path              = "~/.atoms/cache"   # local cache root
draft_ttl_seconds = 3600               # TTL for draft atoms (1 hour)

[keys]
default_key     = ""            # key-id used when --key is omitted from atoms sign
default_backend = ""            # signing backend: "macos-keychain", "vault", "hsm", etc.

[output]
json = false                    # if true, all command output defaults to JSON
```

Per-project overrides MAY be placed in `<catalog-root>/.atoms/config.toml`. Per-project values take precedence over the user-level `~/.atoms/config.toml`.

## Global Flags

The following flags apply to all commands:

| Flag | Description |
|---|---|
| `--json` | Output structured JSON to stdout instead of human-readable text |
| `--quiet` | Suppress informational output; only errors and required output are written |
| `--verbose` | Increase output detail (may be specified multiple times) |
| `--catalog <path>` | Override the catalog root path for this invocation |
| `--config <path>` | Use an alternate config file instead of `~/.atoms/config.toml` |

## Exit Codes

| Code | Meaning |
|---|---|
| 0 | Success |
| 1 | Validation failure (malformed atom, lifecycle gate, content hash mismatch) |
| 2 | Signing failure (key not found, key revoked, backend error, quorum not met) |
| 3 | Network error (canonical domain and all mirrors unreachable during import or cache miss) |
| 4 | Configuration error (missing required config, unknown class, bad catalog root) |
| 5 | Signature verification failure (invalid signature, revoked key contributed, quorum not met) |

Exit codes are stable across minor versions. Adding new exit codes is a minor version bump; reassigning existing codes is a major version bump.

## Structured Output

When `--json` is passed (or `output.json = true` in config), all commands write a JSON object to stdout. The schema:

```json
{
  "ok": true,
  "command": "validate",
  "atoms": [
    {
      "id": "schema-atoms/design-spec/atom-spec@1.1.0",
      "path": "compositions/design-spec/atom-spec@1.1.0/atom.toml",
      "valid": true,
      "errors": []
    }
  ],
  "errors": []
}
```

On failure, `ok` is `false` and `errors` contains structured error objects with `code`, `message`, and `path` fields.

Errors are always written to stderr in human-readable form regardless of `--json`.
