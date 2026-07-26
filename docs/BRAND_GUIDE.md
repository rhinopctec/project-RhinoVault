# RhinoVault Brand Guide

## Concept
N.O.M.A.D. leans "survival tech" (olive/tan, rugged). RhinoVault shifts that a notch
toward **security + resilience** — a rhino (thick-skinned, hard to take down) merged
with a vault door (locked-down, dependable). Same offline-first spirit, different visual
metaphor: this is the thing that keeps your knowledge safe when everything else is down.

## Color Palette

| Role | Name | Hex | Usage |
|------|------|-----|-------|
| Background (dark) | Charcoal | `#1A1D23` | App shell, sidebar, dark-mode base |
| Surface | Slate Steel | `#3E4C59` | Cards, panels, secondary surfaces |
| Border/muted | Steel Gray | `#5A6672` | Borders, dividers, disabled states |
| Primary accent | Vault Amber | `#E8A33D` | Buttons, links, active states, logo horn |
| Primary accent (dark) | Bronze | `#B5761F` | Hover states, gradients, pressed buttons |
| Success/nature | Rhino Green | `#4B7F52` | Success states, "installed" badges |
| Danger | Rust Red | `#B23A34` | Errors, destructive actions |
| Background (light) | Parchment | `#F5F1E8` | Light-mode base, docs background |
| Text (dark mode) | Off-white | `#EDEAE3` | Primary text on charcoal |
| Text (light mode) | Ink | `#1A1D23` | Primary text on parchment |

## Why these choices
- **Amber over the original's blues/greens** — reads as "vault door brass/warning tape," distinct from N.O.M.A.D.'s branding so the fork doesn't look like a reskin.
- **Charcoal + parchment** (rather than pure black/white) keeps the "archive/knowledge" feel from the original while reading as more premium/security-focused.
- **Rhino green** kept as a secondary accent so success states don't feel like they belong to a totally different product — useful if you're porting the same component library.

## CSS variables (drop into `admin/inertia/css/app.css` alongside/replacing existing theme vars)

```css
:root {
  --rv-bg: #F5F1E8;
  --rv-surface: #FFFFFF;
  --rv-border: #D8D2C4;
  --rv-text: #1A1D23;
  --rv-accent: #E8A33D;
  --rv-accent-dark: #B5761F;
  --rv-success: #4B7F52;
  --rv-danger: #B23A34;
}

.dark {
  --rv-bg: #1A1D23;
  --rv-surface: #3E4C59;
  --rv-border: #5A6672;
  --rv-text: #EDEAE3;
  --rv-accent: #E8A33D;
  --rv-accent-dark: #F0B75C;
  --rv-success: #5C9A64;
  --rv-danger: #D9534D;
}
```

Since the admin UI uses Tailwind (`admin/tailwind.config.ts`), map these into the theme's
`extend.colors` so you can use `bg-rv-accent`, `text-rv-surface`, etc. instead of hardcoding
hex values across components — check `ThemeProvider.tsx` and `useTheme.ts` for how dark/light
mode is currently toggled, since your variables need to hook into the same class-based switch.

## Logo
See `rhinovault_logo.svg` — a low-poly rhino head on a rounded vault-door/shield backdrop,
with the eye styled as a keyhole (subtle security nod). Use the full badge version (with
"RHINOVAULT" text plate) for the README and marketing; use just the shield+rhino mark
(crop out the text plate) for the favicon and in-app header, since the wordmark won't be
legible at small sizes.

**Assets to produce from this base:**
- Favicon: crop to the shield 24×226..228 region, export at 32×32/16×16 PNG
- App header logo (replaces `admin/public/project_nomad_logo.webp`): export the full SVG as WebP/PNG, ~200×200
- Social/OG image: place the mark on a solid Charcoal or Parchment background at 1200×630
