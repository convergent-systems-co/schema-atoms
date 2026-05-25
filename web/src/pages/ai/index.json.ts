import type { APIRoute } from 'astro';
import { ATOM_CLASSES, getAtomsForClass } from '../../lib/catalog';

export const GET: APIRoute = () => {
  const catalog: Record<string, string[]> = {};
  for (const cls of ATOM_CLASSES) {
    const atoms = getAtomsForClass(cls);
    if (atoms.length > 0) {
      catalog[cls] = atoms.sort();
    }
  }

  const payload = {
    version: '1',
    spec_version: 'atoms-spec/v1.1.0',
    site: 'https://schema-atoms.com',
    description:
      'Canonical schema atoms for the convergent-systems.co atoms ecosystem — machine-readable, versioned specifications consumed by AIs and humans.',
    catalog,
    endpoints: {
      class_index: 'https://schema-atoms.com/{class}/',
      atom: 'https://schema-atoms.com/{class}/{slug}@{version}/',
    },
    workflow: [
      '1. Fetch https://schema-atoms.com/ai/index.json to discover available atom classes and slugs.',
      '2. Browse a class at https://schema-atoms.com/{class}/ to list all atoms of that type.',
      '3. Fetch https://schema-atoms.com/{class}/{slug}@{version}/ for full structured atom data.',
      '4. Reference atoms as {class}/{slug}@{version} in prompts, configs, or ATOMS.yml compositions.',
    ],
  };

  return new Response(JSON.stringify(payload, null, 2), {
    headers: { 'Content-Type': 'application/json' },
  });
};
