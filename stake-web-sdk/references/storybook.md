# Storybook

Storybook is the primary development surface for the Web SDK. It can render the whole game, an isolated component, a whole book, or a single `bookEvent`.

## Run

```sh
pnpm run storybook --filter=<MODULE_NAME>
# Example
pnpm run storybook --filter=lines
```

`<MODULE_NAME>` is the `name` field of the target app's `package.json` (e.g. `lines` from `web-sdk/apps/lines/package.json`).

## Story hierarchy

Conventions follow the canonical `lines` app; other sample apps mirror it.

### COMPONENTS/&lt;Game&gt;

Stories targeting `web-sdk/apps/<app>/src/components/Game.svelte`:

- `COMPONENTS/<Game>/component` — full `<Game />` with the loading screen included.
- `COMPONENTS/<Game>/preSpin` — `<Game />` with the `preSpin` helper applied.
- `COMPONENTS/<Game>/emitterEvent` — `<Game />` driven by a specific emitter event (e.g. `boardHide`), so a single emitter step can be exercised.

### COMPONENTS/&lt;Symbol&gt; (and other components)

Each component file gets its own folder:

- `COMPONENTS/<Symbol>/component` — `<Symbol />` with Storybook controls for state.
- `COMPONENTS/<Symbol>/symbols` — `<Symbol />` rendered for every symbol × every state at once.

Component stories take plain props rather than being driven by the event emitter. Use them when an emitter-driven story is hard to debug.

### MODE_&lt;MODE&gt;/book

Runs a full book through `playBookEvents()`:

- `MODE_BASE/book/random` — random base-mode book from `src/stories/data/base_books.ts`.
- `MODE_BONUS/book/random` — random bonus-mode book from `src/stories/data/bonus_books.ts`.

### MODE_&lt;MODE&gt;/bookEvent

Runs one `bookEvent` through `playBookEvent()`:

- `MODE_BASE/bookEvent/reveal` — the `reveal` event triggers a real reel spin.
- `MODE_BONUS/bookEvent/<TYPE>` — one event per type, defined in `src/stories/data/bonus_events.ts`.

## The Action button

Story files set an `action` arg that wraps `playBookEvent` / `playBookEvents`. The Storybook toolbar shows an `Action` button; clicking it triggers the wrapped call. When the call resolves Storybook prints `Action is resolved`. Use this as the smoke test that a new bookEvent or emitterEvent integration works.

## Development loop

1. Write the smallest emitter event you need.
2. Test it in `COMPONENTS/<Component>/emitterEvent`.
3. Compose multiple emitter events into a `bookEvent` and test in `MODE_<MODE>/bookEvent/<TYPE>`.
4. Confirm sequencing with `MODE_<MODE>/book/random`.

If every `bookEvent` resolves cleanly in its story, the game is functionally complete; remaining work is fixture coverage and polish.
