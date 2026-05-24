import { readdirSync, existsSync, statSync } from 'fs';
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
 * Returns atom directory names (<slug>@<version>) for the given atom class.
 * Atoms are stored as compositions/<class>/<slug>@<version>/atom.toml.
 * Returns an empty array when the class directory has no atom subdirectories.
 */
export function getAtomsForClass(atomClass: string): string[] {
  const dir = join(COMPOSITIONS_DIR, atomClass);
  if (!existsSync(dir)) return [];
  return (readdirSync(dir) as string[]).filter((entry: string) => {
    const entryPath = join(dir, entry);
    return statSync(entryPath).isDirectory() && existsSync(join(entryPath, 'atom.toml'));
  });
}

/**
 * Parses a slug and version from an atom directory name (<slug>@<version>)
 * or legacy flat filename (<slug>@<version>.toml).
 * Falls back to entry-as-slug with version "latest" when no "@" separator.
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
