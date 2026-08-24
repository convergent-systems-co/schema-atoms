#!/usr/bin/env bash
# test-issue-10.sh — Verify SECURITY.md meets acceptance criteria for issue #10
# EXIT 0 = PASS, EXIT 1 = FAIL

set -euo pipefail

SECURITY_FILE="SECURITY.md"

if [[ ! -f "$SECURITY_FILE" ]]; then
  echo "FAIL: $SECURITY_FILE not found"
  exit 1
fi

# 1. No stub text remaining
if grep -q 'Replace this stub' "$SECURITY_FILE"; then
  echo "FAIL: stub text found ('Replace this stub' still present)"
  exit 1
fi

# 2. 72-hour acknowledgment SLA
if ! grep -qE '72 hour|72-hour|within 72' "$SECURITY_FILE"; then
  echo "FAIL: no 72-hour SLA"
  exit 1
fi

# 3. 90-day coordinated disclosure window
if ! grep -qE '90 day|90-day' "$SECURITY_FILE"; then
  echo "FAIL: no 90-day disclosure window"
  exit 1
fi

# 4. Security email address present
if ! grep -q 'security@convergent-systems.co' "$SECURITY_FILE"; then
  echo "FAIL: no email address (security@convergent-systems.co)"
  exit 1
fi

# 5. Scope statements present
if ! grep -qi 'in scope\|out of scope' "$SECURITY_FILE"; then
  echo "FAIL: no scope statement (in scope / out of scope)"
  exit 1
fi

echo "PASS"
