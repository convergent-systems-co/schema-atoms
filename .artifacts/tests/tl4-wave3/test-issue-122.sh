#!/usr/bin/env bash
# test-issue-122.sh — TDD guard for issue #122 (Astro URL routes)
# Must FAIL on current state (files not yet created), PASS after implementation.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
FAILURES=0

pass() { echo "  PASS: $1"; }
fail() { echo "  FAIL: $1"; FAILURES=$((FAILURES + 1)); }

echo "=== test-issue-122: Astro URL routes ==="
echo "Repo root: $REPO_ROOT"

# 1. [class]/index.astro exists
if test -f "$REPO_ROOT/web/src/pages/[class]/index.astro"; then
  pass "[class]/index.astro exists"
else
  fail "[class]/index.astro does not exist"
fi

# 2. [class]/index.astro contains getStaticPaths
if grep -q 'getStaticPaths' "$REPO_ROOT/web/src/pages/[class]/index.astro" 2>/dev/null; then
  pass "[class]/index.astro contains getStaticPaths"
else
  fail "[class]/index.astro missing getStaticPaths"
fi

# 3. catalog.ts (or catalog.js) exists
if test -f "$REPO_ROOT/web/src/lib/catalog.ts" || test -f "$REPO_ROOT/web/src/lib/catalog.js"; then
  pass "catalog.ts/js exists"
else
  fail "web/src/lib/catalog.ts (or .js) does not exist"
fi

# 4. [class]/[slug]/index.astro exists
if test -f "$REPO_ROOT/web/src/pages/[class]/[slug]/index.astro"; then
  pass "[class]/[slug]/index.astro exists"
else
  fail "[class]/[slug]/index.astro does not exist"
fi

# 5. [class]/[slug]/[version]/index.astro exists
if test -f "$REPO_ROOT/web/src/pages/[class]/[slug]/[version]/index.astro"; then
  pass "[class]/[slug]/[version]/index.astro exists"
else
  fail "[class]/[slug]/[version]/index.astro does not exist"
fi

# 6. catalog.ts exports ATOM_CLASSES
if grep -q 'ATOM_CLASSES' "$REPO_ROOT/web/src/lib/catalog.ts" 2>/dev/null; then
  pass "catalog.ts exports ATOM_CLASSES"
else
  fail "catalog.ts missing ATOM_CLASSES export"
fi

# 7. catalog.ts exports getAtomsForClass
if grep -q 'getAtomsForClass' "$REPO_ROOT/web/src/lib/catalog.ts" 2>/dev/null; then
  pass "catalog.ts exports getAtomsForClass"
else
  fail "catalog.ts missing getAtomsForClass export"
fi

# 8. [class]/[slug]/index.astro contains getStaticPaths
if grep -q 'getStaticPaths' "$REPO_ROOT/web/src/pages/[class]/[slug]/index.astro" 2>/dev/null; then
  pass "[class]/[slug]/index.astro contains getStaticPaths"
else
  fail "[class]/[slug]/index.astro missing getStaticPaths"
fi

# 9. [class]/[slug]/[version]/index.astro contains getStaticPaths
if grep -q 'getStaticPaths' "$REPO_ROOT/web/src/pages/[class]/[slug]/[version]/index.astro" 2>/dev/null; then
  pass "[class]/[slug]/[version]/index.astro contains getStaticPaths"
else
  fail "[class]/[slug]/[version]/index.astro missing getStaticPaths"
fi

# 10. No hardcoded secrets
for f in \
  "$REPO_ROOT/web/src/lib/catalog.ts" \
  "$REPO_ROOT/web/src/pages/[class]/index.astro" \
  "$REPO_ROOT/web/src/pages/[class]/[slug]/index.astro" \
  "$REPO_ROOT/web/src/pages/[class]/[slug]/[version]/index.astro"; do
  if test -f "$f"; then
    if grep -qiE '(password|secret|token|api_key)\s*=\s*["\x27][^"x27]+["\x27]' "$f" 2>/dev/null; then
      fail "Possible hardcoded secret in $f"
    fi
  fi
done
pass "No hardcoded secrets detected"

echo ""
if [ "$FAILURES" -eq 0 ]; then
  echo "RESULT: PASS ($FAILURES failures)"
  exit 0
else
  echo "RESULT: FAIL ($FAILURES failures)"
  exit 1
fi
