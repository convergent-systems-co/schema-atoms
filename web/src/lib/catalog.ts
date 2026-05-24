import { readdirSync, existsSync } from 'fs';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';

// Resolve compositions/ relative to this file's location:
// web/src/lib/ -> web/src/ -> web/ -> repo root -> compositions/
const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const COMPOSITIONS_DIR = join(__dirname, '..', '..', '..', '..', 'compositions');

export const ATOM_CLASSES = [
  'design-spec',
  'openapi-spec',
  'asyncapi-spec',
  'graphql-schema',
  'grpc-spec',
  'json-rpc-spec',
  'json-schema',
  'protobuf-schema',
  'avro-schema',
  'xml-schema',
  'toml-schema',
  'rfc',
  'w3c-spec',
  'iso-spec',
  'fips',
  'internal-protocol',
  'bnf-grammar',
  'ebnf-grammar',
  'language-reference',
  'query-language-spec',
  'regex-spec',
  'ontology',
  'controlled-vocabulary',
  'code-list',
] as const;

export type AtomClass = (typeof ATOM_CLASSES)[number];

/**
 * Returns all .toml filenames (without extension) for the given atom class.
 * Returns an empty array when the class directory is empty or has no .toml files.
 */
export function getAtomsForClass(atomClass: string): string[] {
  const dir = join(COMPOSITIONS_DIR, atomClass);
  if (!existsSync(dir)) return [];
  return (readdirSync(dir) as string[]).filter((f: string) => f.endsWith('.toml'));
}

/**
 * Parses a slug and version from a .toml filename.
 * Convention: <slug>@<version>.toml  (e.g. openapi-3.1@1.0.0.toml)
 * Falls back to filename-as-slug with version "latest" when no "@" separator.
 */
export function parseAtomFilename(filename: string): { slug: string; version: string } {
  const base = filename.replace(/\.toml$/, '');
  const atIndex = base.lastIndexOf('@');
  if (atIndex === -1) {
    return { slug: base, version: 'latest' };
  }
  return {
    slug: base.slice(0, atIndex),
    version: base.slice(atIndex + 1),
  };
}
