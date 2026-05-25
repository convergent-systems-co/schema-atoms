# Plugin Catalog Specification

**Catalog:** `plugin-atoms.com`
**Version:** 1.0.0-draft
**Conforms to:** `schema-atoms/design-spec/atom-spec@1.1.0`

## Purpose

The plugin catalog holds structured definitions of plugins — named extension points that add capabilities to hosts (agents, services, terminals, editors, and runtimes) without modifying the host's core code. Each atom captures a plugin's capability manifest, hook registrations, required permissions, and configuration schema so that hosts can load and govern plugins safely from a versioned, signed artifact.

Plugin atoms are the authoritative source for what a plugin does and what access it requires. They make extension points explicit and auditable, enabling plugin governance at the catalog level rather than the runtime level alone.

## Atom Classes

| Class | Description |
|---|---|
| `agent-plugin` | A plugin that extends an AI agent with additional tools, context injectors, or output processors |
| `service-plugin` | A plugin that extends a service with middleware, filters, or capability additions |
| `editor-plugin` | A plugin for a code editor or IDE, including language support, keybindings, or theme injection |
| `cli-plugin` | A command-line tool extension that adds subcommands or hooks to an existing CLI |

## Consumers

- `agent-atoms` — agent definitions declare which agent-plugin atoms they load
- Olympus runtime — resolves plugin atoms at host initialization and enforces declared permission requirements
- `skill-atoms` — some skills are implemented as plugins; the skill atom provides the invocation interface, the plugin atom provides the extension mechanism
- Developer tooling — editor and CLI plugin atoms are consumed directly by the tools they extend

## Relationship to Other Catalogs

- **skill-atoms:** skills and plugins are related but distinct — a skill is an agent-level capability declaration, a plugin is a host-level extension mechanism. A skill may be backed by a plugin, but a plugin may also extend non-skill surfaces (editors, CLIs, services).
- **agent-atoms:** agents declare their plugin set alongside their skill set; plugins extend the agent's runtime environment, skills extend its task capabilities.
- **policy-atoms:** plugin permission manifests are evaluated against policy atoms to determine whether a plugin's requested access is permitted in a given deployment context.
