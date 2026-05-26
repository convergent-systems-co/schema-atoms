# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2026-05-26

### Added

- Initial grammar catalog across four tiers:
  - **T1 — Core primitives:** `persona`, `prompt`, `policy`
  - **T2 — Identity & delivery:** `identity`, `service`, `channel`, `context`, `model`
  - **T3 — Extended catalog:** `knowledge`, `event`, `doc`, `workflow`, `agent`,
    `compliance`, `brand`, `theme`, `plugin`, `profile`
  - **T4 — Advanced constructs:** `policy-dsl`, `capability`
- `VERSIONING.md` — schema versioning policy (MAJOR / MINOR / PATCH rules, change
  process, deprecation guidance)
- Initial template scaffold: Astro 6 (TypeScript, static) at `web/`,
  Cloudflare Pages deploy workflow, Terraform Cloudflare provider stubs in
  `infra/terraform/envs/{dev,stg,prod}/`, the same standards machinery as
  `convergent-systems-co/go-tf-app-template` (bootstrap, label sync, triage,
  secret scan, ADRs, MADR, Code of Conduct, AGPL-3.0).
