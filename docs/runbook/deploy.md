# Deploy Runbook — schema-atoms

**Audience:** Operator wiring up the Cloudflare Pages deploy pipeline for the first time,
or rotating credentials on an existing deployment.

## Prerequisites

- Cloudflare account access (owner or administrator role)
- GitHub repository admin access (to set secrets and variables)
- `gh` CLI authenticated to the `convergent-systems-co` org

## One-time setup

### 1. Create Cloudflare API tokens

In the Cloudflare dashboard: **My Profile → API Tokens → Create Token**

**Account token** (Pages deploy):

- Template: "Create Additional Tokens"
- Permissions: `Account → Cloudflare Pages → Edit`
- Account Resources: include the `convergent-systems-co` account
- Name: `schema-atoms-pages-deploy`

**DNS token** (Terraform DNS management — needed for `terraform apply` only):

- Template: "Edit zone DNS"
- Zone Resources: include the `schema-atoms.com` zone
- Name: `schema-atoms-dns`

Keep both token values in 1Password under **Convergent Systems - Developer** vault before
setting them as GitHub secrets (they cannot be retrieved from Cloudflare after creation).

### 2. Set GitHub secrets and variables

In GitHub repo → **Settings → Secrets and variables → Actions**:

| Kind | Name | Value |
|---|---|---|
| Secret | `CLOUDFLARE_API_TOKEN` | The account token from step 1 |
| Secret | `CLOUDFLARE_ACCOUNT_ID` | Your Cloudflare account ID (found in the dashboard URL: `dash.cloudflare.com/<account-id>`) |
| Variable | `CLOUDFLARE_PAGES_PROJECT` | `schema-atoms` (the Pages project name for prod) |

Using `gh` CLI:

```bash
# Secrets
gh secret set CLOUDFLARE_API_TOKEN --repo convergent-systems-co/schema-atoms
gh secret set CLOUDFLARE_ACCOUNT_ID --repo convergent-systems-co/schema-atoms

# Variable (not a secret — visible in logs)
gh variable set CLOUDFLARE_PAGES_PROJECT --body "schema-atoms" --repo convergent-systems-co/schema-atoms
```

### 3. Verify the deploy workflow

Push a test tag to confirm the pipeline fires end-to-end:

```bash
git tag v0.0.1-test
git push origin v0.0.1-test
```

Check the **Actions** tab — the `Release` workflow should run. The deploy step runs
`wrangler pages deploy web/dist --project-name=schema-atoms --branch=main` and deploys
to `https://schema-atoms.pages.dev`.

**Cleanup — delete the test tag after confirming:**

```bash
git tag -d v0.0.1-test
git push origin --delete v0.0.1-test
```

## Regular deploys

Push a semver tag to trigger a production deploy:

```bash
git tag v<major>.<minor>.<patch>
git push origin v<major>.<minor>.<patch>
```

The `Release` workflow (`.github/workflows/release.yml`) runs on every `v*` tag push. It:

1. Installs Node 22 dependencies (`npm ci` in `web/`)
2. Runs `npm run build` — output lands in `web/dist/`
3. Deploys `web/dist/` to Cloudflare Pages via `wrangler pages deploy`
4. Creates a GitHub Release with auto-generated notes

If `CLOUDFLARE_PAGES_PROJECT` is not set, the deploy step is skipped and a notice is printed.
The GitHub Release is still created.

## Terraform apply (dev / stg / prod)

Terraform is not run by CI — it is applied manually by an operator with token access.

```bash
# From the relevant env directory, e.g. infra/terraform/envs/dev/
export TF_VAR_account_token="<account-token-from-1Password>"
export TF_VAR_dns_token="<dns-token-from-1Password>"
export TF_VAR_cloudflare_account_id="<account-id>"
export TF_VAR_zone_id="<zone-id>"

terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

Backend credentials (R2 state bucket) are supplied via `AWS_ACCESS_KEY_ID` and
`AWS_SECRET_ACCESS_KEY` environment variables pointing at the Cloudflare R2 API token
minted in `convergent-systems-co/core-infra`.

## Healthy state

- `https://schema-atoms.pages.dev` returns HTTP 200
- `https://schema-atoms.com` returns HTTP 200 (after DNS propagation)
- GitHub Actions `Release` workflow is green on the latest `v*` tag

## Sick state / recovery

| Symptom | Likely cause | Recovery |
|---|---|---|
| Deploy step skipped with "CLOUDFLARE_PAGES_PROJECT unset" | Variable not set in GitHub | Set via `gh variable set` (step 2 above) |
| Wrangler exits with 401 | `CLOUDFLARE_API_TOKEN` expired or wrong scope | Rotate token in Cloudflare, update secret via `gh secret set` |
| Terraform apply fails with "resource not found" | State drift — resource deleted outside Terraform | Run `terraform import` to re-attach existing resource, then apply |
| Pages project returns 522 / site not reachable | DNS record missing or CNAME wrong | Check `cloudflare_dns_record.pages_cname` in Terraform state; re-apply if missing |

## Escalation

For issues beyond this runbook: file a GitHub issue in `convergent-systems-co/schema-atoms`
with label `ops` and assign to the infrastructure maintainer.
