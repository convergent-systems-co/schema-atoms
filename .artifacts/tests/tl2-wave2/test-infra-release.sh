#!/usr/bin/env bash
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
FAIL=0

# Test 1: dev/main.tf must not say "~> 4.0"
if grep -q '~> 4.0' "$REPO_ROOT/infra/terraform/envs/dev/main.tf" 2>/dev/null; then
  echo "FAIL: dev/main.tf still uses cloudflare ~> 4.0"
  FAIL=1
fi

# Test 2: stg/main.tf must not say "~> 4.0"
if grep -q '~> 4.0' "$REPO_ROOT/infra/terraform/envs/stg/main.tf" 2>/dev/null; then
  echo "FAIL: stg/main.tf still uses cloudflare ~> 4.0"
  FAIL=1
fi

# Test 3: dev/main.tf must have ~> 5.0
if ! grep -q '~> 5.0' "$REPO_ROOT/infra/terraform/envs/dev/main.tf" 2>/dev/null; then
  echo "FAIL: dev/main.tf does not use cloudflare ~> 5.0"
  FAIL=1
fi

# Test 4: stg/main.tf must have ~> 5.0
if ! grep -q '~> 5.0' "$REPO_ROOT/infra/terraform/envs/stg/main.tf" 2>/dev/null; then
  echo "FAIL: stg/main.tf does not use cloudflare ~> 5.0"
  FAIL=1
fi

# Test 5: ADR must exist
if [ ! -f "$REPO_ROOT/docs/adr/0002-cloudflare-provider-v5.md" ]; then
  echo "FAIL: docs/adr/0002-cloudflare-provider-v5.md does not exist"
  FAIL=1
fi

# Test 6: deploy runbook must exist
if [ ! -f "$REPO_ROOT/docs/runbook/deploy.md" ]; then
  echo "FAIL: docs/runbook/deploy.md does not exist"
  FAIL=1
fi

# Test 7: release.yml references CLOUDFLARE_API_TOKEN
if ! grep -q 'CLOUDFLARE_API_TOKEN' "$REPO_ROOT/.github/workflows/release.yml" 2>/dev/null; then
  echo "FAIL: release.yml missing CLOUDFLARE_API_TOKEN reference"
  FAIL=1
fi

[ $FAIL -eq 0 ] && echo "ALL TESTS PASSED" || exit 1
