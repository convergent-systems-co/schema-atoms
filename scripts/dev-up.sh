#!/usr/bin/env bash
# scripts/dev-up.sh — bring up local dev dependencies.
set -euo pipefail

echo "Installing site dependencies…"
(cd web && npm ci)

echo
echo "To start the dev server: make dev"
echo "To plan infra:           make tf-plan ENV=dev"
