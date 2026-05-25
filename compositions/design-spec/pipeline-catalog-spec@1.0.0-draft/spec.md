# Pipeline Catalog Specification

**Catalog:** `pipeline-atoms.com`
**Version:** 1.0.0-draft
**Conforms to:** `schema-atoms/design-spec/atom-spec@1.1.0`

## Purpose

The pipeline catalog holds structured definitions of CI/CD and data pipeline configurations — build step sequences, deployment stage declarations, data transformation graphs, and release automation patterns. Each atom encodes a pipeline as a portable, versioned artifact so that pipeline definitions can be shared, validated, and promoted across environments without copy-paste duplication.

Pipeline atoms are the authoritative source for how code and data move from source to production. They are environment-agnostic by default and parameterized for environment-specific binding at execution time.

## Atom Classes

| Class | Description |
|---|---|
| `ci-pipeline` | A continuous integration pipeline definition including trigger conditions, build steps, and test gates |
| `cd-pipeline` | A continuous deployment pipeline definition including environment stages and promotion criteria |
| `data-pipeline` | A data transformation pipeline definition including source, transformation steps, and sink |
| `release-pipeline` | A release automation pipeline covering artifact signing, publishing, and changelog generation |

## Consumers

- CI/CD platforms (GitHub Actions, Azure Pipelines, etc.) — pipeline atoms are compiled into platform-specific workflow files
- `service-atoms` — services declare their deployment pipeline by referencing a pipeline atom
- `agent-atoms` — agent deployment is governed by a pipeline atom that packages and provisions the agent
- Olympus runtime — pipelines that include agent invocation steps reference agent atoms for executor resolution

## Relationship to Other Catalogs

- **workflow-atoms:** pipelines are a specialized domain of workflow — specifically build, test, and deployment automation. Workflow atoms cover general-purpose process orchestration; pipeline atoms cover CI/CD and data movement with their specific semantics (stages, gates, environments).
- **service-atoms:** services are the output of deployment pipelines; pipeline atoms reference service atoms to know what they are deploying and to what target.
- **event-atoms:** pipelines are frequently triggered by events (push, PR, schedule); event atoms define the trigger schema that pipeline atoms subscribe to.
