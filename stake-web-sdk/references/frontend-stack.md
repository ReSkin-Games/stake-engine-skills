# Frontend Stack

Stake Engine is frontend-agnostic — any web tech that produces a static build can ship. The Web SDK uses a specific, community-favoured stack documented below.

## SDK stack

What the Web SDK itself uses (read from the upstream Frontend Stack and File Structure docs; specific minor versions are pinned in each package's `package.json` rather than in the docs):

| Layer | Technology | Role |
|-------|-----------|------|
| UI framework | Svelte 5 | Reactive UI, runes-based state, HUD, menus. |
| Renderer | Pixi 8 | 2D WebGL/WebGPU rendering for game visuals. |
| Pixi binding | `pixi-svelte` (workspace package) | Declarative Svelte wrapper around Pixi. |
| Animation | GSAP | Tweens and timelines for game and UI transitions. |
| State machine | XState | `gameActor` finite-state machine (`rendering`, `idle`, `bet`, `autoBet`, `resumeBet`, `forceResult`). |
| App framework | SvelteKit | Build target; configured with `@sveltejs/adapter-static`. |
| Build pipeline | Vite | Underlying bundler. |
| Workspace | Turborepo + pnpm workspaces | Monorepo orchestration. |
| Component dev | Storybook | Primary development surface. |
| Language | TypeScript | Strict typing throughout. |
| i18n | Lingui (`@lingui/core`) | Localisation. |
| Sound | `howler` (via `utils-sound`) | Music and SFX. |
| HTTP | Fetch API (via `utils-fetcher`) | RGS calls. |

Required toolchain versions (per upstream Getting Started): Node `18.18.0`, pnpm `10.5.0`. See `references/setup.md`.

## Animation assets

Two paths are documented as first-class:

- **Spine** — skeletal animation. Smallest file sizes, runtime mesh deformation, IK constraints, blending. Requires a Spine license. Integrated via `pixi-spine`.
- **Spritesheet** — frame-by-frame. Simpler pipeline, predictable performance, larger files. Exportable from After Effects, Photoshop, Aseprite, etc.

Both are fully supported by Pixi. The choice is a designer-side decision.

## Static build requirement

The final build must be entirely static — HTML, CSS, JS, and assets only. No SSR, no Node server, no API routes inside the frontend. The only server the frontend talks to is the RGS REST API. Stake Engine serves the build from its CDN.

If using SvelteKit, configure `@sveltejs/adapter-static`. Plain Vite (`vite build`) is already static.

## Alternative stacks

Other combinations have shipped successfully:

- React or Vue with Pixi.
- Phaser as an all-in-one game framework.
- Three.js for 3D slot experiences.
- Pure Pixi without any UI framework.

The hard requirement remains a static build that talks to the RGS REST API.
