// @ts-check
import { defineConfig } from 'astro/config';
import { writeExports } from './src/scripts/generate-exports.ts';

/** @type {import('astro').AstroIntegration} */
const catalogExportsIntegration = {
  name: 'catalog-exports',
  hooks: {
    'astro:build:done': ({ dir }) => {
      // dir is a URL; .pathname gives the absolute fs path.
      writeExports(dir.pathname);
    },
  },
};

// https://astro.build/config
export default defineConfig({
  site: 'https://schema-atoms.com',
  output: 'static',
  integrations: [catalogExportsIntegration],
});
