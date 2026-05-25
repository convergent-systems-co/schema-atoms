#!/usr/bin/env bash
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
FAIL=0

# Test 1: script exists
if [ ! -f "$REPO_ROOT/scripts/canonicalize_atoms.py" ]; then
  echo "FAIL: scripts/canonicalize_atoms.py does not exist"; FAIL=1
fi

# Test 2: dry-run exits 0
if [ -f "$REPO_ROOT/scripts/canonicalize_atoms.py" ]; then
  if ! python3 "$REPO_ROOT/scripts/canonicalize_atoms.py" --root "$REPO_ROOT" --dry-run 2>&1; then
    echo "FAIL: dry-run exited non-zero"; FAIL=1
  fi
fi

# Test 3: after real run, no atom with a resolvable asset still has content_hash = ""
#         (atoms that have no asset file on disk are legitimately skipped)
if [ -f "$REPO_ROOT/scripts/canonicalize_atoms.py" ]; then
  OUTPUT=$(python3 "$REPO_ROOT/scripts/canonicalize_atoms.py" --root "$REPO_ROOT" 2>&1)
  echo "$OUTPUT"
  if echo "$OUTPUT" | grep -q "^  VIOLATION:"; then
    echo "FAIL: hash violations detected"; FAIL=1
  fi
  # Count atoms that were updated (HASH lines) — on first run this should be > 0,
  # on subsequent runs it will be 0; both are fine as long as violations = 0.
  UPDATED=$(echo "$OUTPUT" | grep -c "^  HASH:" || true)
  VERIFIED=$(echo "$OUTPUT" | grep -oP '(\d+) verified' | grep -oP '\d+' || echo 0)
  echo "PASS: $UPDATED hashed, $VERIFIED verified, no violations"
fi

# Test 4: running again exits 0 (idempotent — verifies hashes, no rewrites)
if [ -f "$REPO_ROOT/scripts/canonicalize_atoms.py" ]; then
  OUTPUT2=$(python3 "$REPO_ROOT/scripts/canonicalize_atoms.py" --root "$REPO_ROOT" 2>&1)
  echo "$OUTPUT2"
  if echo "$OUTPUT2" | grep -q "^  VIOLATION:"; then
    echo "FAIL: hash violations on second run (idempotency broken)"; FAIL=1
  fi
  # Second run should write nothing — all previously-updated hashes now verify
  SECOND_HASH=$(echo "$OUTPUT2" | grep -c "^  HASH:" || true)
  if [ "$SECOND_HASH" -gt 0 ]; then
    echo "FAIL: second run still wrote $SECOND_HASH hashes — not idempotent"; FAIL=1
  else
    echo "PASS: second run idempotent (0 rewrites)"
  fi
fi

[ $FAIL -eq 0 ] && echo "ALL TESTS PASSED" || exit 1
