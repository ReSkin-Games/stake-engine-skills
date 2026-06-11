# Troubleshooting

Pitfalls and constraints documented in the upstream Web SDK pages. Items not explicitly documented are flagged as such — refer to upstream source for anything missing.

## Context not set

Symptom: components in `apps/` or `packages/components-*` throw on mount when calling `getContext...()`.

Cause: the entry component did not call `setContext()` (defined in `web-sdk/apps/<app>/src/game/context.ts`).

Fix: ensure both surfaces register context:

- Dev server entry — `web-sdk/apps/<app>/src/routes/+page.svelte`.
- Every Storybook story file — `*.stories.svelte` files under `src/stories/`.

Pattern:

```svelte
<script lang="ts">
  import Game from '../components/Game.svelte';
  import { setContext } from '../game/context';
  setContext();
</script>

<Game />
```

## Pixi positioning has no auto-flow

Symptom: components overlap or sit at `(0, 0)`.

Cause: Pixi does not auto-layout. Coordinates and anchors must be set explicitly.

Fix: position relative to `context.stateLayoutDerived.canvasSizes()`. For right-edge alignment, also set `anchor={{ x: 1, y: 0 }}` because Pixi draws from top-left. Right-edge alignment only resolves against the canvas when `<App />` is the direct parent; otherwise positions are relative to the enclosing `<Container />`.

## bookEvent order matters

Symptom: animations appear in the wrong order (e.g. a "win" before the spin).

Cause: `playBookEvents()` resolves each handler sequentially via an internal `sequence()` helper — not `Promise.all`. The order of `book.events` is therefore the player-visible order.

Fix: ensure the math model emits events in the intended visual order. Inspect fixtures under `src/stories/data/`.

## Async handlers must use broadcastAsync

Symptom: the next `bookEvent` starts before the current animation finishes.

Cause: a handler used `eventEmitter.broadcast()` instead of `eventEmitter.broadcastAsync()`, so the awaiting promise is missing.

Fix: when a step must complete before the next event, `await eventEmitter.broadcastAsync(...)`. The subscribing component should resolve its `oncomplete` callback when the animation finishes (e.g. via `waitForResolve`).

## Emitter event types not visible in handler

Symptom: TypeScript does not narrow `bookEvent` inside `bookEventHandlerMap.ts`, or emitter events fail to type-check.

Cause: the new union member was not added to one of:

- `web-sdk/apps/<app>/src/game/typesBookEvent.ts` — `BookEvent` union.
- The component-local `EmitterEvent<Name>` exported from the component's `<script module>`.
- `web-sdk/apps/<app>/src/game/typesEmitterEvent.ts` — `EmitterEventGame` union.
- `web-sdk/apps/<app>/src/game/eventEmitter.ts` — `EmitterEvent` composes `EmitterEventUi | EmitterEventHotKey | EmitterEventGame`.

Fix: add the missing union member; see `references/adding-events.md` for the full chain.

## Storybook story does nothing on Action

Symptom: clicking `Action` in `MODE_<MODE>/bookEvent/<TYPE>` succeeds but no animation runs.

Cause: the story exists (`ModeBonusBookEvent.stories.svelte`) but no `bookEventHandler` is registered yet, or the handler does not broadcast any emitter event.

Fix: add the handler in `bookEventHandlerMap.ts` and make sure a mounted component subscribes to the broadcast event types.

## Static build only

Symptom: deployed game expects an API route or SSR endpoint.

Cause: the Stake Engine CDN only serves static assets — no Node server.

Fix: configure SvelteKit with `@sveltejs/adapter-static`; never introduce server-only routes. All non-RGS state stays client-side.

## FAQ coverage

No frontend-specific entries currently live under `/tmp/stake-engine-docs-source/src/routes/faq/`. The "Getting Started" FAQ category only contains generic onboarding ("how do I start building a game?"). For frontend FAQs, refer back to the Web SDK doc pages directly.
