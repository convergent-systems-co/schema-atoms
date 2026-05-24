#!/usr/bin/env python3
"""Validate json-schema atom.toml files in the schema-atoms catalog."""
import sys
import json
import argparse
from pathlib import Path
try:
    import tomllib
except ImportError:
    import tomli as tomllib  # fallback for Python < 3.11

SCHEMA_VERSION_MAP = {
    "draft-04": "http://json-schema.org/draft-04/schema#",
    "draft-06": "http://json-schema.org/draft-06/schema#",
    "draft-07": "http://json-schema.org/draft-07/schema#",
    "2019-09": "https://json-schema.org/draft/2019-09/schema",
    "2020-12": "https://json-schema.org/draft/2020-12/schema",
}


def find_json_schema_atoms(root: Path):
    for p in sorted(root.glob("compositions/json-schema/*/atom.toml")):
        yield p


def load_schema_asset(atom_dir: Path, asset_name: str):
    """Load JSON or YAML schema asset. Returns parsed dict or None."""
    asset_path = atom_dir / asset_name
    if not asset_path.exists():
        return None, f"asset file '{asset_name}' not found at {asset_path}"
    if asset_path.suffix == ".json":
        with open(asset_path) as f:
            return json.load(f), None
    # yaml: attempt json parse of yaml (simple cases only — avoids pyyaml dep)
    return None, f"YAML asset {asset_name} skipped (pyyaml not required; use .json for full validation)"


def validate_json_schema_atom(rel_path: Path, abs_path: Path, data: dict, violations: list):
    """Validate a single json-schema atom.

    rel_path — path relative to repo root (used in violation messages)
    abs_path — absolute path to atom.toml (used for filesystem access)
    """
    spec = data.get("spec", {})
    schema_version = spec.get("schema_version", "")
    root_schema_id = spec.get("root_schema_id", "")
    asset_name = spec.get("asset", "")

    if not schema_version:
        violations.append(f"{rel_path}: [spec].schema_version is required")
    if not root_schema_id:
        violations.append(f"{rel_path}: [spec].root_schema_id is required")
    if not asset_name:
        violations.append(f"{rel_path}: [spec].asset is required")

    if not (schema_version and root_schema_id and asset_name):
        return  # can't validate further without required fields

    atom_dir = abs_path.parent
    schema_data, err = load_schema_asset(atom_dir, asset_name)
    if err:
        if "skipped" in err:
            return  # yaml skip is informational, not a violation
        violations.append(f"{rel_path}: {err}")
        return

    # #67 — $id must match root_schema_id
    schema_id = schema_data.get("$id", "")
    if schema_id != root_schema_id:
        violations.append(
            f"{rel_path}: $id '{schema_id}' in schema asset does not match "
            f"spec.root_schema_id '{root_schema_id}'"
        )

    # #68 — $schema must match expected URI for schema_version
    expected_schema_uri = SCHEMA_VERSION_MAP.get(schema_version)
    actual_schema_uri = schema_data.get("$schema", "")
    if expected_schema_uri is None:
        violations.append(
            f"{rel_path}: unknown schema_version '{schema_version}'; "
            f"valid values: {', '.join(SCHEMA_VERSION_MAP.keys())}"
        )
    elif actual_schema_uri != expected_schema_uri:
        violations.append(
            f"{rel_path}: $schema '{actual_schema_uri}' does not match "
            f"expected '{expected_schema_uri}' for schema_version '{schema_version}'"
        )


def main():
    parser = argparse.ArgumentParser(description="Validate json-schema atom.toml files")
    parser.add_argument("--root", default=".", help="Repo root directory")
    args = parser.parse_args()
    root = Path(args.root).resolve()
    violations = []
    count = 0
    for atom_path in find_json_schema_atoms(root):
        count += 1
        with open(atom_path, "rb") as f:
            data = tomllib.load(f)
        spec = data.get("spec", {})
        if spec.get("class") == "json-schema":
            validate_json_schema_atom(
                atom_path.relative_to(root),
                atom_path,
                data,
                violations,
            )
    print(f"Validated {count} json-schema atoms")
    if violations:
        for v in violations:
            print(f"  VIOLATION: {v}")
        sys.exit(1)
    print("OK")


if __name__ == "__main__":
    main()
