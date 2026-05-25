# Workflow Catalog Specification

**Catalog:** `workflow-atoms.com`
**Version:** 1.0.0-draft
**Conforms to:** `schema-atoms/design-spec/atom-spec@1.1.0`

## Purpose

The workflow catalog holds structured definitions of multi-step processes — directed acyclic graphs, sequential procedures, and approval chains that coordinate agents, services, and human actors toward a defined outcome. Each atom encodes a workflow as a versioned artifact so it can be referenced, validated, and executed reproducibly without embedding orchestration logic in individual services.

Workflow atoms are the authoritative source for how work moves through the system. They express the what and the order; they do not contain implementation logic — that lives in the agents and services the workflow invokes.

## Atom Classes

| Class | Description |
|---|---|
| `sequential-workflow` | A linear sequence of named steps with declared inputs, outputs, and error handling |
| `dag-workflow` | A directed acyclic graph of steps with explicit dependency edges enabling parallel execution |
| `approval-workflow` | A workflow that includes human-in-the-loop approval gates with escalation and timeout rules |
| `workflow-template` | A parameterized workflow base that is instantiated with environment-specific values at runtime |

## Consumers

- Olympus runtime — the primary executor; resolves workflow atoms and orchestrates step execution
- `agent-atoms` — agents may be invoked as workflow step executors
- `skill-atoms` — workflow-skills wrap workflow atoms into agent-callable single actions
- `pipeline-atoms` — pipelines may invoke workflow atoms as sub-processes in build or deployment flows

## Relationship to Other Catalogs

- **pipeline-atoms:** pipelines are specialized workflows for build and deployment contexts; workflow atoms cover general-purpose process orchestration, pipeline atoms cover CI/CD and data movement specifically.
- **agent-atoms:** agents execute workflow steps; the workflow atom declares the process structure, the agent atom provides the executor for individual steps.
- **event-atoms:** workflows are frequently triggered by events; event atoms define the trigger schema, workflow atoms define the response process.
