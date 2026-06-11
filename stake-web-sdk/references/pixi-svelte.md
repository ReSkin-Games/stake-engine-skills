# pixi-svelte

A declarative Svelte wrapper around Pixi. Source: `web-sdk/packages/pixi-svelte`. Also published to npm as `pixi-svelte`.

## Problem it solves

Pixi's native API is imperative — create a `PIXI.Application`, instantiate `Container`s and `Sprite`s, mutate their properties in update loops, manage their lifecycle manually. That fights Svelte's reactivity.

`pixi-svelte` lets components be written like normal Svelte: declare a `<Sprite>`, bind reactive props, let mount/unmount manage the underlying Pixi display objects.

## What it provides

- An `<App>` component that owns a `PIXI.Application` and exposes it via context.
- Declarative Svelte wrappers for the common Pixi primitives — `<Sprite>`, `<Container>`, `<Text>`, etc.
- `stateApp` and `AppContext`, registered as a Svelte context. `stateApp` exposes the Pixi instance, the asset manifest, and `loadedAssets` populated by `PIXI.Assets.load`. See `references/context-and-state.md#contextapp`.
- Reactive integration: setting a prop on a component drives the corresponding mutation on the underlying Pixi object.

## Usage shape

```svelte
<App>
  <!-- pixi-svelte components live here -->
  <Sprite texture={loadedAssets.symbolH1} />
  <Container>
    <Text text="Win!" style={{ fill: 0xffffff }} />
  </Container>
</App>
```

Components consume `loadedAssets` directly — see `<Sprite>` at `web-sdk/packages/pixi-svelte/src/lib/components/Sprite.svelte`.

## Layout integration

Pixi has no DOM flow, so positions are explicit. `pixi-svelte` is normally paired with `utils-layout` and `components-layout` for responsive coordinates relative to the canvas. See `references/context-and-state.md#contextlayout`.

## Where to look

Component source and props live in `web-sdk/packages/pixi-svelte/src/lib/components/`. The dedicated Storybook for these components is `web-sdk/packages/pixi-svelte-storybook` — run with `pnpm run storybook --filter=pixi-svelte-storybook`.
