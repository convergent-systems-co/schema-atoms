# 0001. Use Cloudflare R2 as Terraform remote state backend

- Status: Accepted
- Date: 2026-05-23

## Context

The project deploys to Cloudflare Pages and manages infrastructure via Terraform.
Three environments exist: `dev`, `stg`, and `prod`. Terraform state must be stored
remotely so that multiple contributors (and future CI runs) share a consistent view
of infrastructure and do not corrupt state through concurrent local execution.

State locking is required to prevent concurrent `terraform apply` operations from
racing against each other.

## Decision

Use Cloudflare R2 (S3-compatible object storage) as the Terraform remote state
backend for all three environments, via the `s3` backend type.

A single shared bucket (`cs-tfstate`) holds state for all environments, separated
by per-environment key paths:

| Environment | State key |
|---|---|
| `dev` | `state-bucket/convergent-systems-co/schema-atoms/dev/pages-project.tfstate` |
| `stg` | `state-bucket/convergent-systems-co/schema-atoms/stg/pages-project.tfstate` |
| `prod` | `state-bucket/convergent-systems-co/schema-atoms/pages-project.tfstate` |

All environment backends share the same R2 endpoint and configuration flags.
State locking is enabled via `use_lockfile = true` (R2 native lock object).

The following flags are required because R2 does not implement all AWS S3
metadata APIs that the Terraform S3 backend probes at initialization time:

- `skip_credentials_validation = true` — R2 does not support the AWS STS
  `GetCallerIdentity` call used to validate credentials.
- `skip_region_validation = true` — R2 uses `region = "auto"`, not an AWS
  region string.
- `skip_metadata_api_check = true` — No EC2 instance metadata service is
  available in the Cloudflare environment.
- `skip_requesting_account_id = true` — R2 does not return an AWS account ID.
- `skip_s3_checksum = true` — R2 does not support the AWS SDK v2 trailing
  checksum header required by recent Terraform versions.
- `use_path_style = false` — R2 uses virtual-hosted-style bucket URLs
  (`bucket.account.r2.cloudflarestorage.com`), not path-style.

## Consequences

- State is durable and shared: any contributor can run `terraform init` and pick
  up the current state without manual state file transfer.
- State locking via `use_lockfile = true` prevents concurrent writes; if a lock
  is left behind by a crashed run, it must be manually cleared with
  `terraform force-unlock`.
- Credentials required: `terraform init` and all Terraform operations require
  Cloudflare R2 API token credentials supplied as `AWS_ACCESS_KEY_ID` and
  `AWS_SECRET_ACCESS_KEY` environment variables (Cloudflare R2 access key ID
  and secret).
- **CI credentials gap:** The current CI workflow (`.github/workflows/ci.yml`)
  does not run `terraform init` or any Terraform commands. The R2 credentials
  (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`) have not been added to GitHub
  Actions secrets. Until those secrets are provisioned and a Terraform job is
  added to CI, `make tf-init ENV=dev` can only be run locally by contributors
  who hold R2 credentials. This gap is tracked as a follow-up task.

## Alternatives considered

- **HCP Terraform (Terraform Cloud).** Provides native remote state, locking,
  run history, and a managed UI. Rejected — requires a separate Terraform Cloud
  subscription; introduces a second SaaS provider dependency for a project that
  is otherwise entirely Cloudflare-native.

- **AWS S3 + DynamoDB.** The canonical S3 backend with DynamoDB for state
  locking is well-documented and widely used. Rejected — requires AWS credentials
  and a DynamoDB table in an otherwise Cloudflare-native stack; adds cross-cloud
  complexity and cost with no benefit over R2 given that R2 is already in use
  for Cloudflare Workers deployments.
