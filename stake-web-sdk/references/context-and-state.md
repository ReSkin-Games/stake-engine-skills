# Context and State

The Web SDK wires shared state through four Svelte contexts. The entry component calls `setContext()` once; descendants in `apps/` and `packages/components-*` call the matching `getContext...()` to read.

## Table of contents

- [Entry point](#entry-point)
- [ContextEventEmitter](#contexteventemitter)
- [ContextLayout](#contextlayout)
- [ContextXstate](#contextxstate)
- [ContextApp](#contextapp)

<a name="entry-point"></a>
## Entry point

`web-sdk/apps/<game>/src/game/context.ts` defines a `setContext()` that registers all four contexts:

```ts
export const setContext = () => {
  setContextEventEmitter<EmitterEvent>({ eventEmitter });
  setContextXstate({ stateXstate, stateXstateDerived });
  setContextLayout({ stateLayout, stateLayoutDerived });
  setContextApp({ stateApp });
};
```

It is called at the highest mountable level — `web-sdk/apps/<game>/src/routes/+page.svelte` for the dev server, and the equivalent in `*.stories.svelte` files for Storybook. Children that omit a matching `getContext...()` will throw at runtime.

Different apps and packages opt into different subsets — only register what the app needs.

<a name="contexteventemitter"></a>
## ContextEventEmitter

`eventEmitter` is created by `web-sdk/packages/utils-event-emitter/src/createEventEmitter.ts`. See `references/flow-and-events.md` for usage. The context is the bridge between the JS-side handlers and the Svelte component-side subscribers.

<a name="contextlayout"></a>
## ContextLayout

`stateLayout` and `stateLayoutDerived` come from `web-sdk/packages/utils-layout/src/createLayout.svelte.ts`. They expose:

- `canvasSizes` — current width/height derived from `svelte/reactivity/window` (`innerWidth`, `innerHeight`). The Pixi `Application` is configured with `resizeTo: window`, so this stays in sync.
- `canvasRatio`, `canvasRatioType`, `canvasSizeType`
- `layoutType` — device class derived from dimensions; switch between portrait and landscape arrangements.
- `isStacked`, `mainLayout`, `normalBackgroundLayout`, `portraitBackgroundLayout`

```ts
const stateLayout = $state({
  showLoadingScreen: true,
});

const stateLayoutDerived = {
  canvasSizes,
  canvasRatio,
  canvasRatioType,
  canvasSizeType,
  layoutType,
  isStacked,
  mainLayout,
  normalBackgroundLayout,
  portraitBackgroundLayout,
};
```

Pixi has no auto-flow, so components position themselves manually using `canvasSizes()`. Right-edge alignment requires setting `anchor` because Pixi draws from top-left:

```svelte
<Component x={0} />                                                <!-- left edge -->
<Component x={context.stateLayoutDerived.canvasSizes().width}
           anchor={{ x: 1, y: 0 }} />                               <!-- right edge -->
```

This only resolves against the canvas when `<App />` is the direct parent; otherwise positions are relative to the enclosing `<Container />`.

<a name="contextxstate"></a>
## ContextXstate

`stateXstate` and `stateXstateDerived` come from `web-sdk/packages/utils-xstate/src/createXstateUtils.svelte.ts`. They wrap an XState `gameActor` defined in `createGameActor.svelte.ts`.

```ts
const stateXstate = $state({
  value: '' as StateValue,
});

const matchesXstate = (state: string) => matchesState(state, stateXstate.value);

const stateXstateDerived = {
  matchesXstate,
  isRendering: () => matchesXstate(STATE_RENDERING),
  isIdle: () => matchesXstate(STATE_IDLE),
  isBetting: () => matchesXstate(STATE_BET),
  isAutoBetting: () => matchesXstate(STATE_AUTOBET),
  isResumingBet: () => matchesXstate(STATE_RESUME_BET),
  isForcingResult: () => matchesXstate(STATE_FORCE_RESULT),
  isPlaying: () => !matchesXstate(STATE_RENDERING) && !matchesXstate(STATE_IDLE),
};
```

The `gameActor` machine:

```ts
const gameMachine = setup({
  actors: {
    bet: intermediateMachines.bet,
    autoBet: intermediateMachines.autoBet,
    resumeBet: intermediateMachines.resumeBet,
    forceResult: intermediateMachines.forceResult,
  },
}).createMachine({
  initial: 'rendering',
  states: {
    [STATE_RENDERING]: stateRendering,
    [STATE_IDLE]: stateIdle,
    [STATE_BET]: stateBet,
    [STATE_AUTOBET]: stateAutoBet,
    [STATE_RESUME_BET]: stateResumeBet,
    [STATE_FORCE_RESULT]: stateForceResult,
  },
});

const gameActor = createActor(gameMachine);
```

States covered out of the box: one-off `bet`, `autoBet` with countdown, `resumeBet` for unfinished rounds, `forceResult` for forced outcomes.

Typical UI usage — disable the bet button while a round is playing:

```svelte
<script lang="ts">
  import { getContext } from '../context';
  const context = getContext();
</script>

<SimpleUiButton disabled={context.stateXstateDerived.isPlaying()} />
```

<a name="contextapp"></a>
## ContextApp

`stateApp` comes from `web-sdk/packages/pixi-svelte/src/lib/createApp.svelte.ts`. It exposes the Pixi application instance and the asset registry:

```ts
const stateApp = $state({
  reset,
  assets,
  loaded: false,
  loadingProgress: 0,
  loadedAssets: {} as LoadedAssets,
  pixiApplication: undefined as PIXI.Application | undefined,
});
```

`assets` is the manifest fed to `PIXI.Assets.load`. The resolved sprites, animations, and sound payloads end up in `loadedAssets`, which Pixi components consume directly — e.g. `<Sprite>` in `web-sdk/packages/pixi-svelte/src/lib/components/Sprite.svelte`.
