#!/usr/bin/env bash
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
FAIL=0

# Test 1: validator script exists (will fail until created)
if [ ! -f "$REPO_ROOT/scripts/validate_atoms.py" ]; then
  echo "FAIL: scripts/validate_atoms.py does not exist"
  FAIL=1
fi

# Test 2: validator exits 0 on real compositions tree
if [ -f "$REPO_ROOT/scripts/validate_atoms.py" ]; then
  if ! python3 "$REPO_ROOT/scripts/validate_atoms.py" --root "$REPO_ROOT" 2>&1; then
    echo "FAIL: validator found violations in real compositions tree"
    FAIL=1
  fi
fi

# Test 3: validator exits 1 on atom missing spec.title
if [ -f "$REPO_ROOT/scripts/validate_atoms.py" ]; then
  TMPDIR_TEST=$(mktemp -d)
  mkdir -p "$TMPDIR_TEST/compositions/design-spec/test-atom@1.0.0"
  cat > "$TMPDIR_TEST/compositions/design-spec/test-atom@1.0.0/atom.toml" <<'TOML'
id = "test/design-spec/test-atom"
version = "1.0.0"
lifecycle = "draft"
created_at = "2026-01-01T00:00:00Z"

[spec]
class = "design-spec"
summary = "missing title"
authors = ["test"]
conforms_to = "schema-atoms/design-spec/atom-spec@1.1.0"
asset = "spec.md"
TOML
  if python3 "$REPO_ROOT/scripts/validate_atoms.py" --root "$TMPDIR_TEST" 2>&1; then
    echo "FAIL: validator should have exited 1 for missing spec.title"
    FAIL=1
  fi
  rm -rf "$TMPDIR_TEST"
fi

# Test 4: validator exits 1 on nonexistent conforms_to
if [ -f "$REPO_ROOT/scripts/validate_atoms.py" ]; then
  TMPDIR_TEST=$(mktemp -d)
  mkdir -p "$TMPDIR_TEST/compositions/design-spec/test-atom2@1.0.0"
  cat > "$TMPDIR_TEST/compositions/design-spec/test-atom2@1.0.0/atom.toml" <<'TOML'
id = "test/design-spec/test-atom2"
version = "1.0.0"
lifecycle = "draft"
created_at = "2026-01-01T00:00:00Z"

[spec]
class = "design-spec"
title = "Test Atom"
summary = "test"
authors = ["test"]
conforms_to = "schema-atoms/design-spec/nonexistent-atom@9.9.9"
asset = "spec.md"
TOML
  if python3 "$REPO_ROOT/scripts/validate_atoms.py" --root "$TMPDIR_TEST" 2>&1; then
    echo "FAIL: validator should exit 1 for nonexistent conforms_to"
    FAIL=1
  fi
  rm -rf "$TMPDIR_TEST"
fi

[ $FAIL -eq 0 ] && echo "ALL TESTS PASSED" || exit 1
