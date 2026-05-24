import { readdirSync, existsSync, statSync, readFileSync } from 'fs';
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

export interface AtomData {
  id: string;
  version: string;
  lifecycle: string;
  created_at: string;
  supersedes?: string;
  migration_notes?: string;
  spec?: Record<string, unknown>;
  assetContent?: string;
  assetName?: string;
  raw: Record<string, unknown>;
}

/**
 * Loads the full atom.toml data and optional asset file content for a given atom.
 * atomDir is the <slug>@<version> directory name within the class directory.
 */
export function loadAtomData(atomClass: string, atomDir: string): AtomData | null {
  const dir = join(COMPOSITIONS_DIR, atomClass, atomDir);
  const tomlPath = join(dir, 'atom.toml');
  if (!existsSync(tomlPath)) return null;

  // Parse TOML using a minimal hand-rolled parser sufficient for atom.toml structure.
  // Avoids a runtime TOML dep; atom.toml files are simple and well-structured.
  const raw = parseAtomToml(readFileSync(tomlPath, 'utf-8'));

  const spec = raw['spec'] as Record<string, unknown> | undefined;
  const assetName = spec?.['asset'] as string | undefined;
  let assetContent: string | undefined;

  if (assetName) {
    const assetPath = join(dir, assetName);
    if (existsSync(assetPath)) {
      assetContent = readFileSync(assetPath, 'utf-8');
    }
  }

  return {
    id: raw['id'] as string ?? '',
    version: raw['version'] as string ?? '',
    lifecycle: raw['lifecycle'] as string ?? '',
    created_at: raw['created_at'] as string ?? '',
    supersedes: raw['supersedes'] as string | undefined,
    migration_notes: raw['migration_notes'] as string | undefined,
    spec,
    assetContent,
    assetName,
    raw,
  };
}

/**
 * Minimal TOML parser for atom.toml files.
 * Handles: top-level string/array key=value, [section], [[array-of-tables]].
 * Not a general TOML parser — tuned to the atom.toml shape.
 */
function parseAtomToml(src: string): Record<string, unknown> {
  const result: Record<string, unknown> = {};
  let current: Record<string, unknown> = result;
  let currentArrayKey: string | null = null;

  for (const raw of src.split('\n')) {
    const line = raw.trim();
    if (!line || line.startsWith('#')) continue;

    // [[array-of-tables]]
    const arrMatch = line.match(/^\[\[(.+)\]\]$/);
    if (arrMatch) {
      const key = arrMatch[1].trim();
      if (!Array.isArray(result[key])) result[key] = [];
      const entry: Record<string, unknown> = {};
      (result[key] as Record<string, unknown>[]).push(entry);
      current = entry;
      currentArrayKey = key;
      continue;
    }

    // [section]
    const secMatch = line.match(/^\[(.+)\]$/);
    if (secMatch) {
      const key = secMatch[1].trim();
      const sec: Record<string, unknown> = {};
      result[key] = sec;
      current = sec;
      currentArrayKey = null;
      continue;
    }

    // key = value
    const eqIdx = line.indexOf('=');
    if (eqIdx === -1) continue;
    const key = line.slice(0, eqIdx).trim();
    const valRaw = line.slice(eqIdx + 1).trim();

    if (valRaw.startsWith('"') || valRaw.startsWith("'")) {
      current[key] = valRaw.slice(1, -1).replace(/\\n/g, '\n').replace(/\\"/g, '"');
    } else if (valRaw.startsWith('[')) {
      const inner = valRaw.slice(1, valRaw.lastIndexOf(']'));
      current[key] = inner.split(',').map((s) => s.trim().replace(/^["']|["']$/g, '')).filter(Boolean);
    } else {
      current[key] = valRaw;
    }
  }

  return result;
}
