#!/usr/bin/env python3
"""Validate atom.toml files in the schema-atoms catalog."""
import sys
import argparse
from pathlib import Path
try:
    import tomllib
except ImportError:
    import tomli as tomllib  # fallback for < 3.11

DESIGN_SPEC_REQUIRED_SPEC_FIELDS = ["class", "title", "summary", "authors", "conforms_to", "asset"]
AMENDMENTS_REQUIRED_FIELDS = ["date", "author", "summary"]

# Top-level keys that are part of the atom envelope, not the payload section.
ENVELOPE_KEYS = {"id", "version", "content_hash", "lifecycle", "created_at", "spec", "protocol"}

# Classes that require a [protocol] section (imported external-standards atoms).
REQUIRES_PROTOCOL = {"rfc", "w3c_spec", "iso_spec", "fips", "internal_protocol"}

# License values recognised by the catalog.
VALID_LICENSES = {
    "IETF Trust", "public-domain", "W3C", "ISO",
    "MIT", "Apache-2.0", "BSD-2-Clause", "BSD-3-Clause",
}

def find_atom_files(root: Path):
    for p in sorted(root.glob("compositions/*/*/atom.toml")):
        yield p

def validate_envelope(path: Path, data: dict, violations: list):
    for field in ["id", "version", "lifecycle", "created_at"]:
        if not data.get(field):
            violations.append(f"{path}: missing required envelope field '{field}'")

def validate_design_spec(path: Path, data: dict, violations: list):
    spec = data.get("spec")
    if not spec:
        violations.append(f"{path}: design-spec atom missing [spec] section")
        return
    for field in DESIGN_SPEC_REQUIRED_SPEC_FIELDS:
        val = spec.get(field)
        if val is None or val == "" or val == []:
            violations.append(f"{path}: [spec].{field} is required and non-empty")
    amendments = spec.get("amendments", [])
    for i, entry in enumerate(amendments):
        for field in AMENDMENTS_REQUIRED_FIELDS:
            if not entry.get(field):
                violations.append(f"{path}: [[spec.amendments]][{i}] missing '{field}'")

def validate_protocol_section(path: Path, data: dict, violations: list):
    """Validate the [protocol] section for atoms that carry one, and require it for external-standard classes."""
    protocol = data.get("protocol")

    # Determine the payload class by finding the first non-envelope top-level key.
    payload_key = next((k for k in data if k not in ENVELOPE_KEYS), None)
    class_name = ""
    if payload_key:
        payload = data.get(payload_key)
        if isinstance(payload, dict):
            class_name = payload.get("class", payload_key)
        else:
            class_name = payload_key

    # Normalise class name: hyphens and underscores are interchangeable.
    class_norm = class_name.replace("-", "_") if class_name else ""
    needs_protocol = class_norm in REQUIRES_PROTOCOL

    if needs_protocol and not protocol:
        violations.append(
            f"{path}: class '{class_name}' requires a [protocol] section"
        )
        return

    if not protocol:
        return

    # --- provenance ---
    prov = protocol.get("provenance", "")
    if not prov:
        violations.append(f"{path}: [protocol].provenance is required and must be non-empty")
    elif not (prov.startswith("http://") or prov.startswith("https://")):
        violations.append(
            f"{path}: [protocol].provenance must start with http:// or https://"
        )

    # --- license ---
    lic = protocol.get("license", "")
    if not lic:
        violations.append(f"{path}: [protocol].license is required and must be non-empty")
    elif lic not in VALID_LICENSES:
        violations.append(
            f"{path}: [protocol].license '{lic}' is not a recognized value; "
            f"expected one of {sorted(VALID_LICENSES)}"
        )


def resolve_conforms_to(root: Path, path: Path, data: dict, violations: list):
    spec = data.get("spec", {})
    ref = spec.get("conforms_to", "")
    if not ref:
        return
    # Format: schema-atoms/<class>/<slug>@<version>
    # Maps to: <root>/compositions/<class>/<slug>@<version>/atom.toml
    prefix = "schema-atoms/"
    if ref.startswith(prefix):
        rest = ref[len(prefix):]
        target = root / "compositions" / rest / "atom.toml"
        if not target.exists():
            violations.append(f"{path}: conforms_to '{ref}' not found at {target}")

def main():
    parser = argparse.ArgumentParser(description="Validate schema-atoms atom.toml files")
    parser.add_argument("--root", default=".", help="Repo root directory")
    args = parser.parse_args()
    root = Path(args.root).resolve()
    violations = []
    count = 0
    for atom_path in find_atom_files(root):
        count += 1
        with open(atom_path, "rb") as f:
            data = tomllib.load(f)
        rel = atom_path.relative_to(root)
        validate_envelope(rel, data, violations)
        spec = data.get("spec", {})
        if spec.get("class") == "design-spec":
            validate_design_spec(rel, data, violations)
        resolve_conforms_to(root, rel, data, violations)
        validate_protocol_section(rel, data, violations)
    print(f"Validated {count} atoms")
    if violations:
        for v in violations:
            print(f"  VIOLATION: {v}")
        sys.exit(1)
    print("OK")

if __name__ == "__main__":
    main()
