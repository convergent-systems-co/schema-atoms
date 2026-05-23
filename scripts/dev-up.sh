#!/usr/bin/env bash
# scripts/dev-up.sh — bring up local dev dependencies.
set -euo pipefail

echo "Installing site dependencies…"
(cd web/site && npm ci)

echo
echo "To start the dev server: make dev SITE=site"
echo "To plan infra:           make tf-plan ENV=dev"
