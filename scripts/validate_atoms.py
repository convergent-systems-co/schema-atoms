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
        validate_envelope(atom_path.relative_to(root), data, violations)
        spec = data.get("spec", {})
        if spec.get("class") == "design-spec":
            validate_design_spec(atom_path.relative_to(root), data, violations)
        resolve_conforms_to(root, atom_path.relative_to(root), data, violations)
    print(f"Validated {count} atoms")
    if violations:
        for v in violations:
            print(f"  VIOLATION: {v}")
        sys.exit(1)
    print("OK")

if __name__ == "__main__":
    main()
