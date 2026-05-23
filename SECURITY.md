# Security Policy

## Reporting a Vulnerability

Email `security@convergent-systems.co` with a description of the issue,
steps to reproduce, and any relevant artifacts. Do NOT open a public issue
for security-relevant findings.

GPG key not yet published — email only for initial contact.

We will acknowledge your report within 72 hours. We follow a coordinated
disclosure process: vulnerabilities are kept confidential for 90 days from
the date of report to allow time for a fix and coordinated release before
public disclosure.

## Scope

**In scope:**

- Schema files: `schemas/**`
- TypeScript and Astro web files: `web/**`
- CI workflow definitions: `.github/workflows/**`

**Out of scope:**

- Dependency vulnerabilities already tracked by Dependabot
- Vulnerabilities in third-party libraries not under our control

## Supply Chain

This repo ships an SPDX SBOM with every release (via syft). Container image
signing via cosign is deferred to the Tier-2 backlog.
