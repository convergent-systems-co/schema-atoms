#!/usr/bin/env python3
"""Compute and write content_hash for all atoms with empty hashes."""
import sys
import hashlib
import re
import argparse
from pathlib import Path
from typing import Optional
try:
    import tomllib
except ImportError:
    import tomli as tomllib

ENVELOPE_KEYS = {'id', 'version', 'content_hash', 'lifecycle', 'created_at',
                 'supersedes', 'superseded_by', 'migration_notes', 'protocol'}


def find_atom_files(root: Path):
    for p in sorted(root.glob("compositions/*/*/atom.toml")):
        yield p


def find_payload_asset(data: dict) -> Optional[str]:
    """Return the primary asset filename from the first non-envelope payload section."""
    for key, val in data.items():
        if key not in ENVELOPE_KEYS and isinstance(val, dict):
            asset = val.get('asset') or val.get('asset_source')
            if asset:
                return str(asset)
    return None


def sha256_file(path: Path) -> str:
    h = hashlib.sha256()
    with open(path, 'rb') as f:
        for chunk in iter(lambda: f.read(65536), b''):
            h.update(chunk)
    return h.hexdigest()


def update_content_hash(toml_path: Path, new_hash: str) -> bool:
    """Replace content_hash = "" with the computed hash in the raw TOML text."""
    text = toml_path.read_text(encoding='utf-8')
    updated = re.sub(
        r'(content_hash\s*=\s*)"(?:)"',
        lambda m: f'{m.group(1)}"{new_hash}"',
        text,
    )
    if updated != text:
        toml_path.write_text(updated, encoding='utf-8')
        return True
    return False


def resolve_asset_path(atom_path: Path, data: dict) -> Optional[Path]:
    """
    Locate the asset file for an atom.

    Preference order:
    1. Primary 'asset' field (the rendered/canonical artifact).
    2. 'asset_source' field (the upstream source file).

    For atoms that carry both (e.g. RFC, FIPS), the primary 'asset' wins
    because it is the file the catalog actually distributes.
    """
    for key, val in data.items():
        if key not in ENVELOPE_KEYS and isinstance(val, dict):
            # Try primary asset first, fall back to asset_source.
            for field in ('asset', 'asset_source'):
                name = val.get(field)
                if name:
                    candidate = atom_path.parent / name
                    if candidate.exists():
                        return candidate
    return None


def main():
    parser = argparse.ArgumentParser(
        description="Compute and write content_hash for schema-atoms"
    )
    parser.add_argument('--root', default='.', help='Repo root')
    parser.add_argument('--dry-run', action='store_true', help='Report without writing')
    args = parser.parse_args()
    root = Path(args.root).resolve()

    updated = verified = skipped = violations = 0

    for atom_path in find_atom_files(root):
        with open(atom_path, 'rb') as f:
            data = tomllib.load(f)

        existing_hash = data.get('content_hash', '')
        asset_path = resolve_asset_path(atom_path, data)

        if asset_path is None:
            print(f"  SKIP (no asset): {atom_path.relative_to(root)}")
            skipped += 1
            continue

        computed = sha256_file(asset_path)

        if not existing_hash:
            if not args.dry_run:
                update_content_hash(atom_path, computed)
            print(f"  HASH: {atom_path.relative_to(root)} → {computed[:16]}...")
            updated += 1
        elif existing_hash == computed:
            verified += 1
        else:
            print(f"  VIOLATION: {atom_path.relative_to(root)} hash mismatch")
            print(f"    stored:   {existing_hash}")
            print(f"    computed: {computed}")
            violations += 1

    print(
        f"\nDone: {updated} updated, {verified} verified, "
        f"{skipped} skipped, {violations} violations"
    )
    if violations:
        sys.exit(1)


if __name__ == '__main__':
    main()
