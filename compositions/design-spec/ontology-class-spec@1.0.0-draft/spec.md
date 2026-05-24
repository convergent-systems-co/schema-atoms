# Ontology Class Specification

**Class:** `ontology`
**Family:** taxonomy-spec (Family 6)
**Version:** 1.0.0-draft
**Lifecycle:** draft
**Conforms to:** `schema-atoms/design-spec/atom-spec@1.1.0`
**Authors:** convergent-systems-co

---

## 1. Purpose and Scope

The `ontology` class represents formal concept systems expressed in OWL, RDF, or JSON-LD. Atoms of this class publish machine-readable ontologies that define classes, properties, axioms, and relationships between concepts so that downstream systems can perform logical inference, semantic validation, and knowledge-graph integration.

Ontologies differ from controlled vocabularies in that they express formal logical relationships (subclass-of, equivalent-to, disjoint-with, property restrictions) rather than simple enumerations. They differ from code lists in that their authority is the publishing organization or a formal standards body (W3C, OBO Foundry, schema.org), and their primary use is semantic reasoning rather than code-level validation.

Typical examples include: OWL ontologies for biomedical domains (Gene Ontology, SNOMED CT), upper ontologies (DOLCE, BFO), schema.org type hierarchies, and organization-specific knowledge graphs.

---

## 2. Asset Formats

An atom of class `ontology` MUST provide its ontology in one of the following formats:

| Format | MIME type | When to use |
|---|---|---|
| `.ttl` (Turtle) | `text/turtle` | Preferred for human-authored ontologies; readable, diff-friendly |
| `.owl` (OWL/XML) | `application/owl+xml` | Use when the ontology is produced by OWL tooling (Protégé, etc.) that exports OWL/XML natively |
| `.json-ld` (JSON-LD) | `application/ld+json` | Preferred when consumers are JSON-native or the ontology is served over HTTP APIs |

The asset file path is declared in `atom.toml` under `[spec].asset`. The file MUST be a syntactically valid serialization of its declared format.

### Turtle example structure

```turtle
@prefix owl:  <http://www.w3.org/2002/07/owl#> .
@prefix rdf:  <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix xsd:  <http://www.w3.org/2001/XMLSchema#> .
@prefix ex:   <https://schema-atoms.com/ontology/example#> .

<https://schema-atoms.com/ontology/example>
    a owl:Ontology ;
    rdfs:label "Example Ontology"@en ;
    owl:versionIRI <https://schema-atoms.com/ontology/example/1.0.0-draft> .

ex:DigitalArtifact
    a owl:Class ;
    rdfs:label "Digital Artifact"@en ;
    rdfs:comment "Any machine-readable artifact produced or consumed by a system."@en .

ex:Atom
    a owl:Class ;
    rdfs:subClassOf ex:DigitalArtifact ;
    rdfs:label "Atom"@en ;
    rdfs:comment "A versioned, addressable unit of structured knowledge."@en .
```

### JSON-LD example structure

```json
{
  "@context": {
    "owl": "http://www.w3.org/2002/07/owl#",
    "rdfs": "http://www.w3.org/2000/01/rdf-schema#"
  },
  "@graph": [
    {
      "@id": "https://schema-atoms.com/ontology/example",
      "@type": "owl:Ontology",
      "rdfs:label": "Example Ontology"
    }
  ]
}
```

---

## 3. Required Envelope Fields

Every `ontology` atom MUST declare the following fields in its `atom.toml`:

| Field | Required value or constraint |
|---|---|
| `id` | `"schema-atoms/ontology/<slug>"` |
| `version` | SemVer string (e.g., `"1.0.0"`) |
| `content_hash` | SHA-256 of the asset file; empty string at draft stage |
| `lifecycle` | One of: `draft`, `stable`, `deprecated` |
| `created_at` | RFC 3339 UTC timestamp |
| `[spec].class` | `"ontology"` |
| `[spec].title` | Human-readable title |
| `[spec].summary` | One-sentence description of the ontology's domain and purpose |
| `[spec].authors` | Non-empty array of author identifiers |
| `[spec].asset` | Relative path to the asset file (`.ttl`, `.owl`, or `.json-ld`) |

A `[spec].namespace` field SHOULD declare the ontology's base IRI so consumers can resolve term references without parsing the asset.

---

## 4. Normative Requirements

**MUST:** An atom of class `ontology` MUST declare an `owl:Ontology` IRI in the asset file. An RDF graph without an ontology IRI declaration is a set of triples, not a versioned ontology.

**SHOULD:** An `ontology` atom SHOULD declare `owl:versionIRI` in the asset so that version-pinned imports resolve without ambiguity.

**MUST NOT:** An `ontology` atom MUST NOT embed credentials, internal hostnames, or other secrets in the asset's annotation properties or comments.

---

## 5. Example Atom Reference

The following illustrates a well-formed `ontology` atom at draft stage:

```
schema-atoms/ontology/schema-atoms-meta@1.0.0-draft
```

`atom.toml`:

```toml
id          = "schema-atoms/ontology/schema-atoms-meta"
version     = "1.0.0-draft"
content_hash = ""
lifecycle   = "draft"
created_at  = "2026-05-23T00:00:00Z"

[spec]
class       = "ontology"
title       = "Schema-Atoms Meta-Ontology"
summary     = "OWL ontology defining the core classes and properties of the schema-atoms knowledge model."
authors     = ["convergent-systems-co"]
asset       = "schema-atoms-meta.ttl"
namespace   = "https://schema-atoms.com/ontology/meta#"
```

`schema-atoms-meta.ttl` (excerpt):

```turtle
@prefix owl:  <http://www.w3.org/2002/07/owl#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix sa:   <https://schema-atoms.com/ontology/meta#> .

<https://schema-atoms.com/ontology/meta>
    a owl:Ontology ;
    rdfs:label "Schema-Atoms Meta-Ontology"@en ;
    owl:versionIRI <https://schema-atoms.com/ontology/meta/1.0.0-draft> .

sa:Atom
    a owl:Class ;
    rdfs:label "Atom"@en ;
    rdfs:comment "A versioned, addressable unit of structured knowledge in schema-atoms."@en .

sa:atomClass
    a owl:DatatypeProperty ;
    rdfs:domain sa:Atom ;
    rdfs:label "atom class"@en ;
    rdfs:comment "The class identifier that determines how the atom's asset is interpreted."@en .
```

---

## 6. Changelog

- **1.0.0-draft** — Initial draft specification.
