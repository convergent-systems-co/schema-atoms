# Plan: Replace SECURITY.md Stub with Real Policy

**Issue:** #10
**TL:** TL-3
**Branch:** feat/tl3-docs-security

## Acceptance Criteria

- [ ] No "Replace this stub" text remains in SECURITY.md
- [ ] Contains "72 hours" (or "72-hour") — acknowledgment SLA
- [ ] Contains "90 days" (or "90-day") — coordinated disclosure window
- [ ] Contains "security@convergent-systems.co"
- [ ] Has explicit in-scope and out-of-scope statements
- [ ] No AI writing tells (no em-dash overload, no generic openers, no tricolons for rhythm)

## Seed Commit

None — SECURITY.md exists as a stub from initial repo setup.

## Sub-tasks

### T1 (Coder A): Rewrite SECURITY.md

**OWNS:** `SECURITY.md` only

**Required additions:**
1. Acknowledgment SLA: 72 hours for initial response
2. Coordinated disclosure window: 90 days from report to public disclosure
3. In-scope: `schemas/**`, `web/**`, `.github/workflows/**`
4. Out-of-scope: dependency vulnerabilities tracked by Dependabot, third-party library vulnerabilities
5. GPG key note: forthcoming, email-only for initial contact

**Keep from stub:**
- Reporting email: `security@convergent-systems.co`
- No public issues prohibition
- SPDX SBOM + cosign supply-chain note

**Remove from stub:**
- "(Replace this stub during seed issue #9 ...)" parenthetical

**Writing quality:**
- Active voice, sentence economy
- No AI tells: no em-dashes, no "it's not just X it's Y", no tricolons for rhythm, no generic openers
- Audience: security researchers and contributors

**Commit format:** `docs: replace SECURITY.md stub with real security policy`

## Test Strategy

Grep-based shell script at `.artifacts/tests/tl3/test-issue-10.sh`:

1. Absence of stub text: `grep -q 'Replace this stub' SECURITY.md` must fail
2. 72-hour SLA present: `grep -qE '72 hour|72-hour|within 72'` must pass
3. 90-day window present: `grep -qE '90 day|90-day'` must pass
4. Email present: `grep -q 'security@convergent-systems.co'` must pass
5. Scope statements present: `grep -qi 'in scope|out of scope'` must pass

Adversarial checks:
- No TODO/FIXME remnants
- Em-dash count <= 2 for whole file
- At least 3 `##` headings
- Conventional commit message on branch
