#!/usr/bin/env bash
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
FAIL=0

# Test 1: class spec atom.toml must exist
if [ ! -f "$REPO_ROOT/compositions/design-spec/json-schema-class-spec@1.0.0-draft/atom.toml" ]; then
  echo "FAIL: compositions/design-spec/json-schema-class-spec@1.0.0-draft/atom.toml does not exist"
  FAIL=1
fi

# Test 2: class spec spec.md must exist
if [ ! -f "$REPO_ROOT/compositions/design-spec/json-schema-class-spec@1.0.0-draft/spec.md" ]; then
  echo "FAIL: compositions/design-spec/json-schema-class-spec@1.0.0-draft/spec.md does not exist"
  FAIL=1
fi

# Test 3: validator script must exist
if [ ! -f "$REPO_ROOT/scripts/validate_json_schema.py" ]; then
  echo "FAIL: scripts/validate_json_schema.py does not exist"
  FAIL=1
fi

# Test 4: validator exits 0 on empty json-schema dir (no atoms yet)
if [ -f "$REPO_ROOT/scripts/validate_json_schema.py" ]; then
  if ! python3 "$REPO_ROOT/scripts/validate_json_schema.py" --root "$REPO_ROOT" 2>&1; then
    echo "FAIL: validator should exit 0 when no json-schema atoms exist"
    FAIL=1
  fi
fi

# Test 5: validator exits 1 on atom with mismatched $id
if [ -f "$REPO_ROOT/scripts/validate_json_schema.py" ]; then
  TMPDIR_TEST=$(mktemp -d)
  mkdir -p "$TMPDIR_TEST/compositions/json-schema/test-schema@1.0.0"
  cat > "$TMPDIR_TEST/compositions/json-schema/test-schema@1.0.0/atom.toml" <<'TOML'
id = "test/json-schema/test-schema"
version = "1.0.0"
lifecycle = "draft"
created_at = "2026-01-01T00:00:00Z"

[spec]
class = "json-schema"
schema_version = "2020-12"
root_schema_id = "https://schema-atoms.com/json-schema/correct-id/1.0.0"
asset = "schema.json"
TOML
  cat > "$TMPDIR_TEST/compositions/json-schema/test-schema@1.0.0/schema.json" <<'JSON'
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "https://schema-atoms.com/json-schema/WRONG-id/1.0.0"
}
JSON
  if python3 "$REPO_ROOT/scripts/validate_json_schema.py" --root "$TMPDIR_TEST" 2>&1; then
    echo "FAIL: validator should exit 1 for mismatched \$id"
    FAIL=1
  fi
  rm -rf "$TMPDIR_TEST"
fi

# Test 6: validator exits 1 on atom with mismatched schema_version
if [ -f "$REPO_ROOT/scripts/validate_json_schema.py" ]; then
  TMPDIR_TEST=$(mktemp -d)
  mkdir -p "$TMPDIR_TEST/compositions/json-schema/test-schema2@1.0.0"
  cat > "$TMPDIR_TEST/compositions/json-schema/test-schema2@1.0.0/atom.toml" <<'TOML'
id = "test/json-schema/test-schema2"
version = "1.0.0"
lifecycle = "draft"
created_at = "2026-01-01T00:00:00Z"

[spec]
class = "json-schema"
schema_version = "draft-07"
root_schema_id = "https://schema-atoms.com/json-schema/test-schema2/1.0.0"
asset = "schema.json"
TOML
  cat > "$TMPDIR_TEST/compositions/json-schema/test-schema2@1.0.0/schema.json" <<'JSON'
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "https://schema-atoms.com/json-schema/test-schema2/1.0.0"
}
JSON
  if python3 "$REPO_ROOT/scripts/validate_json_schema.py" --root "$TMPDIR_TEST" 2>&1; then
    echo "FAIL: validator should exit 1 for mismatched schema_version"
    FAIL=1
  fi
  rm -rf "$TMPDIR_TEST"
fi

[ $FAIL -eq 0 ] && echo "ALL TESTS PASSED" || exit 1
