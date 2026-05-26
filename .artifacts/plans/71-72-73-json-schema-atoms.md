# Plan: JSON Schema Atoms — panels-config, project-config, agent-envelope

**Issues:** #71 (panels-config), #72 (project-config), #73 (agent-envelope)
**Branch:** feat/71-72-73-json-schema-atoms

---

## Objective

Add three `json-schema` type atoms to the schema-atoms catalog, one per issue.
Each atom lives at `compositions/json-schema/<slug>@1.0.0/` with an `atom.toml`
envelope and a corresponding `.json` asset file containing the actual JSON Schema.

---

## Acceptance Criteria

1. `compositions/json-schema/panels-config@1.0.0/atom.toml` is valid per `validate_atoms.py`.
2. `compositions/json-schema/panels-config@1.0.0/panels-config.json` contains a non-trivial JSON Schema describing the `panels` list in `project.yaml`.
3. `compositions/json-schema/project-config@1.0.0/atom.toml` is valid per `validate_atoms.py`.
4. `compositions/json-schema/project-config@1.0.0/project-config.json` contains a non-trivial JSON Schema describing the full `project.yaml` structure.
5. `compositions/json-schema/agent-envelope@1.0.0/atom.toml` is valid per `validate_atoms.py`.
6. `compositions/json-schema/agent-envelope@1.0.0/agent-envelope.json` is a verbatim copy of the canonical schema from `olympus-central/src/core/embed/_content/schemas/agent-envelope.schema.json`.
7. `python3 scripts/validate_atoms.py` exits 0 on the worktree.

---

## Schema Sources

| Atom | Source / Derivation |
|---|---|
| panels-config | Derived from `project.yaml` `panels:` field across ecosystem repos (core-infra, olympus, olympus-central). Describes a list of panel slugs referencing review panels. |
| project-config | Derived from observed `project.yaml` files across all *-atoms and olympus repos. Covers name, language, framework, personas, panels, tooling, conventions, governance, repository, issue_tracker, ado_integration, instructions. |
| agent-envelope | Verbatim from `olympus-central/src/core/embed/_content/schemas/agent-envelope.schema.json`. |

---

## Sub-tasks

1. Confirm baseline: run `python3 scripts/validate_atoms.py` — must be green.
2. Author `panels-config.json` JSON Schema.
3. Create `compositions/json-schema/panels-config@1.0.0/atom.toml`.
4. Author `project-config.json` JSON Schema.
5. Create `compositions/json-schema/project-config@1.0.0/atom.toml`.
6. Copy `agent-envelope.json` from olympus-central canonical source.
7. Create `compositions/json-schema/agent-envelope@1.0.0/atom.toml`.
8. Run `python3 scripts/validate_atoms.py` — must be green.
9. Adversarial pass: verify spec fields are non-trivial, all 3 atoms present.
10. Commit, push, open PR.

---

## Test Strategy

- `python3 scripts/validate_atoms.py` is the gating test. It validates envelope
  fields (id, version, lifecycle, created_at), protocol section presence/content
  for classes that require it, and `conforms_to` link resolution.
- The json-schema class does NOT require a `[protocol]` section unless it is an
  external standard — but all three of our atoms cite an upstream source, so
  `[protocol]` is included for provenance.
- Manual adversarial check: each `.json` asset must be valid JSON, must have
  `$schema`, `$id`, `title`, `description`, `type`, and non-trivial `properties`.

---

## Risk Assessment

- **Risk:** `validate_atoms.py` glob pattern is `compositions/*/*/atom.toml` — must
  place files there, not under an `atoms/` subdirectory.
- **Mitigation:** The existing `json-schema/` atoms confirm the path shape is
  `compositions/json-schema/<slug>@<version>/atom.toml`. Follow this exactly.
- **Risk:** `[protocol].license` must be one of the recognized set in the validator.
  Apache-2.0 is recognized; use it for all three (consistent with existing atoms).

---

## Alternatives Considered

| Alternative | Pros | Cons | Verdict |
|---|---|---|---|
| Single combined atom for all three schemas | Fewer files | Violates one-atom-per-schema principle; can't version independently | Rejected |
| Use `draft-07` schema version instead of `2020-12` | Broader tooling compat | Inconsistent with rest of catalog (all use 2020-12) | Rejected |
| Omit `[protocol]` for internally authored schemas | Simpler | Loses provenance; inconsistent with style of existing atoms | Rejected |
