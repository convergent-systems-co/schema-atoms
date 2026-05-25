# scripts/

Utility scripts for the schema-atoms catalog. All scripts are Python 3.11+ and require no
external dependencies beyond what is listed per-script.

---

## validate_atoms.py

Validates every `atom.toml` in `compositions/` against the catalog envelope rules.

**Usage:**

```bash
python3 scripts/validate_atoms.py [--root <repo-root>]
```

**What it checks:**

- Required envelope fields: `id`, `version`, `content_hash`, `lifecycle`, `created_at`
- `lifecycle` is one of the recognised values
- Classes that require a `[protocol]` section (`rfc`, `fips`, `w3c_spec`, `iso_spec`,
  `internal_protocol`) have one, with valid `provenance` and `license` fields
- No extra top-level keys outside the known envelope set

Exits `0` when all atoms pass, `1` when any violation is found.

---

## validate_json_schema.py

Validates `json-schema` class atoms: checks that the referenced asset is a parseable JSON
Schema document and that required `[json_schema]` fields are present.

**Usage:**

```bash
python3 scripts/validate_json_schema.py [--root <repo-root>]
```

Exits `0` on success, `1` on violation.

---

## atoms_import.py

Downloads a specification from a URL, computes its SHA-256 hash, and scaffolds an
`atom.toml` + asset file ready for authoring. Replaces the manual download-hash-write cycle.

**Usage:**

```bash
python3 scripts/atoms_import.py \
  --url <url> \
  --class <class> \
  --slug <slug> \
  --version <version> \
  [--title <title>] \
  [--authors "Author A, Author B"] \
  [--published-date YYYY-MM] \
  [--status <status>] \
  [--rfc-number <n>] \
  [--fips-number <n>] \
  [--provenance <string>] \
  [--license <string>] \
  [--ext <.ext>] \
  [--dry-run]
```

**Arguments:**

| Flag | Required | Description |
|---|---|---|
| `--url` | yes | URL of the spec to download |
| `--class` | yes | Atom class: `rfc`, `fips`, `w3c-spec`, `iso-spec`, `internal-protocol`, `ebnf-grammar`, `json-schema`, etc. |
| `--slug` | yes | Atom slug, e.g. `rfc-4648` |
| `--version` | no | Atom version (default: `1.0.0`) |
| `--title` | no | Human-readable spec title |
| `--authors` | no | Comma-separated author list |
| `--published-date` | no | Publication date (`YYYY-MM`) |
| `--status` | no | Spec status: `STANDARDS_TRACK`, `BCP`, `INFORMATIONAL`, `FINAL`, etc. |
| `--rfc-number` | no | RFC number (for `rfc` class atoms) |
| `--fips-number` | no | FIPS number (for `fips` class atoms) |
| `--provenance` | no | Full provenance string (defaults to the download URL) |
| `--license` | no | License value (defaults to `IETF Trust`) |
| `--ext` | no | Override the asset file extension |
| `--dry-run` | no | Print what would be created without writing any files |

**Output:**

Creates `compositions/<class>/<slug>@<version>/atom.toml` and the downloaded asset file.
The `atom.toml` is populated with the computed `content_hash` and a `draft` lifecycle.
Edit the generated file to add any class-specific fields (`obsoletes`, `short_name`,
`algorithm`, etc.) before committing.

**Example — RFC 4648:**

```bash
python3 scripts/atoms_import.py \
  --url https://www.rfc-editor.org/rfc/rfc4648.txt \
  --class rfc \
  --slug rfc-4648 \
  --version 1.0.0 \
  --rfc-number 4648 \
  --title "The Base16, Base32, and Base64 Data Encodings" \
  --authors "S. Josefsson" \
  --published-date "2006-10" \
  --status STANDARDS_TRACK
```

**Example — NIST FIPS (dry-run first):**

```bash
python3 scripts/atoms_import.py \
  --url https://doi.org/10.6028/NIST.FIPS.186-5 \
  --class fips \
  --slug fips-186-5 \
  --version 1.0.0 \
  --fips-number 186 \
  --title "Digital Signature Standard (DSS)" \
  --published-date "2023-02" \
  --license public-domain \
  --dry-run
```

---

## Shell scripts

### dev-up.sh

Starts local development services (runs `docker compose up` and related setup). See inline
comments for prerequisites.

### release.sh

Cuts a catalog release: bumps versions, tags, and publishes. Requires write access to the
remote and a configured `PACKAGE_PUBLISH_TOKEN`.

### tf-plan.sh

Runs `terraform plan` against the configured workspace. Requires Terraform CLI and valid
cloud credentials.
