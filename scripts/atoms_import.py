#!/usr/bin/env python3
"""
atoms import — Download a spec from URL, compute hash, scaffold atom.toml.

Usage:
  python3 scripts/atoms_import.py --url <url> --class <class> --slug <slug> --version <version> [options]

Examples:
  python3 scripts/atoms_import.py \\
    --url https://www.rfc-editor.org/rfc/rfc4648.txt \\
    --class rfc \\
    --slug rfc-4648 \\
    --version 1.0.0 \\
    --rfc-number 4648 \\
    --title "The Base16, Base32, and Base64 Data Encodings" \\
    --authors "S. Josefsson" \\
    --published-date "2006-10" \\
    --status STANDARDS_TRACK
"""
import sys
import hashlib
import argparse
import urllib.request
import urllib.error
from pathlib import Path
from datetime import datetime, timezone

COMPOSITIONS_DIR = Path(__file__).resolve().parent.parent / "compositions"

CLASS_EXTENSIONS = {
    'rfc': '.txt',
    'fips': '.txt',
    'w3c-spec': '.html',
    'iso-spec': '.txt',
    'internal-protocol': '.md',
    'ebnf-grammar': '.ebnf',
    'json-schema': '.json',
}

CLASS_SECTION_TEMPLATES = {
    'rfc': """[rfc]
rfc_number     = {rfc_number}
title          = "{title}"
authors        = [{authors_list}]
published_date = "{published_date}"
status         = "{status}"
asset          = "{asset_filename}"
""",
    'fips': """[fips]
fips_number    = {fips_number}
title          = "{title}"
published_date = "{published_date}"
status         = "FINAL"
asset          = "{asset_filename}"
""",
    'w3c-spec': """[w3c_spec]
title          = "{title}"
published_date = "{published_date}"
asset          = "{asset_filename}"
""",
    'default': """[{class_key}]
title          = "{title}"
published_date = "{published_date}"
asset          = "{asset_filename}"
""",
}


def download_url(url: str) -> bytes:
    print(f"  Downloading {url}...")
    req = urllib.request.Request(url, headers={'User-Agent': 'atoms-import/1.0 schema-atoms'})
    with urllib.request.urlopen(req, timeout=30) as resp:
        return resp.read()


def sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def make_authors_list(authors_str: str) -> str:
    authors = [a.strip() for a in authors_str.split(',')]
    return ', '.join(f'"{a}"' for a in authors)


def build_atom_toml(args, asset_filename: str, content_hash: str, created_at: str) -> str:
    class_key = args.atom_class.replace('-', '_')
    template = CLASS_SECTION_TEMPLATES.get(args.atom_class, CLASS_SECTION_TEMPLATES['default'])

    section = template.format(
        rfc_number=getattr(args, 'rfc_number', 0) or 0,
        fips_number=getattr(args, 'fips_number', 0) or 0,
        title=args.title or args.slug,
        authors_list=make_authors_list(args.authors) if args.authors else '"unknown"',
        published_date=args.published_date or '',
        status=args.status or 'INFORMATIONAL',
        asset_filename=asset_filename,
        class_key=class_key,
    )

    provenance = args.provenance or f"{args.url}"
    license_val = args.license or 'IETF Trust'

    return f"""id          = "schema-atoms/{args.atom_class}/{args.slug}"
version     = "{args.version}"
content_hash = "{content_hash}"
lifecycle   = "draft"
created_at  = "{created_at}"

{section}
[protocol]
provenance = "{provenance}"
license    = "{license_val}"
"""


def main():
    parser = argparse.ArgumentParser(description="Import a spec and scaffold an atom")
    parser.add_argument('--url', required=True, help='URL to download')
    parser.add_argument('--class', dest='atom_class', required=True,
                        help='Atom class (rfc, fips, w3c-spec, etc.)')
    parser.add_argument('--slug', required=True, help='Atom slug (e.g. rfc-4648)')
    parser.add_argument('--version', default='1.0.0', help='Atom version (default: 1.0.0)')
    parser.add_argument('--title', help='Spec title')
    parser.add_argument('--authors', help='Comma-separated author list')
    parser.add_argument('--published-date', help='Publication date (YYYY-MM)')
    parser.add_argument('--status',
                        help='Spec status (STANDARDS_TRACK, BCP, INFORMATIONAL, etc.)')
    parser.add_argument('--rfc-number', type=int, help='RFC number (for rfc class)')
    parser.add_argument('--fips-number', type=int, help='FIPS number (for fips class)')
    parser.add_argument('--provenance',
                        help='Full provenance string (default: derived from URL)')
    parser.add_argument('--license', help='License value (default: IETF Trust)')
    parser.add_argument('--ext', help='Asset file extension override')
    parser.add_argument('--dry-run', action='store_true',
                        help='Show what would be created without writing')
    args = parser.parse_args()

    # Determine output directory and asset filename
    atom_dir = COMPOSITIONS_DIR / args.atom_class / f"{args.slug}@{args.version}"
    ext = args.ext or CLASS_EXTENSIONS.get(args.atom_class, '.txt')
    asset_filename = f"{args.slug}{ext}"

    # Download
    try:
        content = download_url(args.url)
    except Exception as e:
        print(f"ERROR: download failed: {e}", file=sys.stderr)
        sys.exit(3)

    content_hash = sha256_bytes(content)
    created_at = datetime.now(timezone.utc).strftime('%Y-%m-%dT%H:%M:%SZ')

    atom_toml = build_atom_toml(args, asset_filename, content_hash, created_at)

    print(f"\n  Atom ID:  schema-atoms/{args.atom_class}/{args.slug}@{args.version}")
    print(f"  Asset:    {asset_filename} ({len(content):,} bytes)")
    print(f"  Hash:     {content_hash}")
    print(f"  Dir:      {atom_dir}")

    if args.dry_run:
        print("\n  [dry-run] Would create:")
        print(f"    {atom_dir}/atom.toml")
        print(f"    {atom_dir}/{asset_filename}")
        print("\n--- atom.toml preview ---")
        print(atom_toml)
        return

    atom_dir.mkdir(parents=True, exist_ok=True)

    (atom_dir / 'atom.toml').write_text(atom_toml, encoding='utf-8')
    (atom_dir / asset_filename).write_bytes(content)

    print(f"\n  Created:")
    print(f"    {atom_dir}/atom.toml")
    print(f"    {atom_dir}/{asset_filename}")
    print("\n  Review atom.toml and edit title/authors/metadata before committing.")


if __name__ == '__main__':
    main()
