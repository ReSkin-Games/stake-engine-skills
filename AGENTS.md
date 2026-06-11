# Stake Engine — Agent Instructions

This file is the universal entry point for any AI dev tool (Cursor, Windsurf, Codex CLI, Aider, Claude Code, GitHub Copilot, etc.) working on a Stake Engine slot game project.

Claude Code users: prefer the full skills in `~/.claude/skills/stake-math-sdk/` and `~/.claude/skills/stake-web-sdk/` (richer than this file). Use this file as a quick reference.

## What is Stake Engine

A platform for publishing slot games on Stake.com. Two official SDKs:

- **Math SDK** (Python): defines game rules, simulates outcomes, generates publishable books + lookup-tables.
- **Web SDK** (Svelte + PixiJS + Turborepo): renders games in the browser by consuming books from the RGS.

Source-of-truth (always prefer these over any cached knowledge):

- Math SDK source: <https://github.com/StakeEngine/math-sdk>
- Web SDK source: <https://github.com/StakeEngine/web-sdk>
- Docs: <https://stakeengine.github.io/math-sdk/>
- TS RGS client: <https://github.com/StakeEngine/ts-client>
- Advanced optimizer: <https://github.com/StakeEngine/convex-optimizer>
- Docs MCP server (live doc access for any MCP-aware tool): in the `mcp-server/` folder of `StakeEngine/docs`

## Glossary (use these terms consistently)

| Term | Meaning |
|---|---|
| **GameState** | The Python class in `math-sdk/src/state/state.py` that holds simulation parameters and runs a spin. |
| **betmode** | A configured way to bet (cost, RTP target, criteria). Defined per game. |
| **book** | One simulated game outcome: an `events` list + `payoutMultiplier`. Lives in `library/books/books_<betmode>.jsonl`. |
| **lookup-table** | The CSV that maps simulation IDs to probability weights and payouts. Lives in `library/lookup_tables/lookUpTable_<betmode>.csv`. |
| **RGS** | Remote Game Server. At `/play/` time it consults the lookup-table, returns the matching book to the frontend. |
| **book event** | A typed entry inside a book (`reveal`, `winInfo`, `updateGlobalMult`, etc.). The frontend renders these in order. |
| **bookEventHandlerMap** | Frontend map of `event.type → async handler`. Each game implements this. |
| **playBookEvents** | The runner that iterates a book's events and dispatches via the handler map. |
| **eventEmitter** | Pub/sub bus used by handlers to coordinate animations. |
| **force key** | A criteria/forcing rule used to filter simulation outcomes (e.g., "must contain max-win"). |
| **paytable** | Symbol-to-payout mapping. Part of `GameConfig`. |
| **pixi-svelte** | In-house declarative layer letting Svelte components describe Pixi scenes. |

## Critical contracts (enforced by Stake on approval)

### Math

- RTP per betmode: **90.0–98.0%**.
- Across betmodes: maximum spread **0.5%** (e.g., base 97.0% requires others 96.5–97.5%).
- Max-win frequency: typically ≥1 in 10,000,000 — must be actually obtainable.
- Non-zero hit-rate: ≥1 in 20 for "BASE" modes.
- Simulation count: 100k–1M for slot-type games.
- Stateless: each bet independent. No jackpots, gamble features, cashout.

### Output files (required for publication)

```
library/books/books_<mode>.jsonl
library/lookup_tables/lookUpTable_<mode>.csv
library/lookup_tables/lookUpTableIdToCriteria_<mode>.csv
library/configs/index.json
library/configs/config_<mode>.json
```

### Frontend

- Build is **static-only**: no SSR, no runtime fetches to external origins.
- All assets (including fonts) from Stake Engine CDN. External fetches → console errors → rejection.
- `rgs_url` from query parameter; never hardcoded.
- Strict XSS policy.
- Bet levels from `/authenticate` response, not hardcoded. Respect `minStep`.
- UI must include: bet size control, balance display, win display with incremental updates, sound mute, spacebar = bet, autoplay with confirmation + stop button, rules + paytable accessible, RTP shown per betmode, max-win shown per betmode.
- Mobile + mini-player view supported without distortion.

### RGS API

| Endpoint | Purpose |
|---|---|
| `POST /wallet/authenticate` | Session, bet config, currency, language. |
| `POST /wallet/play` | Start a round, debit, return the book. |
| `POST /wallet/end-round` | Finalize, credit winnings. |
| `POST /wallet/balance` | Current balance. |
| `POST /bet/event` | Record an event during a round. |

Standard error codes: `ERR_VAL`, `ERR_IS`, `ERR_IPB`, `ERR_ATE`, `ERR_GLE`, `ERR_GEN`.

## Setup commands

### Math SDK (Python 3.12+, optionally Rust/Cargo for bundled optimizer)

```bash
git clone https://github.com/StakeEngine/math-sdk.git
cd math-sdk
make setup
make run GAME=0_0_lines   # smoke
```

### Web SDK (Node 22.16.0, pnpm 10.5.0)

```bash
nvm install 22.16.0 && nvm use 22.16.0
npm install -g pnpm@10.5.0
git clone https://github.com/StakeEngine/web-sdk.git
cd web-sdk
pnpm install
pnpm run storybook --filter=lines   # smoke
```

## Repo layout cheat-sheet

### `math-sdk/`

```
src/
  calculations/   board, lines, ways, cluster, scatter, tumble — win calculators
  config/         GameConfig, BetMode, distributions, paytable, paths
  events/         event factories
  executables/    extension hooks for custom game logic
  state/          GameState (the simulation engine)
  wins/           win_manager, multiplier strategies
  write_data/     output generators (books, lookup-tables, configs)
games/            sample games + your games (start by copying 0_0_lines)
```

### `web-sdk/`

```
apps/             sample games (lines, ways, cluster, scatter, number-picker, price)
packages/
  pixi-svelte             declarative Pixi via Svelte
  components-pixi         Pixi UI components
  components-ui-pixi      in-canvas UI
  components-ui-html      DOM overlays
  utils-book              parser for books JSONL
  utils-event-emitter     pub/sub bus
  rgs-fetcher             HTTP client
  rgs-requests            request/response shapes
  state-shared            cross-app state
  utils-xstate            XState helpers
```

## Common workflows

### Add a new book event end-to-end (frontend)

1. Add the event payload to story fixtures in `apps/<game>/src/stories/data/`.
2. Add a type to `apps/<game>/src/game/types.ts`.
3. Implement the handler in `apps/<game>/src/game/bookEventHandlers.ts` keyed by `event.type`.
4. Register in `bookEventHandlerMap`.
5. If the handler triggers animation, publish an `emitterEvent` via `eventEmitter.broadcastAsync(...)` and subscribe in the relevant Pixi component.

### Add a new betmode (math)

1. In `games/<name>/game_config.py`, append a `BetMode(...)` to the list with `cost`, `rtp`, `criteria`, `weight`.
2. Adjust `distributions.py` if the new mode needs a tuned outcome distribution.
3. Re-run `make run GAME=<name>` to generate new books + lookup-tables for the new mode.
4. Verify RTP within 0.5% of other modes via `library/optimization_files/`.

### Hit a target RTP

1. The optimizer lives in `math-sdk/optimization_program/` (Rust). For complex constraints, see <https://github.com/StakeEngine/convex-optimizer>.
2. Tunable parameters in `src/config/optimization_paramaters.py`.
3. After running, verify final RTP from the lookup-table (not from config target — those can drift).

## Anti-patterns to avoid

- **Don't trust hardcoded RTP labels in UI as the source of truth** — compute displayed RTP from the weighted lookup-table.
- **Don't refactor the books generator without a golden-master baseline** — special-card behavior is easy to break invisibly.
- **Don't inject max-win only into books** — the optimizer reads payouts from the raw lookup-table; both must stay in sync.
- **Don't reach for `setContext` outside the `<App>` boundary** (frontend) — contexts must be set inside the entry point.
- **Don't use `broadcast` when you need ordered animation sequences** — use `broadcastAsync`.
- **Don't bake the bet amount or currency into UI** — read from `/authenticate` response.

## When in doubt

- For Claude Code: trigger the full skill (`stake-math-sdk` / `stake-web-sdk`) — it has 27+21 reference files with the full breakdown.
- For any MCP-aware tool: install the `stake-engine-docs` MCP server (in the `StakeEngine/docs` repo, `mcp-server/` folder) for live doc search.
- Otherwise: read the upstream README and docs directly. Don't guess.
