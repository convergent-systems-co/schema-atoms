# Plan: Initialize Terraform Remote State Backend

**Issue:** #4 — Initialize Terraform remote state backend
**TL:** TL-2
**Date:** 2026-05-23

## Acceptance Criteria

- [ ] `infra/terraform/envs/dev/backend.tf`: no REPLACE-ME strings, real R2 config matching prod pattern, key contains `dev`
- [ ] `infra/terraform/envs/stg/backend.tf`: no REPLACE-ME strings, real R2 config matching prod pattern, key contains `stg`
- [ ] `docs/adr/0001-tf-backend.md`: exists, MADR format, documents R2 backend choice
- [ ] ADR Consequences section notes CI credentials gap (CI does not run terraform; R2 credentials not yet in GitHub secrets)

## Seed Commit

None. Files to be created/replaced from scratch.

## Sub-Tasks

### T1 — Coder A

**Owns:**
- `infra/terraform/envs/dev/backend.tf`
- `infra/terraform/envs/stg/backend.tf`
- `docs/adr/0001-tf-backend.md`

**Work:**
1. Replace `infra/terraform/envs/dev/backend.tf` with real R2 backend config.
   - Same structure as prod backend
   - Key: `state-bucket/convergent-systems-co/schema-atoms/dev/pages-project.tfstate`
2. Replace `infra/terraform/envs/stg/backend.tf` with real R2 backend config.
   - Same structure as prod backend
   - Key: `state-bucket/convergent-systems-co/schema-atoms/stg/pages-project.tfstate`
3. Create `docs/adr/0001-tf-backend.md` in MADR format documenting:
   - R2 backend choice and bucket/key convention
   - Why `skip_*` flags are needed (R2 doesn't support all AWS S3 metadata APIs)
   - Alternatives rejected: HCP Terraform, AWS S3+DynamoDB
   - CI credentials noted as a gap in Consequences
4. Commit with message: `chore(infra): initialize dev/stg Terraform remote state backends + ADR`

**Do NOT touch:** any other files.

## Test Strategy

Grep-based validation only — no live `terraform init` needed (requires Cloudflare R2 credentials not available in CI).

Test script: `.artifacts/tests/tl2/test-issue-4.sh`

Tests:
1. Fail if REPLACE-ME found in dev/backend.tf
2. Fail if REPLACE-ME found in stg/backend.tf
3. Fail if `docs/adr/0001-tf-backend.md` does not exist
4. Fail if `cs-tfstate` not found in dev/backend.tf
5. Fail if `cs-tfstate` not found in stg/backend.tf

Note: `make tf-init ENV=dev` cannot be validated in CI (requires R2 credentials). This constraint is documented in the ADR.

## Alternatives Considered

| Alternative | Pros | Cons | Verdict |
|---|---|---|---|
| HCP Terraform | Native remote state + locking, managed UI | Requires separate Terraform Cloud subscription; foreign to Cloudflare stack | Rejected |
| AWS S3 + DynamoDB | Industry standard; well-documented | AWS dependency in an otherwise Cloudflare-native stack; adds cross-cloud credentials complexity | Rejected |
| Cloudflare R2 (S3-compatible) | Same provider as deployment target; no extra subscription; `use_lockfile=true` for state locking | Requires `skip_*` flags; credentials must be added to CI separately | **Chosen** |

## Risk Assessment

- **R2 credential gap in CI:** `terraform init` cannot run in CI until `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` (Cloudflare R2 tokens) are added to GitHub secrets. Mitigated by noting the gap in the ADR; file structure is fully verified via grep tests.
- **Backend config correctness:** Using prod backend as the reference template minimizes drift risk.
