// generate-exports.ts
// Generates catalog export JSON files and mirror.toml into the Astro dist directory.
// Called from the Astro `catalog-exports` integration hook at `astro:build:done`.
// Safe with zero atoms: catalog.json = [], by-class.json = {}, by-lifecycle.json = {}.

import { readdirSync, existsSync, writeFileSync, mkdirSync, statSync } from 'fs';
import { join } from 'path';

// Path to compositions/ is one level above the web/ directory.
// __dirname is unavailable in ESM; compute relative to process.cwd() (web/).
const COMPOSITIONS_DIR = join(process.cwd(), '..', 'compositions');

export interface AtomEntry {
  class: string;
  slug: string;
  file: string;
}

/**
 * Scan compositions/ for .toml files organised by class subdirectory.
 * Returns a flat array of AtomEntry. Returns [] when compositions/ is absent
 * or all class directories contain only non-.toml files (e.g. .gitkeep).
 */
export function buildCatalog(): AtomEntry[] {
  if (!existsSync(COMPOSITIONS_DIR)) return [];

  const entries: AtomEntry[] = [];

  for (const cls of readdirSync(COMPOSITIONS_DIR)) {
    const classDir = join(COMPOSITIONS_DIR, cls);
    // Skip non-directories (edge case on unusual FS layouts).
    if (!statSync(classDir).isDirectory()) continue;

    const tomlFiles = readdirSync(classDir).filter((f) => f.endsWith('.toml'));
    for (const file of tomlFiles) {
      entries.push({ class: cls, slug: file.replace(/\.toml$/, ''), file });
    }
  }

  return entries;
}

/**
 * Build the minimal mirror.toml content from well-known ATOMS.yml metadata.
 * The values here are static constants derived from ATOMS.yml; a future
 * iteration could parse ATOMS.yml at build time if the manifest grows.
 */
function buildMirrorToml(): string {
  return [
    '# mirror.toml — schema-atoms catalog mirror declaration',
    '# Generated at build time. Do not edit manually.',
    '',
    'spec_version = "atoms-spec/v1"',
    'name = "schema-atoms"',
    'canonical_domain = "schema-atoms.com"',
    'federation = "xdao.co"',
    '',
  ].join('\n');
}

/**
 * Write all catalog export artifacts into `outDir`:
 *   outDir/exports/catalog.json
 *   outDir/exports/by-class.json
 *   outDir/exports/by-lifecycle.json
 *   outDir/mirror.toml
 *
 * @param outDir - Absolute path to the Astro dist directory (dir.pathname from the hook).
 */
export function writeExports(outDir: string): void {
  const catalog = buildCatalog();

  // Group atoms by class name.
  const byClass: Record<string, AtomEntry[]> = {};
  // Group atoms by lifecycle. Lifecycle would come from parsing each .toml;
  // default to 'draft' until individual atom TOML files are authored.
  const byLifecycle: Record<string, AtomEntry[]> = {};

  for (const atom of catalog) {
    (byClass[atom.class] ??= []).push(atom);
    // TODO(#future): parse lifecycle from atom's TOML frontmatter.
    (byLifecycle['draft'] ??= []).push(atom);
  }

  // Ensure exports subdirectory exists.
  const exportsDir = join(outDir, 'exports');
  mkdirSync(exportsDir, { recursive: true });

  writeFileSync(join(exportsDir, 'catalog.json'), JSON.stringify(catalog, null, 2) + '\n');
  writeFileSync(join(exportsDir, 'by-class.json'), JSON.stringify(byClass, null, 2) + '\n');
  writeFileSync(
    join(exportsDir, 'by-lifecycle.json'),
    JSON.stringify(byLifecycle, null, 2) + '\n'
  );
  writeFileSync(join(outDir, 'mirror.toml'), buildMirrorToml());
}
