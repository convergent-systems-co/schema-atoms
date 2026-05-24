#!/usr/bin/env bash
# test-class-specs.sh — TDD guard for issues #139, #140, #141
# Taxonomy-spec class specifications: controlled-vocabulary, code-list, ontology
# Must FAIL (exit 1) before implementation (directories not yet created).
# Must PASS (exit 0) after implementation.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
FAILURES=0

pass() { echo "  PASS: $1"; }
fail() { echo "  FAIL: $1"; FAILURES=$((FAILURES + 1)); }

echo "=== test-class-specs: taxonomy-spec class specifications (#139, #140, #141) ==="
echo "REPO_ROOT=$REPO_ROOT"
echo ""

# ------------------------------------------------------------------
# Class 1: controlled-vocabulary (#139)
# ------------------------------------------------------------------
CV_DIR="$REPO_ROOT/compositions/design-spec/controlled-vocabulary-class-spec@1.0.0-draft"

echo "--- controlled-vocabulary atom.toml (#139)"
if test -f "$CV_DIR/atom.toml"; then
  pass "controlled-vocabulary-class-spec atom.toml exists"
else
  fail "controlled-vocabulary-class-spec atom.toml missing"
fi

echo "--- controlled-vocabulary spec.md (#139)"
if test -f "$CV_DIR/spec.md"; then
  pass "controlled-vocabulary-class-spec spec.md exists"
else
  fail "controlled-vocabulary-class-spec spec.md missing"
fi

echo "--- controlled-vocabulary atom.toml contains required keys (#139)"
if test -f "$CV_DIR/atom.toml" && \
   grep -q 'id' "$CV_DIR/atom.toml" && \
   grep -q 'version' "$CV_DIR/atom.toml" && \
   grep -q 'lifecycle' "$CV_DIR/atom.toml" && \
   grep -q '\[spec\]' "$CV_DIR/atom.toml"; then
  pass "controlled-vocabulary-class-spec atom.toml has required keys"
else
  fail "controlled-vocabulary-class-spec atom.toml missing required keys (id, version, lifecycle, [spec])"
fi

echo ""

# ------------------------------------------------------------------
# Class 2: code-list (#140)
# ------------------------------------------------------------------
CL_DIR="$REPO_ROOT/compositions/design-spec/code-list-class-spec@1.0.0-draft"

echo "--- code-list atom.toml (#140)"
if test -f "$CL_DIR/atom.toml"; then
  pass "code-list-class-spec atom.toml exists"
else
  fail "code-list-class-spec atom.toml missing"
fi

echo "--- code-list spec.md (#140)"
if test -f "$CL_DIR/spec.md"; then
  pass "code-list-class-spec spec.md exists"
else
  fail "code-list-class-spec spec.md missing"
fi

echo "--- code-list atom.toml contains required keys (#140)"
if test -f "$CL_DIR/atom.toml" && \
   grep -q 'id' "$CL_DIR/atom.toml" && \
   grep -q 'version' "$CL_DIR/atom.toml" && \
   grep -q 'lifecycle' "$CL_DIR/atom.toml" && \
   grep -q '\[spec\]' "$CL_DIR/atom.toml"; then
  pass "code-list-class-spec atom.toml has required keys"
else
  fail "code-list-class-spec atom.toml missing required keys (id, version, lifecycle, [spec])"
fi

echo ""

# ------------------------------------------------------------------
# Class 3: ontology (#141)
# ------------------------------------------------------------------
ON_DIR="$REPO_ROOT/compositions/design-spec/ontology-class-spec@1.0.0-draft"

echo "--- ontology atom.toml (#141)"
if test -f "$ON_DIR/atom.toml"; then
  pass "ontology-class-spec atom.toml exists"
else
  fail "ontology-class-spec atom.toml missing"
fi

echo "--- ontology spec.md (#141)"
if test -f "$ON_DIR/spec.md"; then
  pass "ontology-class-spec spec.md exists"
else
  fail "ontology-class-spec spec.md missing"
fi

echo "--- ontology atom.toml contains required keys (#141)"
if test -f "$ON_DIR/atom.toml" && \
   grep -q 'id' "$ON_DIR/atom.toml" && \
   grep -q 'version' "$ON_DIR/atom.toml" && \
   grep -q 'lifecycle' "$ON_DIR/atom.toml" && \
   grep -q '\[spec\]' "$ON_DIR/atom.toml"; then
  pass "ontology-class-spec atom.toml has required keys"
else
  fail "ontology-class-spec atom.toml missing required keys (id, version, lifecycle, [spec])"
fi

echo ""

# ------------------------------------------------------------------
# Summary
# ------------------------------------------------------------------
if [ "$FAILURES" -eq 0 ]; then
  echo "RESULT: PASS (0 failures)"
  exit 0
else
  echo "RESULT: FAIL ($FAILURES failures)"
  exit 1
fi
