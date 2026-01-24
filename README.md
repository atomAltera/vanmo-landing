# VANMO Landing Page

Static website for VANMO — a sports mafia game club in Tbilisi, Georgia.

Built with [Astro](https://astro.build) and [Tailwind CSS](https://tailwindcss.com).

## Tech Stack

- **Astro** — Static Site Generator (SSG)
- **Tailwind CSS v4** — Styling
- **YAML** — Content management
- **TypeScript** — Type safety

## Getting Started

```bash
# Install dependencies
npm install

# Start dev server
npm run dev

# Build for production
npm run build

# Preview production build
npm run preview
```

Dev server runs at `http://localhost:4321`

## Project Structure

```
src/
├── components/     # Astro components
│   ├── Header.astro
│   ├── Footer.astro
│   ├── Hero.astro
│   ├── About.astro
│   ├── FAQ.astro
│   ├── Map.astro
│   └── ...
├── data/           # YAML content files
│   ├── site.yaml   # Site name, contact, social links
│   ├── hero.yaml   # Hero section content
│   ├── faq.yaml    # FAQ items
│   ├── rules.yaml  # Club rules
│   └── pages.yaml  # SEO metadata per page
├── layouts/
│   └── BaseLayout.astro
├── pages/
│   ├── index.astro
│   ├── rules.astro
│   └── contacts.astro
└── styles/
    └── global.css
```

## Content Management

All editable content is in `src/data/*.yaml` files. Edit these to update site content without touching components.

### site.yaml
```yaml
name: "VANMO"
tagline: "Клуб спортивной мафии"
contact:
  phone: "+995 593 527 310"
  email: "contact@vanmo.ge"
social:
  telegram: "https://t.me/vanmo_mafia"
  instagram: "https://www.instagram.com/vanmo_mafia/"
```

### hero.yaml
```yaml
headline: "Добро пожаловать в VANMO"
subtext: "Клуб спортивной мафии..."
cta:
  text: "Группа в Телеграме"
  link: "https://t.me/vanmo_mafia"
```

## Deployment

### Cloudflare Pages (Recommended)

1. Push to GitHub
2. Connect repo in [Cloudflare Pages](https://pages.cloudflare.com)
3. Configure:
   - Build command: `npm run build`
   - Output directory: `dist`
4. Deploy

### Other platforms

Works with Vercel, Netlify, GitHub Pages, or any static hosting.

## Features

- Pure static HTML/CSS output
- SEO optimized (meta tags, OG tags, sitemap.xml, robots.txt)
- Mobile responsive
- Contact info obfuscation (anti-scraping)
- Google Maps integration

## License

MIT
