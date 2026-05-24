#!/usr/bin/env bash
# test-publish.sh — validates the 4 initial atoms published by feat/tl-publish-initial-atoms
# Exits 1 if any check fails.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
PASS=0
FAIL=0

check() {
  local label="$1"
  local result="$2"  # "ok" or "fail:<reason>"
  if [[ "$result" == "ok" ]]; then
    echo "  PASS  $label"
    ((PASS++)) || true
  else
    echo "  FAIL  $label — ${result#fail:}"
    ((FAIL++)) || true
  fi
}

assert_file() {
  local path="$1"
  if [[ -f "$path" ]]; then
    echo "ok"
  else
    echo "fail:file not found: $path"
  fi
}

assert_toml_valid() {
  local path="$1"
  if python3 -c "
import sys
try:
    import tomllib
except ImportError:
    import tomli as tomllib
with open('$path', 'rb') as f:
    tomllib.load(f)
" 2>/dev/null; then
    echo "ok"
  else
    echo "fail:invalid TOML: $path"
  fi
}

assert_yaml_valid() {
  local path="$1"
  if python3 -c "
import yaml, sys
with open('$path') as f:
    data = yaml.safe_load(f)
if data is None:
    sys.exit(1)
" 2>/dev/null; then
    echo "ok"
  else
    echo "fail:invalid or empty YAML: $path"
  fi
}

assert_no_stubs() {
  local path="$1"
  if grep -qiE 'TODO|FIXME|YOUR_CWD|PLACEHOLDER|stub' "$path" 2>/dev/null; then
    echo "fail:stub/placeholder text found in $path"
  else
    echo "ok"
  fi
}

assert_ebnf_nonempty() {
  local path="$1"
  local lines
  lines=$(wc -l < "$path" 2>/dev/null || echo 0)
  if [[ "$lines" -ge 10 ]]; then
    echo "ok"
  else
    echo "fail:grammar.ebnf appears too short ($lines lines) — expected at least 10"
  fi
}

# ── #142: atom-lifecycle-states ──────────────────────────────────────────────
echo "=== #142: controlled-vocabulary/atom-lifecycle-states@1.0.0 ==="
DIR142="$REPO_ROOT/compositions/controlled-vocabulary/atom-lifecycle-states@1.0.0"

check "atom.toml exists"       "$(assert_file    "$DIR142/atom.toml")"
check "atom.toml valid TOML"   "$(assert_toml_valid "$DIR142/atom.toml")"
check "values.yaml exists"     "$(assert_file    "$DIR142/values.yaml")"
check "values.yaml valid YAML" "$(assert_yaml_valid "$DIR142/values.yaml")"
check "no stubs in atom.toml"  "$(assert_no_stubs  "$DIR142/atom.toml")"
check "no stubs in values.yaml" "$(assert_no_stubs "$DIR142/values.yaml")"

# ── #143: signer-roles ───────────────────────────────────────────────────────
echo "=== #143: controlled-vocabulary/signer-roles@1.0.0 ==="
DIR143="$REPO_ROOT/compositions/controlled-vocabulary/signer-roles@1.0.0"

check "atom.toml exists"       "$(assert_file    "$DIR143/atom.toml")"
check "atom.toml valid TOML"   "$(assert_toml_valid "$DIR143/atom.toml")"
check "values.yaml exists"     "$(assert_file    "$DIR143/values.yaml")"
check "values.yaml valid YAML" "$(assert_yaml_valid "$DIR143/values.yaml")"
check "no stubs in atom.toml"  "$(assert_no_stubs  "$DIR143/atom.toml")"
check "no stubs in values.yaml" "$(assert_no_stubs "$DIR143/values.yaml")"

# ── #144: persona-domains ────────────────────────────────────────────────────
echo "=== #144: controlled-vocabulary/persona-domains@1.0.0 ==="
DIR144="$REPO_ROOT/compositions/controlled-vocabulary/persona-domains@1.0.0"

check "atom.toml exists"       "$(assert_file    "$DIR144/atom.toml")"
check "atom.toml valid TOML"   "$(assert_toml_valid "$DIR144/atom.toml")"
check "values.yaml exists"     "$(assert_file    "$DIR144/values.yaml")"
check "values.yaml valid YAML" "$(assert_yaml_valid "$DIR144/values.yaml")"
check "no stubs in atom.toml"  "$(assert_no_stubs  "$DIR144/atom.toml")"
check "no stubs in values.yaml" "$(assert_no_stubs "$DIR144/values.yaml")"

# ── #145: ebnf-grammar/toml-1-0 ─────────────────────────────────────────────
echo "=== #145: ebnf-grammar/toml-1-0@1.0.0 ==="
DIR145="$REPO_ROOT/compositions/ebnf-grammar/toml-1-0@1.0.0"

check "atom.toml exists"         "$(assert_file    "$DIR145/atom.toml")"
check "atom.toml valid TOML"     "$(assert_toml_valid "$DIR145/atom.toml")"
check "grammar.ebnf exists"      "$(assert_file    "$DIR145/grammar.ebnf")"
check "grammar.ebnf nonempty"    "$(assert_ebnf_nonempty "$DIR145/grammar.ebnf")"
check "no stubs in atom.toml"    "$(assert_no_stubs "$DIR145/atom.toml")"
check "no stubs in grammar.ebnf" "$(assert_no_stubs "$DIR145/grammar.ebnf")"

# ── Summary ──────────────────────────────────────────────────────────────────
echo ""
echo "Results: $PASS passed, $FAIL failed"
if [[ "$FAIL" -gt 0 ]]; then
  exit 1
fi
exit 0
