#!/usr/bin/env bash
# test-issue-120.sh — Verify compositions/ scaffold and schemas/ removal
# Issue: #120
# Must FAIL (exit 1) before fix, PASS (exit 0) after fix.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
PASS=0
FAIL=0

ok()   { echo "  PASS: $*"; PASS=$((PASS+1)); }
fail() { echo "  FAIL: $*"; FAIL=$((FAIL+1)); }

echo "=== test-issue-120: compositions/ scaffold + schemas/ removal ==="
echo "REPO_ROOT=$REPO_ROOT"
echo ""

# ------------------------------------------------------------------
# 1. compositions/ directory exists
# ------------------------------------------------------------------
echo "--- Test 1: compositions/ directory exists"
if test -d "$REPO_ROOT/compositions/"; then
  ok "compositions/ exists"
else
  fail "compositions/ does not exist"
fi

# ------------------------------------------------------------------
# 2. Spot-check: design-spec
# ------------------------------------------------------------------
echo "--- Test 2: compositions/design-spec/.gitkeep exists"
if test -f "$REPO_ROOT/compositions/design-spec/.gitkeep"; then
  ok "compositions/design-spec/.gitkeep exists"
else
  fail "compositions/design-spec/.gitkeep missing"
fi

# ------------------------------------------------------------------
# 3. Spot-check: rfc
# ------------------------------------------------------------------
echo "--- Test 3: compositions/rfc/.gitkeep exists"
if test -f "$REPO_ROOT/compositions/rfc/.gitkeep"; then
  ok "compositions/rfc/.gitkeep exists"
else
  fail "compositions/rfc/.gitkeep missing"
fi

# ------------------------------------------------------------------
# 4. Spot-check: code-list
# ------------------------------------------------------------------
echo "--- Test 4: compositions/code-list/.gitkeep exists"
if test -f "$REPO_ROOT/compositions/code-list/.gitkeep"; then
  ok "compositions/code-list/.gitkeep exists"
else
  fail "compositions/code-list/.gitkeep missing"
fi

# ------------------------------------------------------------------
# 5. schemas/ must be gone
# ------------------------------------------------------------------
echo "--- Test 5: schemas/ directory must NOT exist"
if test ! -d "$REPO_ROOT/schemas/"; then
  ok "schemas/ is absent (correctly removed)"
else
  fail "schemas/ still exists — must be removed"
fi

# ------------------------------------------------------------------
# 6. All 24 class directories must exist
# ------------------------------------------------------------------
echo "--- Test 6: All 24 class directories exist under compositions/"
CLASSES=(
  design-spec
  openapi-spec
  asyncapi-spec
  graphql-schema
  grpc-spec
  json-rpc-spec
  json-schema
  protobuf-schema
  avro-schema
  xml-schema
  toml-schema
  rfc
  w3c-spec
  iso-spec
  fips
  internal-protocol
  bnf-grammar
  ebnf-grammar
  language-reference
  query-language-spec
  regex-spec
  ontology
  controlled-vocabulary
  code-list
)

for cls in "${CLASSES[@]}"; do
  if test -d "$REPO_ROOT/compositions/$cls"; then
    ok "compositions/$cls/ exists"
  else
    fail "compositions/$cls/ MISSING"
  fi
done

# ------------------------------------------------------------------
# 7. Each of the 24 class dirs contains .gitkeep
# ------------------------------------------------------------------
echo "--- Test 7: Each class dir contains .gitkeep"
for cls in "${CLASSES[@]}"; do
  if test -f "$REPO_ROOT/compositions/$cls/.gitkeep"; then
    ok "compositions/$cls/.gitkeep present"
  else
    fail "compositions/$cls/.gitkeep MISSING"
  fi
done

# ------------------------------------------------------------------
# 8. Exactly 24 .gitkeep files (no extras, no missing)
# ------------------------------------------------------------------
echo "--- Test 8: Exactly 24 .gitkeep files under compositions/"
if test -d "$REPO_ROOT/compositions/"; then
  COUNT=$(find "$REPO_ROOT/compositions/" -name ".gitkeep" | wc -l | tr -d ' ')
  if [ "$COUNT" -eq 24 ]; then
    ok ".gitkeep count = 24 (expected 24)"
  else
    fail ".gitkeep count = $COUNT (expected 24)"
  fi
else
  fail "compositions/ does not exist — cannot count .gitkeep files"
fi

# ------------------------------------------------------------------
# Summary
# ------------------------------------------------------------------
echo ""
echo "=== Results: PASS=$PASS  FAIL=$FAIL ==="
if [ "$FAIL" -eq 0 ]; then
  echo "RESULT: PASS"
  exit 0
else
  echo "RESULT: FAIL"
  exit 1
fi
