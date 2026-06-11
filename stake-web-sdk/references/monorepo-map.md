# StakeEngine/web-sdk — Monorepo Map

Authoritative map of the upstream `StakeEngine/web-sdk` monorepo.
Source: `gh api repos/StakeEngine/web-sdk` (latest commit `1843d60`, 2025-11-27).

## Table of Contents

- [Top-Level Layout](#top-level-layout)
- [apps/ — Sample Games](#apps--sample-games)
- [packages/ — Shared Libraries](#packages--shared-libraries)
  - [Graphics (Pixi + Svelte)](#graphics-pixi--svelte)
  - [Data / RGS](#data--rgs)
  - [State](#state)
  - [UI](#ui)
  - [Utilities](#utilities)
  - [Tooling / Config](#tooling--config)

## Top-Level Layout

| Path | Purpose |
|------|---------|
| `apps/` | Sample game apps — one per mechanic. |
| `packages/` | Shared libraries consumed by `apps/`. |
| `documentation/` | Web-sdk docs source. |
| `caddyfile` | Local reverse-proxy config for dev. |
| `turbo.json` | Turborepo pipeline config. |
| `pnpm-workspace.yaml` | pnpm monorepo workspace definition. |
| `package.json`, `pnpm-lock.yaml` | Root manifest and lockfile. |

## apps/ — Sample Games

One folder per game mechanic. Each app is a runnable SvelteKit + Pixi project that pulls from `packages/`.

| App | Mechanic |
|-----|----------|
| `lines` | Classic payline slot. |
| `ways` | Ways-pays slot (e.g. 243-ways adjacency). |
| `cluster` | Cluster-pays slot (flood-fill groups). |
| `scatter` | Scatter-pays slot. |
| `number-picker` | Pick-style bonus / instant-win mechanic. |
| `price` | Price-style game (non-reel format). |

## packages/ — Shared Libraries

### Graphics (Pixi + Svelte)

| Package | Purpose |
|---------|---------|
| `pixi-svelte` | Svelte bindings for Pixi.js — declarative `<Container>` / `<Sprite>` components. |
| `pixi-svelte-storybook` | Storybook setup for `pixi-svelte` primitives. |
| `components-pixi` | Reusable in-canvas game components (reels, symbols, animations). |

### Data / RGS

| Package | Purpose |
|---------|---------|
| `rgs-requests` | Typed request / response definitions for RGS endpoints (authenticate, play, end-round). |
| `rgs-fetcher` | HTTP client built on top of `rgs-requests` for talking to the RGS. |
| `utils-book` | Helpers for consuming `book` payloads emitted by the math-sdk. |
| `utils-fetcher` | Generic fetch wrapper (timeouts, retries, error normalization). |

### State

| Package | Purpose |
|---------|---------|
| `state-shared` | Cross-app game state stores (balance, bet, round status). |
| `utils-xstate` | XState helpers and shared machine fragments. |
| `utils-event-emitter` | Lightweight event-bus primitive used between game systems. |

### UI

| Package | Purpose |
|---------|---------|
| `components-ui-pixi` | In-canvas UI widgets (buttons, dialogs) rendered with Pixi. |
| `components-ui-html` | DOM / HTML UI overlays (settings panel, paytable). |
| `components-layout` | Responsive layout primitives shared across apps. |
| `components-shared` | Cross-cutting UI building blocks reused by Pixi and HTML layers. |
| `components-storybook` | Storybook setup for UI components. |

### Utilities

| Package | Purpose |
|---------|---------|
| `utils-shared` | Generic helpers (math, arrays, formatters). |
| `utils-bet` | Bet construction, validation, currency formatting. |
| `utils-slots` | Slot-mechanic helpers (reel utilities, payline math). |
| `utils-layout` | Layout helpers (breakpoints, scale modes). |
| `utils-resize-observer` | Cross-browser resize-observer wrapper. |
| `utils-sound` | Sound-asset loading and playback. |
| `constants-shared` | Shared constants (event names, mode keys). |
| `envs` | Environment-variable parsing and typing. |

### Tooling / Config

| Package | Purpose |
|---------|---------|
| `eslint-config-custom` | Shared ESLint preset. |
| `config-ts` | Shared `tsconfig` base files. |
| `config-svelte` | Shared `svelte.config.js` base. |
| `config-vite` | Shared Vite config base. |
| `config-storybook` | Shared Storybook config. |
| `config-lingui` | Shared Lingui (i18n) config. |
