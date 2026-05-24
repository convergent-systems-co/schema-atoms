#!/usr/bin/env bash
# test-class-specs.sh
# TDD tests for issues #135, #136, #137, #138
# Language-spec class specification design-spec atoms.
# Must FAIL (exit 1) before implementation, PASS (exit 0) after.

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
DESIGN_SPEC_DIR="$REPO_ROOT/compositions/design-spec"

echo "=== TDD: language-spec class specs (issues #135 #136 #137 #138) ==="
echo "Repo root: $REPO_ROOT"
echo "Design-spec dir: $DESIGN_SPEC_DIR"
echo ""

PASS=0
FAIL=0

check() {
  local desc="$1"
  local result="$2"
  if [ "$result" = "0" ]; then
    echo "  PASS: $desc"
    PASS=$((PASS + 1))
  else
    echo "  FAIL: $desc"
    FAIL=$((FAIL + 1))
  fi
}

# Test 1: ebnf-grammar-class-spec atom.toml exists (#135)
[ -f "$DESIGN_SPEC_DIR/ebnf-grammar-class-spec@1.0.0-draft/atom.toml" ]; check "ebnf-grammar-class-spec@1.0.0-draft/atom.toml exists" $?

# Test 2: language-reference-class-spec atom.toml exists (#136)
[ -f "$DESIGN_SPEC_DIR/language-reference-class-spec@1.0.0-draft/atom.toml" ]; check "language-reference-class-spec@1.0.0-draft/atom.toml exists" $?

# Test 3: query-language-spec-class-spec atom.toml exists (#137)
[ -f "$DESIGN_SPEC_DIR/query-language-spec-class-spec@1.0.0-draft/atom.toml" ]; check "query-language-spec-class-spec@1.0.0-draft/atom.toml exists" $?

# Test 4: regex-spec-class-spec atom.toml exists (#138)
[ -f "$DESIGN_SPEC_DIR/regex-spec-class-spec@1.0.0-draft/atom.toml" ]; check "regex-spec-class-spec@1.0.0-draft/atom.toml exists" $?

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="

if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
exit 0
