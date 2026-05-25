#!/usr/bin/env bash
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
FAIL=0

# Test 1: script exists
if [ ! -f "$REPO_ROOT/scripts/atoms_import.py" ]; then
  echo "FAIL: scripts/atoms_import.py does not exist"; FAIL=1
fi

# Test 2: --help exits 0
if [ -f "$REPO_ROOT/scripts/atoms_import.py" ]; then
  if ! python3 "$REPO_ROOT/scripts/atoms_import.py" --help > /dev/null 2>&1; then
    echo "FAIL: --help exited non-zero"; FAIL=1
  fi
fi

# Test 3: dry-run with a local file URL
if [ -f "$REPO_ROOT/scripts/atoms_import.py" ]; then
  TMPFILE=$(mktemp /tmp/test-spec-XXXXX.txt)
  echo "test spec content for atoms import" > "$TMPFILE"
  LOCAL_URL="file://$TMPFILE"
  if ! python3 "$REPO_ROOT/scripts/atoms_import.py" \
    --url "$LOCAL_URL" \
    --class rfc \
    --slug rfc-test \
    --version 1.0.0 \
    --title "Test RFC" \
    --dry-run 2>&1 | grep -q "dry-run"; then
    echo "FAIL: dry-run did not print expected output"; FAIL=1
  fi
  rm -f "$TMPFILE"
fi

# Test 4: real run creates files
if [ -f "$REPO_ROOT/scripts/atoms_import.py" ]; then
  TMPFILE=$(mktemp /tmp/test-spec-XXXXX.txt)
  echo "test spec content" > "$TMPFILE"
  LOCAL_URL="file://$TMPFILE"
  python3 "$REPO_ROOT/scripts/atoms_import.py" \
    --url "$LOCAL_URL" \
    --class rfc \
    --slug rfc-import-test \
    --version 1.0.0 \
    --title "Import Test RFC" 2>&1
  if [ ! -f "$REPO_ROOT/compositions/rfc/rfc-import-test@1.0.0/atom.toml" ]; then
    echo "FAIL: atom.toml not created"; FAIL=1
  else
    echo "PASS: atom.toml created"
    # Clean up test atom
    rm -rf "$REPO_ROOT/compositions/rfc/rfc-import-test@1.0.0"
  fi
  rm -f "$TMPFILE"
fi

[ $FAIL -eq 0 ] && echo "ALL TESTS PASSED" || exit 1
