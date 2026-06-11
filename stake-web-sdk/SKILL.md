---
name: stake-web-sdk
description: Builds Stake Engine slot game frontends with the official web-sdk (Svelte + PixiJS + Turborepo). Auto-clones StakeEngine/web-sdk, installs Node 22.16 and pnpm 10.5, smokes Storybook. Covers monorepo navigation (apps/lines, apps/ways, apps/cluster, apps/scatter, apps/number-picker, packages/pixi-svelte, packages/utils-book, packages/utils-event-emitter, packages/rgs-fetcher), adding new book events, building Pixi components, XState integration, RGS communication, and Stake's frontend approval requirements (static-only, CDN-only, strict XSS, mini-player, mobile, spacebar=bet, sound mute, autoplay confirmation). Use when working on slot frontends, web-sdk, Storybook, Pixi, book events, ts-client, or any Stake frontend question.
allowed-tools: Bash, Read, Edit, Write, Glob, Grep, WebFetch
---

# Stake Engine Web SDK

This skill helps build slot game frontends for [Stake Engine](https://engine.stake.com/) using the official Svelte + PixiJS web-sdk at <https://github.com/StakeEngine/web-sdk>. On first activation it bootstraps the environment; afterwards it answers questions and guides workflows.

## How to use this skill

1. **Always start with `scripts/detect-state.sh`** to check whether Node 22.x, pnpm 10.x, and the web-sdk clone are ready. The exit code routes the next step (see `references/bootstrap.md`).
2. **If not ready**: follow `references/bootstrap.md`. It calls atomic scripts in `scripts/`.
3. **If ready**: pick the right `references/*.md` for the user's question. The navigation map below maps topics → files.
4. **For canonical code**: read the actual upstream source in the user's `web-sdk/` clone, never guess. File-path hints in references are `web-sdk/<relative>` — append to the clone root.

Source of truth (in order of priority):
1. The user's clone of `StakeEngine/web-sdk` (the actual code).
2. Upstream README at <https://github.com/StakeEngine/web-sdk>.
3. Official docs at <https://stakeengine.github.io/math-sdk/> (the docs site covers both SDKs).
4. These references (distilled from the above).

## Glossary (use these terms consistently)

| Term | Meaning |
|---|---|
| **book** | One simulated game outcome from math-sdk: events + `payoutMultiplier`. The frontend's input. |
| **book event** | A typed entry in a book (`reveal`, `winInfo`, `updateGlobalMult`, etc.). Drives rendering. |
| **bookEventHandlerMap** | Map of `event.type → async handler`. Each game implements this. |
| **playBookEvents** | The runner that iterates a book's events and dispatches via the handler map. |
| **eventEmitter** | The pub/sub bus used by handlers to coordinate animations. |
| **emitterEvent** | A custom event published on the emitter (game-specific, decoupled from book events). |
| **pixi-svelte** | In-house declarative layer that lets Svelte components describe Pixi scenes. |
| **app** | A folder in `apps/` — one playable game (one sample = one app). |
| **package** | A folder in `packages/` — a shared library (one of: graphics, data, state, UI, utilities, tooling). |
| **betmode** | Configured way to bet, defined in math-sdk and consumed by the frontend. |
| **RGS** | Remote Game Server. The frontend hits `/authenticate`, `/play`, `/end-round`, `/balance`, `/event`. |

## Quickstart (after bootstrap)

```bash
# 1. See a sample game in Storybook.
cd web-sdk
pnpm run storybook --filter=lines
# Open the URL it prints. Pick MODE_BASE/book/random in the sidebar.
# Click the "Action" button — a base round plays.

# 2. To start your own game, copy a sample.
cp -R apps/lines apps/my_game
# Edit apps/my_game/package.json (name) and apps/my_game/src/game/* (logic).

# 3. Dev mode (hot reload).
pnpm run dev --filter=my_game
```

For details, see `references/sample-apps.md` and `references/adding-events.md`.

## Navigation: pick a reference by topic

| User's question / task | Read first | Also useful |
|---|---|---|
| Set up Node, pnpm, clone, smoke | `bootstrap.md` | `setup.md` |
| Monorepo layout (apps/* and packages/*) | `monorepo-map.md` | `sample-apps.md` |
| How book events drive rendering | `flow-and-events.md` | |
| Add a new book event end-to-end | `adding-events.md` | `flow-and-events.md` |
| XState context, state-shared, scoped stores | `context-and-state.md` | |
| Build Pixi components / UI overlays | `ui-and-components.md` | `pixi-svelte.md` |
| Declarative Pixi layer | `pixi-svelte.md` | |
| Run Storybook, develop a game in isolation | `storybook.md` | |
| Tech stack and versions | `frontend-stack.md` | `setup.md` |
| Pick a starting sample app | `sample-apps.md` | `monorepo-map.md` |
| RGS HTTP contract | `rgs-api.md` | `how-rgs-works.md` |
| How RGS works conceptually | `how-rgs-works.md` | |
| Pass Stake frontend approval | `approval-frontend.md` | `approval-rgs.md` |
| Currency / language / dimensions / social-mode | `reference-locales.md` | |
| Common gotchas, broken setups | `troubleshooting.md` | |
| Stake's MCP server, AI agents | `ai-integration.md` | |
| What changed recently | `recent-changes.md` | |
| First-time / getting-started questions | `getting-started-faq.md` | |
| Publishing questions (ranking, exclusivity, removal) | `publishing-faq.md` | |

## Critical contracts (inline — do not break)

These are enforced by Stake on approval. Verify before publishing.

- **Build is static-only**: no SSR, no runtime fetches to external origins, no dev tooling reaching the network. See `approval-frontend.md`.
- **All assets from Stake CDN** — including fonts. Downloading from any other origin (Google Fonts, custom CDN) → console errors → rejection.
- **`rgs_url` from query parameter**: the frontend reads `?rgs_url=…` from the page URL; never hard-code.
- **Strict XSS policy**: no inline scripts from runtime data; CSP-compatible.
- **Bet levels from `/authenticate` response**: not hardcoded. `minStep` controls increments. Don't allow a bet outside the returned range.
- **UI must include**: bet size control, balance display, win display with incremental updates, sound mute, spacebar = bet, autoplay with confirmation + stop button, rules + paytable accessible, RTP shown per betmode, max-win shown per betmode.
- **Mobile + mini-player view supported**: game board not visibly distorted under either.
- **Fastplay (if implemented)**: win amounts and combos still legible.

## Stack flexibility — what's contract vs convention

**Contract** (Stake enforces; can't deviate):
- Static build, no network at runtime except RGS.
- CDN-only assets.
- RGS HTTP contract (URLs, methods, request/response shapes).
- Approval UI behaviors (above).

**Convention** (web-sdk path, not enforced by name):
- Svelte 5 + PixiJS 8 + Turborepo + pnpm + XState.
- `pixi-svelte` declarative wrapper.
- Storybook for development.

If using a different framework (React, Vue, vanilla):
- The RGS contract still applies — `packages/rgs-fetcher` + `packages/rgs-requests` are useful as reference even if not directly imported, or use the separate [`StakeEngine/ts-client`](https://github.com/StakeEngine/ts-client) (framework-agnostic).
- `packages/utils-book` and event-handling patterns from `apps/lines` translate conceptually.
- XState is framework-agnostic — re-wire it via `@xstate/react` or similar.
- Storybook setup needs replicating; sample setups in `apps/*` are Svelte-specific.
- `pixi-svelte` does not apply — use `@pixi/react` or write a direct Pixi integration.
- Approval team accepts any framework as long as the contract above is met.

See `troubleshooting.md` for known gotchas around framework choices.

## Anti-patterns to avoid

- **Don't reach for `setContext` outside the `<App>` boundary** — contexts (EventEmitter, Layout, Xstate, App) must be set inside the entry point.
- **Don't assume Pixi will auto-update on data change** — the renderer doesn't react to mutation outside the declarative path; reassign or use the pattern from `apps/lines/src/components/`.
- **Don't use `broadcast` when you need awaited side effects** — `broadcast` is fire-and-forget; for ordered animation sequences use `broadcastAsync`.
- **Don't manually edit `pnpm-lock.yaml`** — regenerate with `pnpm install` after `package.json` changes.
- **Don't bake the bet amount or currency into UI** — read from `/authenticate` response.

## What this skill does NOT do

- Build math, simulate outcomes, or generate books. For math, the sibling skill `stake-math-sdk` handles that. Activate it when the user asks about Python, GameState, RTP, books, lookup-tables, or optimizer.
- Replace upstream code with copies. Always cite paths in the user's clone; do not paste large blocks of upstream source.
- Decide approval outcomes for the user. The skill explains requirements; the user submits.
