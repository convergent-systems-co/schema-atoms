#!/usr/bin/env bash
# test-issues-123-124.sh
# TDD tests for issues #123 and #124 — catalog export JSON files and mirror.toml
# Must FAIL before implementation, PASS after.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
WEB_DIR="$REPO_ROOT/web"
DIST_DIR="$WEB_DIR/dist"

echo "=== TDD: issues #123 and #124 ==="
echo "Repo root: $REPO_ROOT"
echo "Running build..."

cd "$WEB_DIR" && npm run build 2>/dev/null
echo "Build complete."

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

# Test 1: catalog.json exists
[ -f "$DIST_DIR/exports/catalog.json" ]
check "dist/exports/catalog.json exists" $?

# Test 2: by-class.json exists
[ -f "$DIST_DIR/exports/by-class.json" ]
check "dist/exports/by-class.json exists" $?

# Test 3: by-lifecycle.json exists
[ -f "$DIST_DIR/exports/by-lifecycle.json" ]
check "dist/exports/by-lifecycle.json exists" $?

# Test 4: mirror.toml exists
[ -f "$DIST_DIR/mirror.toml" ]
check "dist/mirror.toml exists" $?

# Test 5: catalog.json is valid JSON
python3 -c "import json; json.load(open('$DIST_DIR/exports/catalog.json'))" 2>/dev/null
check "catalog.json is valid JSON" $?

# Test 6: by-class.json is valid JSON
python3 -c "import json; json.load(open('$DIST_DIR/exports/by-class.json'))" 2>/dev/null
check "by-class.json is valid JSON" $?

# Test 7: by-lifecycle.json is valid JSON
python3 -c "import json; json.load(open('$DIST_DIR/exports/by-lifecycle.json'))" 2>/dev/null
check "by-lifecycle.json is valid JSON" $?

# Test 8: mirror.toml is non-empty and contains schema-atoms
grep -q "schema-atoms" "$DIST_DIR/mirror.toml" 2>/dev/null
check "mirror.toml contains 'schema-atoms'" $?

# Test 9: catalog.json is an array or object (not null, not bare string)
python3 -c "
import json
data = json.load(open('$DIST_DIR/exports/catalog.json'))
assert isinstance(data, (list, dict)), f'Expected list or dict, got {type(data)}'
print('catalog type:', type(data).__name__)
" 2>/dev/null
check "catalog.json is array or object" $?

# Test 10: by-class.json is an object
python3 -c "
import json
data = json.load(open('$DIST_DIR/exports/by-class.json'))
assert isinstance(data, dict), f'Expected dict, got {type(data)}'
" 2>/dev/null
check "by-class.json is an object" $?

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="

if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
exit 0
