terraform {
  required_version = ">= 1.7.0"
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.0"
    }
  }
}

# STAGING environment — mirrors prod pattern with a stg-specific Pages project.
#
# Multi-provider setup: account-level Pages resources use the account token;
# zone-level DNS records use the dns token. Matches the 2026-05-23 core-infra
# token split documented in ADR 0002.
#
# Tokens passed in as sensitive TF variables. Populate from 1Password before
# apply (see variables below) or via the cs-tofu wrapper at
# convergent-systems-co/core-infra/scripts/cs-tofu.

provider "cloudflare" {
  alias     = "account"
  api_token = var.account_token
}

provider "cloudflare" {
  alias     = "dns"
  api_token = var.dns_token
}

# --- Pages project + custom domain (account-scoped) -------------------------

resource "cloudflare_pages_project" "this" {
  provider          = cloudflare.account
  account_id        = var.cloudflare_account_id
  name              = "schema-atoms-stg"
  production_branch = "main"

  build_config {
    build_command   = "npm run build"
    destination_dir = "dist"
    root_dir        = "web"
  }
}

resource "cloudflare_pages_domain" "custom" {
  provider     = cloudflare.account
  account_id   = var.cloudflare_account_id
  project_name = cloudflare_pages_project.this.name
  name         = "stg.schema-atoms.com"
}

# --- DNS record (zone-scoped) -----------------------------------------------

resource "cloudflare_dns_record" "pages_cname" {
  provider = cloudflare.dns
  zone_id  = var.zone_id
  name     = "stg.schema-atoms.com"
  type     = "CNAME"
  content  = "${cloudflare_pages_project.this.name}.pages.dev"
  proxied  = true
  ttl      = 1 # 1 = "auto" — required when proxied

  comment = "Cloudflare Pages stg apex — managed by terraform"

  depends_on = [cloudflare_pages_domain.custom]
}

# --- Inputs -----------------------------------------------------------------

variable "cloudflare_account_id" {
  description = "Cloudflare account ID that owns the Pages project."
  type        = string
}

variable "zone_id" {
  description = "Cloudflare zone ID for schema-atoms.com."
  type        = string
}

variable "account_token" {
  description = "Cloudflare API token with Account Pages Edit scope. Minted by terraform/cloudflare/account-token in core-infra. Populate from 'Convergent Systems - Account' in 1Password Developer vault."
  type        = string
  sensitive   = true
}

variable "dns_token" {
  description = "Cloudflare API token with Zone DNS Edit scope. Minted by terraform/cloudflare/dns-token in core-infra. Populate from 'Convergent Systems - DNS' in 1Password Developer vault."
  type        = string
  sensitive   = true
}

# --- Outputs ----------------------------------------------------------------

output "project_name" {
  value = cloudflare_pages_project.this.name
}

output "subdomain" {
  value       = cloudflare_pages_project.this.subdomain
  description = "Default *.pages.dev hostname for the stg project."
}

output "custom_domain" {
  value       = cloudflare_pages_domain.custom.name
  description = "Stg custom domain attached to the Pages project."
}
