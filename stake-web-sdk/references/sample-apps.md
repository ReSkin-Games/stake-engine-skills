# Sample Apps

The Web SDK ships five sample slot games under `web-sdk/apps/`. Each is a complete, runnable Storybook + dev-server target.

## Catalog

| App | Mechanic | When to copy from |
|-----|----------|-------------------|
| `lines` | Paylines (fixed lines, left-to-right wins) | Default starting point. Cleanest implementation of every concept — context wiring, bookEventHandlerMap, emitter events, Storybook stories. |
| `ways` | Ways-to-win (e.g. 243 ways, adjacent reels) | Copy when a game wins on any matching adjacent symbols regardless of position. |
| `cluster` | Cluster pays (connected groups of matching symbols) | Copy when wins are based on contiguous symbol clusters. Includes a tumble/cascade mechanic. |
| `scatter` | Scatter pays (symbols pay anywhere) | Copy when symbol count anywhere on the board drives wins. |
| `price` | Price-driven variant | Copy when modelling a price-/level-up mechanic on top of a slot. |

## Recommended starting point

Start from `lines`. It is the canonical example used throughout the upstream docs — every code snippet in the Adding Events guide, the Flowchart, and the Context guide references files under `web-sdk/apps/lines/`.

## What to copy

When forking a sample game:

1. Copy the entire `web-sdk/apps/<sample>/` directory to `web-sdk/apps/<your-game>/`.
2. Update `package.json` — change `name` to the new module name (this is the Turborepo `--filter` target).
3. Update Storybook fixture data under `src/stories/data/` to match the math model output.
4. Update `src/game/typesBookEvent.ts` and `src/game/typesEmitterEvent.ts` to match the new event surface.
5. Adjust `src/game/bookEventHandlerMap.ts` and the components under `src/components/` for the new behaviours.

## Running an app

```sh
pnpm run storybook --filter=<name>   # Storybook (primary dev surface)
pnpm run dev --filter=<name>         # SvelteKit dev server (end-user view)
```
