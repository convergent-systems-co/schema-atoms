#!/usr/bin/env python3
"""Build exports/catalog.json — reads ATOMS.yml for metadata."""
import json, sys
from datetime import datetime, timezone
from pathlib import Path
try:
    import jsonschema, yaml
except ImportError:
    print("error: pip install jsonschema pyyaml", file=sys.stderr); sys.exit(2)
REPO = Path(__file__).resolve().parent.parent
_cfg = yaml.safe_load((REPO / "ATOMS.yml").read_text())
CATALOG_NAME = _cfg.get("name", REPO.name)
CATALOG_VERSION = str(_cfg.get("version", "0.1.0"))
_comp = str(_cfg.get("composition_dir", "compositions")).rstrip("/")
COMPOSITIONS_DIR = REPO / _comp
SCHEMA_DIR = REPO / "schemas"
ATOMS_DIR = REPO / "atoms"
RULES_DIR = REPO / "rules"
EXPORT_PATH = REPO / "exports" / "catalog.json"
def load_v(name):
    p = SCHEMA_DIR / name
    if not p.exists(): return None
    return jsonschema.Draft202012Validator(json.loads(p.read_text()))
def collect(dp, v, label):
    if not dp.exists(): return []
    out = []
    for p in sorted(dp.rglob("*.json")):
        data = json.loads(p.read_text())
        if v:
            errs = list(v.iter_errors(data))
            if errs:
                print(f"✗ {p.relative_to(REPO)}: {errs[0].message}", file=sys.stderr); sys.exit(1)
        out.append(data)
    return out
atoms = collect(ATOMS_DIR, load_v("atom-v1.json"), "atom")
comps = collect(COMPOSITIONS_DIR, load_v("composition-v1.json"), "composition")
rules = collect(RULES_DIR, load_v("rule-v1.json"), "rule")
catalog = {"catalog": CATALOG_NAME, "version": CATALOG_VERSION,
           "built_at": datetime.now(timezone.utc).isoformat(timespec="seconds"),
           "atoms": atoms, "compositions": comps, "rules": rules}
EXPORT_PATH.parent.mkdir(parents=True, exist_ok=True)
EXPORT_PATH.write_text(json.dumps(catalog, indent=2, ensure_ascii=False) + "\n")
print(f"wrote {EXPORT_PATH.relative_to(REPO)} — {len(atoms)} atoms, {len(comps)} comps, {len(rules)} rules")
