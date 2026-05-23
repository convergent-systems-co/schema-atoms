#!/usr/bin/env bash
# scripts/tf-plan.sh ENV — terraform plan against an env
set -euo pipefail
env="${1:-dev}"
cd "infra/terraform/envs/$env"
terraform init -input=false
terraform plan -input=false -no-color
