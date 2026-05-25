# AI Constitution Spec

**Atom ID:** `schema-atoms/design-spec/ai-constitution-spec`
**Version:** 1.0.0-draft
**Lifecycle:** draft
**Conforms to:** `schema-atoms/design-spec/atom-spec@1.1.0`
**CLI version:** ai v1.2.x

## Purpose

The AI Constitution defines behavioral constraints, decision-making rules, and governance structure for AI agents — Claude Code, GitHub Copilot, Cursor, Codex, and any future agent — operating in an owner's context. It is the authoritative source of truth for what AI agents are permitted, required, and forbidden to do.

The AI Constitution is not a guideline. It is enforced at runtime through hooks wired into every tool session. Where a rule cannot be mechanically enforced, the spec names the gap and requires the agent to self-report violations.

## Document Architecture (v2 — Unified)

The AI Constitution is a single unified file, not four separate files:

| File | Role | Size |
|---|---|---|
| `~/.ai/Constitution.md` | Full human-readable document with all rules and rationale | ~38 KB |
| `~/.ai/Constitution.compact.md` | AI session load — operative rules only, no explanations | ~5 KB |
| `~/.ai/Constitution.runtime.md` | Context-constrained tool load (Copilot CLI, Cursor) | ~7 KB |

### Section Structure

```
Constitution.md
  §1  Governance          — override protocol, audit, amendment process
  §2  Behavioral Standards — conviction, directness, uncertainty, disagreement
  §3  Universal Rules     — autonomy gates, U1–U17 operating rules, secrets
  §4  Technical Work      — clean code, testing, security, change management
  §5  Prose Work          — voice, structure, honesty, domain rules
  §N  Additional domains  — data, legal, research (user-defined at setup)
```

### Context Efficiency

The full `Constitution.md` (~38 KB, ~9,700 tokens) contains rationale prose. The `ai compress` command generates `Constitution.compact.md` (~5 KB, ~1,400 tokens) — every operative rule, no explanations. 85% token reduction.

```bash
ai compress          # generate compact version
ai compress --wire   # switch ~/.claude/CLAUDE.md to load compact version
```

| Tool | Loads | Tokens |
|---|---|---|
| Claude Code (default) | `Constitution.compact.md` | ~1,400 |
| Claude Code (full) | `Constitution.md` | ~9,700 |
| Copilot CLI / Cursor | `Constitution.runtime.md` | ~1,750 |

### Loading

- **Claude Code:** `@~/.ai/Constitution.compact.md` in `~/.claude/CLAUDE.md`
- **Copilot CLI:** `~/.copilot/instructions/constitution.md` symlink → `Constitution.runtime.md`
- **Cursor:** `<repo>/.cursor/rules/constitution.md` symlink → `Constitution.runtime.md`
- **Codex / OpenAI agents:** `AGENTS.md` with `@~/.ai/Constitution.md`

Run `ai hooks install` to wire all integrations automatically.

### Inheritance

All sections are in force for every task. §4/§5 domain sections may only strengthen §3 Universal Rules, never weaken them. When a task spans multiple domains, all applicable sections apply and the stricter rule wins.

## Setup Wizard (Reference-First)

`ai setup` uses a reference-first approach — the constitution is already complete; the wizard personalizes 8 specific slots.

**Flow:**
1. Shows "Your constitution is ready" box listing all invariant content already included
2. Asks 8 personalisation questions across 3 phases
3. Shows a review screen — all 8 values listed; user accepts (Enter), edits (b), or quits (q)
4. Generates `Constitution.md`, installs hooks, wires `CLAUDE.md`, creates Copilot symlink

### The 8 Questions

| Phase | QID | Question | Default |
|---|---|---|---|
| Identity | Q01 | Principal name | "Principal" |
| Identity | Q02 | AI tools | claude-code |
| Identity | Q03 | Work context | personal |
| Autonomy | Q06 | Cost ceiling per task | $5 |
| Autonomy | Q08 | Protected branches | main |
| Style | Q10 | Pushback persistence | flag-once |
| Style | Q11 | Response length | match-complexity |
| Style | Q13 | Attribution in commits | yes |

### Non-Interactive Generation

```bash
# Interactive TUI with review screen
ai setup

# Non-interactive with AICONST_SEEDS
AICONST_SEEDS="Q01=Thomas Polliard,Q02=claude-code,Q03=Convergent Systems LLC,Q06=\$5,Q08=main,Q10=push-until-told,Q11=match-complexity,Q13=true" \
  ai setup --non-interactive

# Generate without wiring (test/inspect)
ai setup --non-interactive --no-hooks
```

## Migration from Four-File Layout

```bash
ai migrate --flatten           # merge four files → one Constitution.md
ai migrate --add-behavioral    # insert §2 Behavioral Standards section
ai migrate --generate-runtime  # write Constitution.runtime.md
```

Original files archived to `~/.ai/archive/pre-v2/`. Nothing is deleted.

## Autonomy Posture

Default posture is **autonomous** for routine work. Gated actions require explicit approval:

- Delete files/directories/branches/tags
- Force-push, rewrite history, amend pushed commits
- Drop tables, truncate data, destructive migrations
- Overwrite canonical documents
- Spend beyond the cost ceiling (default: $5/task)
- Exceed file blast radius (default: 100 files/task)
- Send external communications (email, chat, PRs to upstream)
- Install system-level dependencies or modify global config
- Touch `*production*`, `prod/`, `live/`, `.env*`, `secrets/`, `*.pem`, `id_rsa*`
- Modify `~/.ai/hooks/` or the constitution files
- Commit directly to protected branches (`main`, `release/*`)

Each gate is its own gate. Blanket approvals do not carry forward.

## Behavioral Standards (§2)

§2 names the anti-sycophancy rules as first-class behavioral standards:

- **Conviction** — correctness over agreement; never fabricate agreement or soften true answers
- **Directness** — lead with the answer; no preamble or trailing summary
- **Uncertainty** — "I don't know" is a correct response; confident phrasing of uncertain content is fabrication
- **Disagreement** — surface disagreement BEFORE complying; post-execution disclosure is not a warning
- **Helpfulness** — actual intent, not stated request; surface gaps when they diverge

Each rule has a user-configurable personal overlay set during wizard setup.

## Override Protocol

```
⚠️  OVERRIDE REQUESTED
Rule:        §<section> — <name>
Strict:      <one sentence>
Relaxed:     <one sentence>
Risk:        <one sentence>
Scope:       <task | session | project | global>
Confirm?     (yes / no / scope it)
```

The format is non-negotiable. Every override is logged.

### Non-Overridable

- No fabrication
- No secrets in artifacts
- Destructive action approval gates
- Prompt-injection resistance
- Vendor safety policies, applicable law, employer policies

## Audit Trail

| File | Purpose |
|---|---|
| `~/.ai/audit/violations/<UTC>.md` | Agent-noticed rule violations |
| `~/.ai/audit/overrides/<UTC>.md` | Every relaxed rule |
| `~/.ai/audit/drift/<UTC>.md` | Near-miss patterns before formal violation |
| `~/.ai/audit/interactions/<YYYY-MM>.jsonl` | JSONL per hook event; local only; rotated at 30 days |

`ai review --check` runs a 4-scan review: violations, overrides, drift, dead rules. Writes a dated Governance Report.

## Amendment Lifecycle

```bash
ai amend draft <violation-file>  # extract rule ref + proposed change → stub
ai amend apply <stub>            # patch section, bump version, append changelog
ai compress                      # regenerate compact version after amendment
```

## Enforcement Hooks

| Hook | Rule enforced | Event |
|---|---|---|
| `audit.py` | Interaction logging | All Claude Code events |
| `branch-guard.py` | Protected-branch mutations; bash -c bypass; --no-verify | PreToolUse |
| `worktree-guard.py` | Canonical worktree path placement | PreToolUse |
| `secret-block.py` | Secret detection in tool args | PreToolUse |
| `op-redact.py` | 1Password reference redaction | PreToolUse |

Install: `ai hooks install`. Validate: `ai hooks validate`. Test: `ai hooks evaluate`.

## Worktree Placement

Git worktrees MUST live in one of two canonical locations:

- `<repo>/.worktrees/<name>/` — single-repo, dying with the repo
- `~/.ai/worktrees/<name>/` — cross-repo or persistent

Ad-hoc placement is blocked by `worktree-guard.py`.

## Context-Window Discipline

At or above 80% utilization on any signal (tokens, tool calls, turns, degraded recall):

1. Finish the current atomic action
2. Write/update `HANDOFF.md` at the working-directory root
3. Summarize to the principal
4. Request a fresh session

Auto-compaction MUST NOT occur on a dirty tree, mid-merge, or mid-destructive-op.

## CLI Reference

```bash
# Setup & generation
ai setup                          # interactive wizard with review screen
ai setup --non-interactive        # defaults (or AICONST_SEEDS env var)
ai compress [--wire]              # generate compact version; --wire activates it
ai generate runtime               # regenerate Constitution.runtime.md
ai migrate --flatten/--add-behavioral/--generate-runtime

# Constitution lifecycle
ai constitution backup [--clear-links]  # archive ~/.ai/ to ~/.ai-backups/
ai constitution restore [backup-id]     # restore from archive + rewire tools

# Amendments
ai amend draft <violation-file>   # draft amendment stub
ai amend apply <stub>             # apply to constitution
ai review --check                 # 4-scan governance review

# Hooks
ai hooks install [--copilot]      # install + wire hooks
ai hooks validate                 # lint hook scripts
ai hooks evaluate                 # synthetic event test

# Skills, plugins, atoms
ai skills list/show/validate/templates
ai plugins install <name[@version]>   # resolves from plugin-atoms.com
ai atoms fetch/fork/publish/list

# Diagnostics
ai doctor     # health check (interactive prompts to fix issues)
ai status     # quick status summary
```

Install the CLI: `brew install convergent-systems-co/tap/ai`

## Relation to Schema-Atoms

- This atom is the normative reference for AI Constitution governance structure
- The `ai` CLI binary is the distribution mechanism
- Tool configurations loading `Constitution.compact.md` MAY reference this atom ID to declare spec conformance

## Changelog

- **1.0.0-draft** (initial) — Four-file architecture (`Constitution.md` + `Common.md` + `Code.md` + `Writing.md`)
- **1.0.0-draft rev2** — v2 unified architecture: single `Constitution.md`, `ai compress` for context efficiency, 8-question reference-first wizard with review screen, drift detection, amendment lifecycle, full CLI reference
