# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
npm run dev      # Start dev server at localhost:4321
npm run build    # Build to ./dist/
npm run preview  # Preview production build
```

## Architecture

Static Astro site (SSG) with Tailwind CSS. No client-side JavaScript.

**Content System**: All editable content lives in YAML files under `src/data/`:
- `site.yaml` - Site name, about text, address, social links
- `hero.yaml` - Landing page hero section
- `faq.yaml` - FAQ items array
- `pages.yaml` - SEO metadata (title/description) per page
- `rules.yaml` - Rules page content

Components read YAML at build time via `js-yaml` and `fs.readFileSync`.

**Layout**: `BaseLayout.astro` wraps all pages with Header, Footer, and SEO component. SEO component handles title, meta description, OG tags, and canonical URLs.

**Pages**: `/` (landing), `/rules`, `/contacts` - each imports components and page-specific SEO from `pages.yaml`.

## Constraints

- Pure static HTML/CSS output - no React/Vue/Svelte
- No client-side JS unless explicitly requested
- Sitemap auto-generated via @astrojs/sitemap
- Update `site` in `astro.config.mjs` before deploying
