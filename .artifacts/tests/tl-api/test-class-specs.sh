#!/usr/bin/env bash
# test-class-specs.sh — TDD test for api-spec class specification atoms
# Must FAIL before coders write files; must PASS after.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
DESIGN_SPEC="$REPO_ROOT/compositions/design-spec"
PASS=0
FAIL=0

check_atom() {
  local dir="$1"
  local toml_path="$DESIGN_SPEC/$dir/atom.toml"
  local spec_path="$DESIGN_SPEC/$dir/spec.md"

  echo "--- Checking $dir ---"

  if [ ! -f "$toml_path" ]; then
    echo "FAIL: $toml_path not found"
    FAIL=$((FAIL + 1))
    return
  fi
  echo "  atom.toml: present"

  if ! python3 -c "
try:
    import tomllib
except ImportError:
    import tomli as tomllib
tomllib.load(open('$toml_path','rb'))
" 2>/dev/null; then
    echo "FAIL: $toml_path is not valid TOML"
    FAIL=$((FAIL + 1))
    return
  fi
  echo "  atom.toml: valid TOML"

  if [ ! -f "$spec_path" ]; then
    echo "FAIL: $spec_path not found"
    FAIL=$((FAIL + 1))
    return
  fi
  echo "  spec.md: present"

  PASS=$((PASS + 1))
  echo "  PASS"
}

check_atom "openapi-spec-class-spec@1.0.0-draft"
check_atom "asyncapi-spec-class-spec@1.0.0-draft"
check_atom "graphql-schema-class-spec@1.0.0-draft"
check_atom "grpc-spec-class-spec@1.0.0-draft"
check_atom "json-rpc-spec-class-spec@1.0.0-draft"

echo ""
echo "Results: $PASS passed, $FAIL failed"

if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
exit 0
