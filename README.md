# astro-tf-app-template

GitHub template repository for Astro + Terraform projects in the
[convergent-systems-co](https://github.com/convergent-systems-co) org.

> Use this template, don't fork it. Click **Use this template** above.

## What you get

- Astro starter at `web/site/` (TypeScript, static output, Astro 6.x)
- Multi-site convention: `web/<site-name>/` (see `web/README.md`)
- Terraform infra layout (`modules/`, `envs/dev/stg/prod`) wired for the Cloudflare provider
- GitHub Actions: CI (typecheck/build), TF plan, secret scan (gitleaks), release-to-Cloudflare-Pages
- Structured issue templates (bug / feature / RFC / chore)
- 10 seed issues filed automatically on first push
- 28-label org standard installed automatically
- Agentic issue triage via `repo-standards@v1` (Copilot primary, REST fallback)
- Weekly label cleanup
- ADR (MADR) starter, CHANGELOG (Keep-a-Changelog), Code of Conduct
- DevContainer (Node 22 + Terraform + tflint + gh)
- AGPL-3.0 license by default; seed issue 00 lets the consumer change it

## Layout

```
web/                    Front-end sites
  site/                 Astro 6 (TypeScript, static, minimal starter)
  README.md             multi-site convention
infra/                  Infrastructure-as-code
  terraform/
    modules/
    envs/{dev,stg,prod}/  Cloudflare provider stubs
docs/                   Project docs
  adr/                  MADR-format architecture decisions
scripts/                Project tooling
.github/                Workflows, issue templates, dependabot, seed issues
```

## How to use

1. Click **Use this template** on this repo
2. Push your first commit to `main`
3. The bootstrap workflow runs once:
   - Enables secret scanning + push protection (GHAS / public repos only)
   - Installs the 28-label standard
   - Files the 10 seed issues
   - Files a "Welcome" meta-issue
   - Removes itself
4. Work through the seed issues in order, starting with the license choice

## Local development

```sh
# install
make install SITE=site         # or: cd web/site && npm ci

# dev server (localhost:4321)
make dev SITE=site             # or: cd web/site && npm run dev

# typecheck
make check SITE=site

# build
make build SITE=site

# infra plan
make tf-plan ENV=dev
```

## License

AGPL-3.0. See `LICENSE` and `COPYRIGHT`. Per-project bootstrap may override; see seed issue 00.
