# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
npm run dev      # Start dev server at localhost:4321
npm run build    # Build to ./dist/
npm run preview  # Preview production build
```

## Playwright (Browser Preview)

Playwright runs in Docker, so use `host.docker.internal` instead of `localhost`:
- Dev server: `http://host.docker.internal:4321/`

## Architecture

Static Astro site (SSG) with Tailwind CSS. No client-side JavaScript.

**Content System**: All editable content lives in YAML files under `src/data/`:
- `site.yaml` - Site name, about text, address, social links
- `faq.yaml` - FAQ items array
- `pages.yaml` - SEO metadata (title/description) per page
- `rules.yaml` - Rules page content

Components read YAML at build time via `js-yaml` and `fs.readFileSync`.

**Layout**: `BaseLayout.astro` wraps all pages with Header, Footer, and SEO component. SEO component handles title, meta description, OG tags, and canonical URLs.

**Pages**: `/` (landing), `/rules`, `/contacts` - each imports components and page-specific SEO from `pages.yaml`.

**Events**: `src/components/Events.astro` — секция событий на главной странице. Карточка турнира вынесена в `src/components/OmlSpotlight.astro` (данные захардкожены прямо в нём). Ссылается на страницу турнира `src/pages/events/one_more_league_2026.astro`, где также все данные захардкожены. Для каждого нового события — отдельная статическая страница со своим шаблоном.

**OG-превью**: картинки соцсетей рендерятся из реальных компонентов, а не рисуются руками.
- `src/pages/og/*.astro` — страницы-исходники размером ровно 1200×630, `noindex` и исключены из sitemap (фильтр в `astro.config.mjs`).
- `scripts/render-og.sh` — снимает их локальным Chromium из ms-playwright в 2x и ужимает в `public/images/events/*.jpg`. Требует запущенный dev-сервер; ходит на `127.0.0.1:4321` (не `localhost` — сервер слушает только IPv4).
- После правок карточки перегенерировать картинку и закоммитить её вместе с кодом.

## ⚠️ IMPORTANT: Content Language

**ALL content must be in Russian.** This includes:
- All YAML data files (site.yaml, faq.yaml, rules.yaml, pages.yaml)
- UI text in components (navigation, buttons, headings)
- SEO metadata (titles, descriptions)

## Official Links

- Telegram: https://t.me/vanmo_mafia
- Instagram: https://www.instagram.com/vanmo_mafia/

## Constraints

- Pure static HTML/CSS output - no React/Vue/Svelte
- No client-side JS unless explicitly requested
- Sitemap auto-generated via @astrojs/sitemap
- Update `site` in `astro.config.mjs` before deploying
- Always commit after changes you have made. generate commit message based on what you have changed. avoid to run `git diff` if you remember what you have done. try use breaf commit messages
- never run `npm run dev`, server is already running