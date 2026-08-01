#!/usr/bin/env bash
# test-issue-4.sh — Validate Terraform remote state backend configuration
# Issue #4: Initialize Terraform remote state backend
# TL-2 / TDD Writer
#
# Exit 0 = all criteria pass (post-fix state)
# Exit 1 = one or more criteria fail

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
PASS=0
FAIL=0

check() {
  local desc="$1"
  local result="$2"   # "pass" or "fail"
  if [[ "$result" == "pass" ]]; then
    echo "  PASS: $desc"
    PASS=$((PASS + 1))
  else
    echo "  FAIL: $desc"
    FAIL=$((FAIL + 1))
  fi
}

echo "=== test-issue-4.sh: Terraform backend validation ==="
echo "Repo root: $REPO_ROOT"
echo ""

# 1. dev/backend.tf must NOT contain REPLACE-ME
if grep -q 'REPLACE-ME' "$REPO_ROOT/infra/terraform/envs/dev/backend.tf" 2>/dev/null; then
  check "dev/backend.tf: no REPLACE-ME placeholder" "fail"
else
  check "dev/backend.tf: no REPLACE-ME placeholder" "pass"
fi

# 2. stg/backend.tf must NOT contain REPLACE-ME
if grep -q 'REPLACE-ME' "$REPO_ROOT/infra/terraform/envs/stg/backend.tf" 2>/dev/null; then
  check "stg/backend.tf: no REPLACE-ME placeholder" "fail"
else
  check "stg/backend.tf: no REPLACE-ME placeholder" "pass"
fi

# 3. ADR 0001 must exist
if [[ -f "$REPO_ROOT/docs/adr/0001-tf-backend.md" ]]; then
  check "docs/adr/0001-tf-backend.md exists" "pass"
else
  check "docs/adr/0001-tf-backend.md exists" "fail"
fi

# 4. dev/backend.tf must reference real bucket name
if grep -q 'cs-tfstate' "$REPO_ROOT/infra/terraform/envs/dev/backend.tf" 2>/dev/null; then
  check "dev/backend.tf: uses cs-tfstate bucket" "pass"
else
  check "dev/backend.tf: uses cs-tfstate bucket" "fail"
fi

# 5. stg/backend.tf must reference real bucket name
if grep -q 'cs-tfstate' "$REPO_ROOT/infra/terraform/envs/stg/backend.tf" 2>/dev/null; then
  check "stg/backend.tf: uses cs-tfstate bucket" "pass"
else
  check "stg/backend.tf: uses cs-tfstate bucket" "fail"
fi

# 6. dev key path must contain 'dev' (not prod key)
if grep -q 'dev' "$REPO_ROOT/infra/terraform/envs/dev/backend.tf" 2>/dev/null; then
  check "dev/backend.tf: key path contains 'dev'" "pass"
else
  check "dev/backend.tf: key path contains 'dev'" "fail"
fi

# 7. stg key path must contain 'stg' (not prod key)
if grep -q 'stg' "$REPO_ROOT/infra/terraform/envs/stg/backend.tf" 2>/dev/null; then
  check "stg/backend.tf: key path contains 'stg'" "pass"
else
  check "stg/backend.tf: key path contains 'stg'" "fail"
fi

echo ""
echo "Results: $PASS passed, $FAIL failed"

if [[ "$FAIL" -gt 0 ]]; then
  echo "STATUS: FAIL"
  exit 1
else
  echo "STATUS: PASS"
  exit 0
fi
