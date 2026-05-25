#!/usr/bin/env bash
# test-provenance-validator.sh
# TL2 tests for the [protocol.provenance] block validator (issue #76).
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
VALIDATOR="$REPO_ROOT/scripts/validate_atoms.py"
FAIL=0

pass() { echo "PASS: $1"; }
fail() { echo "FAIL: $1"; FAIL=1; }

# ---------------------------------------------------------------------------
# Test 1: validator exits 0 on the real compositions tree.
# All existing atoms with [protocol] sections must be valid.
# ---------------------------------------------------------------------------
if python3 "$VALIDATOR" --root "$REPO_ROOT" >/dev/null 2>&1; then
  pass "validator exits 0 on real compositions tree"
else
  fail "validator found violations in real compositions tree"
  python3 "$VALIDATOR" --root "$REPO_ROOT" || true
fi

# ---------------------------------------------------------------------------
# Test 2: class=rfc with no [protocol] section must exit 1.
# ---------------------------------------------------------------------------
TMPDIR2=$(mktemp -d)
trap 'rm -rf "$TMPDIR2"' EXIT
mkdir -p "$TMPDIR2/compositions/rfc/rfc-9999@1.0.0"
cat > "$TMPDIR2/compositions/rfc/rfc-9999@1.0.0/atom.toml" <<'TOML'
id         = "test/rfc/rfc-9999"
version    = "1.0.0"
lifecycle  = "draft"
created_at = "2026-01-01T00:00:00Z"

[rfc]
rfc_number     = 9999
title          = "Test RFC — no protocol section"
authors        = ["Test Author"]
published_date = "2026-01"
status         = "INFORMATIONAL"
asset          = "rfc9999.md"
TOML
if python3 "$VALIDATOR" --root "$TMPDIR2" >/dev/null 2>&1; then
  fail "class=rfc without [protocol] section should exit 1"
else
  pass "class=rfc without [protocol] section exits 1"
fi
rm -rf "$TMPDIR2"
trap - EXIT

# ---------------------------------------------------------------------------
# Test 3: [protocol] present but provenance is missing must exit 1.
# ---------------------------------------------------------------------------
TMPDIR3=$(mktemp -d)
trap 'rm -rf "$TMPDIR3"' EXIT
mkdir -p "$TMPDIR3/compositions/rfc/rfc-9999@1.0.0"
cat > "$TMPDIR3/compositions/rfc/rfc-9999@1.0.0/atom.toml" <<'TOML'
id         = "test/rfc/rfc-9999"
version    = "1.0.0"
lifecycle  = "draft"
created_at = "2026-01-01T00:00:00Z"

[rfc]
rfc_number     = 9999
title          = "Test RFC — missing provenance"
authors        = ["Test Author"]
published_date = "2026-01"
status         = "INFORMATIONAL"
asset          = "rfc9999.md"

[protocol]
license = "IETF Trust"
TOML
if python3 "$VALIDATOR" --root "$TMPDIR3" >/dev/null 2>&1; then
  fail "[protocol] with missing provenance should exit 1"
else
  pass "[protocol] with missing provenance exits 1"
fi
rm -rf "$TMPDIR3"
trap - EXIT

# ---------------------------------------------------------------------------
# Test 4: provenance present but does not start with http must exit 1.
# ---------------------------------------------------------------------------
TMPDIR4=$(mktemp -d)
trap 'rm -rf "$TMPDIR4"' EXIT
mkdir -p "$TMPDIR4/compositions/rfc/rfc-9999@1.0.0"
cat > "$TMPDIR4/compositions/rfc/rfc-9999@1.0.0/atom.toml" <<'TOML'
id         = "test/rfc/rfc-9999"
version    = "1.0.0"
lifecycle  = "draft"
created_at = "2026-01-01T00:00:00Z"

[rfc]
rfc_number     = 9999
title          = "Test RFC — bad provenance URL"
authors        = ["Test Author"]
published_date = "2026-01"
status         = "INFORMATIONAL"
asset          = "rfc9999.md"

[protocol]
provenance = "rfc-editor.org/rfc/rfc9999 — Test RFC 9999."
license    = "IETF Trust"
TOML
if python3 "$VALIDATOR" --root "$TMPDIR4" >/dev/null 2>&1; then
  fail "provenance not starting with http should exit 1"
else
  pass "provenance not starting with http exits 1"
fi
rm -rf "$TMPDIR4"
trap - EXIT

# ---------------------------------------------------------------------------
# Test 5: unrecognised license value must exit 1.
# ---------------------------------------------------------------------------
TMPDIR5=$(mktemp -d)
trap 'rm -rf "$TMPDIR5"' EXIT
mkdir -p "$TMPDIR5/compositions/rfc/rfc-9999@1.0.0"
cat > "$TMPDIR5/compositions/rfc/rfc-9999@1.0.0/atom.toml" <<'TOML'
id         = "test/rfc/rfc-9999"
version    = "1.0.0"
lifecycle  = "draft"
created_at = "2026-01-01T00:00:00Z"

[rfc]
rfc_number     = 9999
title          = "Test RFC — bad license"
authors        = ["Test Author"]
published_date = "2026-01"
status         = "INFORMATIONAL"
asset          = "rfc9999.md"

[protocol]
provenance = "https://www.rfc-editor.org/rfc/rfc9999 — Test RFC 9999."
license    = "UNLICENSED"
TOML
if python3 "$VALIDATOR" --root "$TMPDIR5" >/dev/null 2>&1; then
  fail "unrecognised license value should exit 1"
else
  pass "unrecognised license value exits 1"
fi
rm -rf "$TMPDIR5"
trap - EXIT

# ---------------------------------------------------------------------------
# Result
# ---------------------------------------------------------------------------
[ $FAIL -eq 0 ] && echo "ALL TESTS PASSED" || { echo "SOME TESTS FAILED"; exit 1; }
