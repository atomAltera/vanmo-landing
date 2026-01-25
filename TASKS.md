# Tasks

## Mobile Hamburger Menu

**Assignee**: Ralph
**Status**: Pending

### Goal
Add responsive hamburger menu for mobile view while keeping the current horizontal navigation on desktop.

### Current State
- Header in `src/components/Header.astro`
- Horizontal nav with 3 links: Главная, Правила, Контакты
- No mobile responsiveness - nav always visible horizontally

### Requirements

**Mobile (< 768px)**:
- Hide horizontal nav links
- Show hamburger icon (☰) on right side
- On tap: slide-down menu with vertical nav links
- Overlay should be dark/semi-transparent matching site theme
- Close on: X button, tap outside, or nav link click

**Desktop (≥ 768px)**:
- Keep current horizontal nav exactly as-is
- Hide hamburger icon

### Technical Constraints
- Pure CSS solution preferred (checkbox hack) to maintain "no client-side JS" policy
- OR minimal vanilla JS if CSS-only isn't smooth enough
- Use Tailwind classes for styling
- Keep Russian labels: Главная, Правила, Контакты
- Match existing aesthetic: `bg-neutral-950/70`, `backdrop-blur`, uppercase tracking

### Suggested Approach
1. Add hidden checkbox for toggle state
2. Add hamburger button with `md:hidden`
3. Add mobile nav container that shows/hides based on checkbox
4. Use Tailwind `hidden md:flex` to hide desktop nav on mobile
5. Animate with CSS transitions

### Files to Modify
- `src/components/Header.astro` - main changes here
