#!/usr/bin/env bash
# test-supersession.sh — TDD gate for spec→design-spec supersession (issues #146, #147)
# Must exit 1 before the atom.toml files are created.
# Must exit 0 after both files are created and valid.
set -euo pipefail

REPO_ROOT="$(git -C "$(dirname "$0")" rev-parse --show-toplevel)"
DESIGN_SPEC_TOML="$REPO_ROOT/compositions/design-spec/atom-spec@1.1.0/atom.toml"
SPEC_TOML="$REPO_ROOT/compositions/spec/atom-spec@1.1.0/atom.toml"

PASS=0
FAIL=0

check() {
  local desc="$1"
  local result="$2"  # 0=ok, 1=fail
  if [ "$result" -eq 0 ]; then
    echo "  PASS: $desc"
    PASS=$((PASS + 1))
  else
    echo "  FAIL: $desc"
    FAIL=$((FAIL + 1))
  fi
}

echo "=== Supersession test suite ==="
echo ""

# --- Check 1: design-spec atom.toml exists ---
echo "[ #146 design-spec/atom-spec@1.1.0 ]"
if [ -f "$DESIGN_SPEC_TOML" ]; then
  check "design-spec atom.toml exists" 0
else
  check "design-spec atom.toml exists" 1
fi

# --- Check 2: design-spec TOML is valid ---
if [ -f "$DESIGN_SPEC_TOML" ]; then
  if python3 -c "import tomllib; tomllib.load(open('$DESIGN_SPEC_TOML','rb'))" 2>/dev/null; then
    check "design-spec atom.toml is valid TOML" 0
  else
    check "design-spec atom.toml is valid TOML" 1
  fi
else
  check "design-spec atom.toml is valid TOML (skipped — file missing)" 1
fi

# --- Check 3: design-spec id correct ---
if [ -f "$DESIGN_SPEC_TOML" ]; then
  ID=$(python3 -c "import tomllib; d=tomllib.load(open('$DESIGN_SPEC_TOML','rb')); print(d.get('id',''))" 2>/dev/null)
  [ "$ID" = "schema-atoms/design-spec/atom-spec" ] && check "design-spec id=schema-atoms/design-spec/atom-spec" 0 || check "design-spec id=schema-atoms/design-spec/atom-spec (got: $ID)" 1
else
  check "design-spec id correct (skipped — file missing)" 1
fi

# --- Check 4: design-spec version=1.1.0 ---
if [ -f "$DESIGN_SPEC_TOML" ]; then
  VER=$(python3 -c "import tomllib; d=tomllib.load(open('$DESIGN_SPEC_TOML','rb')); print(d.get('version',''))" 2>/dev/null)
  [ "$VER" = "1.1.0" ] && check "design-spec version=1.1.0" 0 || check "design-spec version=1.1.0 (got: $VER)" 1
else
  check "design-spec version=1.1.0 (skipped — file missing)" 1
fi

# --- Check 5: design-spec lifecycle=draft ---
if [ -f "$DESIGN_SPEC_TOML" ]; then
  LC=$(python3 -c "import tomllib; d=tomllib.load(open('$DESIGN_SPEC_TOML','rb')); print(d.get('lifecycle',''))" 2>/dev/null)
  [ "$LC" = "draft" ] && check "design-spec lifecycle=draft" 0 || check "design-spec lifecycle=draft (got: $LC)" 1
else
  check "design-spec lifecycle=draft (skipped — file missing)" 1
fi

# --- Check 6: design-spec supersedes set correctly ---
if [ -f "$DESIGN_SPEC_TOML" ]; then
  SUP=$(python3 -c "import tomllib; d=tomllib.load(open('$DESIGN_SPEC_TOML','rb')); print(d.get('supersedes',''))" 2>/dev/null)
  [ "$SUP" = "schema-atoms/spec/atom-spec@1.1.0" ] && check "design-spec supersedes=schema-atoms/spec/atom-spec@1.1.0" 0 || check "design-spec supersedes correct (got: $SUP)" 1
else
  check "design-spec supersedes set (skipped — file missing)" 1
fi

# --- Check 7: design-spec [spec].class=design-spec ---
if [ -f "$DESIGN_SPEC_TOML" ]; then
  CLS=$(python3 -c "import tomllib; d=tomllib.load(open('$DESIGN_SPEC_TOML','rb')); print(d.get('spec',{}).get('class',''))" 2>/dev/null)
  [ "$CLS" = "design-spec" ] && check "design-spec [spec].class=design-spec" 0 || check "design-spec [spec].class=design-spec (got: $CLS)" 1
else
  check "design-spec [spec].class=design-spec (skipped — file missing)" 1
fi

# --- Check 8: design-spec [spec].conforms_to set ---
if [ -f "$DESIGN_SPEC_TOML" ]; then
  CT=$(python3 -c "import tomllib; d=tomllib.load(open('$DESIGN_SPEC_TOML','rb')); print(d.get('spec',{}).get('conforms_to',''))" 2>/dev/null)
  [ "$CT" = "schema-atoms/design-spec/atom-spec@1.1.0" ] && check "design-spec [spec].conforms_to=schema-atoms/design-spec/atom-spec@1.1.0" 0 || check "design-spec [spec].conforms_to correct (got: $CT)" 1
else
  check "design-spec [spec].conforms_to set (skipped — file missing)" 1
fi

echo ""

# --- Check 9: spec atom.toml exists ---
echo "[ #147 spec/atom-spec@1.1.0 ]"
if [ -f "$SPEC_TOML" ]; then
  check "spec atom.toml exists" 0
else
  check "spec atom.toml exists" 1
fi

# --- Check 10: spec TOML is valid ---
if [ -f "$SPEC_TOML" ]; then
  if python3 -c "import tomllib; tomllib.load(open('$SPEC_TOML','rb'))" 2>/dev/null; then
    check "spec atom.toml is valid TOML" 0
  else
    check "spec atom.toml is valid TOML" 1
  fi
else
  check "spec atom.toml is valid TOML (skipped — file missing)" 1
fi

# --- Check 11: spec id correct ---
if [ -f "$SPEC_TOML" ]; then
  ID=$(python3 -c "import tomllib; d=tomllib.load(open('$SPEC_TOML','rb')); print(d.get('id',''))" 2>/dev/null)
  [ "$ID" = "schema-atoms/spec/atom-spec" ] && check "spec id=schema-atoms/spec/atom-spec" 0 || check "spec id correct (got: $ID)" 1
else
  check "spec id correct (skipped — file missing)" 1
fi

# --- Check 12: spec version=1.1.0 ---
if [ -f "$SPEC_TOML" ]; then
  VER=$(python3 -c "import tomllib; d=tomllib.load(open('$SPEC_TOML','rb')); print(d.get('version',''))" 2>/dev/null)
  [ "$VER" = "1.1.0" ] && check "spec version=1.1.0" 0 || check "spec version=1.1.0 (got: $VER)" 1
else
  check "spec version=1.1.0 (skipped — file missing)" 1
fi

# --- Check 13: spec lifecycle=historic ---
if [ -f "$SPEC_TOML" ]; then
  LC=$(python3 -c "import tomllib; d=tomllib.load(open('$SPEC_TOML','rb')); print(d.get('lifecycle',''))" 2>/dev/null)
  [ "$LC" = "historic" ] && check "spec lifecycle=historic" 0 || check "spec lifecycle=historic (got: $LC)" 1
else
  check "spec lifecycle=historic (skipped — file missing)" 1
fi

# --- Check 14: spec superseded_by set correctly ---
if [ -f "$SPEC_TOML" ]; then
  SBY=$(python3 -c "import tomllib; d=tomllib.load(open('$SPEC_TOML','rb')); print(d.get('superseded_by',''))" 2>/dev/null)
  [ "$SBY" = "schema-atoms/design-spec/atom-spec@1.1.0" ] && check "spec superseded_by=schema-atoms/design-spec/atom-spec@1.1.0" 0 || check "spec superseded_by correct (got: $SBY)" 1
else
  check "spec superseded_by set (skipped — file missing)" 1
fi

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="

if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
exit 0
