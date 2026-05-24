# 0002 — Upgrade Cloudflare Terraform provider to v5, adopt dual-token split

**Status:** Accepted — 2026-05-24

## Context

The dev and stg environments used cloudflare provider `~> 4.0` with a single API token
supplied via the `CLOUDFLARE_API_TOKEN` environment variable. The prod environment was
upgraded to `~> 5.0` during the core-infra token split (see prod/main.tf comments and
convergent-systems-co/core-infra). This ADR documents aligning dev and stg with prod.

The v4→v5 upgrade reorganized several Cloudflare provider resources. The most material
change for this repo: `cloudflare_record` was renamed to `cloudflare_dns_record`, and
provider configuration now requires explicit alias declaration when two provider instances
are used in the same module.

## Decision

Upgrade dev and stg to `cloudflare ~> 5.0`. Adopt the dual-provider pattern (account-scoped
token + DNS-scoped token) matching prod. This reduces blast radius if a token is compromised
and aligns with Cloudflare's recommended least-privilege model.

Both environments now declare:

```hcl
provider "cloudflare" {
  alias     = "account"
  api_token = var.account_token
}

provider "cloudflare" {
  alias     = "dns"
  api_token = var.dns_token
}
```

## Consequences

- `terraform init` in dev/stg will upgrade the provider binary from v4 to v5.
- Two token variables (`account_token`, `dns_token`) must be set in each environment.
  See `docs/runbook/deploy.md` for how to obtain and configure them.
- Resource `cloudflare_pages_project.site` renamed to `.this` for consistency with prod.
- `cloudflare_pages_domain.custom` and `cloudflare_dns_record.pages_cname` added to
  dev and stg, matching the full resource structure in prod.
- Dev Pages project name: `schema-atoms-dev`; stg: `schema-atoms-stg`.

## Alternatives Rejected

| Alternative | Pros | Cons | Verdict |
|---|---|---|---|
| Keep `~> 4.0` for dev/stg | No migration work | Divergent provider versions between envs; maintenance burden; config drift risk | Rejected |
| Single token for both scopes | Simpler credential management | Violates least-privilege; a leaked token grants both Pages and DNS write access | Rejected |
| Upgrade to latest v5.x patch | Picks up all patches | Lockfile drift requires manual reconciliation across envs | Rejected in favour of `~> 5.0` constraint which allows patch upgrades via lockfile |
