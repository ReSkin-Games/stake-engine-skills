# UI and Components

The Web SDK ships two UI packages: one rendered inside the Pixi canvas, one rendered as HTML overlays.

## Packages

| Package | Purpose | Path |
|---------|---------|------|
| `components-ui-pixi` | In-canvas HUD (bet panel, auto-bet, turbo mode, bonus buttons, responsiveness). | `web-sdk/packages/components-ui-pixi` |
| `components-ui-html` | DOM-level overlays — modals, game version display, anything outside the canvas. | `web-sdk/packages/components-ui-html` |

Both are functional but visually plain. Treat them as a starting skeleton, not a finished product. Replacing either with a custom UI is fully supported.

## Wiring example

Taken from the upstream UI doc. Pixi components live inside `<App>`; HTML components live alongside it.

```svelte
<script lang="ts">
  import { UI, UiGameName } from 'components-ui-pixi';
  import { GameVersion, Modals } from 'components-ui-html';
</script>

<App>
  <UI>
    {#snippet gameName()}
      <UiGameName name="LINES GAME" />
    {/snippet}
    {#snippet logo()}
      <Text
        anchor={{ x: 1, y: 0 }}
        text="ADD YOUR LOGO"
        style={{
          fontFamily: 'proxima-nova',
          fontSize: REM * 1.5,
          fontWeight: '600',
          lineHeight: REM * 2,
          fill: 0xffffff,
        }}
      />
    {/snippet}
  </UI>
</App>

<Modals>
  {#snippet version()}
    <GameVersion version="0.0.0" />
  {/snippet}
</Modals>
```

`<UI>` exposes named snippets (`gameName`, `logo`, etc.) so the host app injects branding without forking the component. The same pattern applies to `<Modals>`.

## Built-in features

`components-ui-pixi`'s `<UI>` covers:

- Auto-bet with a countdown (driven by `STATE_AUTOBET` in the XState actor).
- Turbo mode toggle.
- Bonus / feature-buy button surface.
- Responsiveness — layout adapts to `stateLayoutDerived.layoutType` and `canvasSizes` (see `references/context-and-state.md`).

## Branding guidance

The upstream recommendation is to use these packages as scaffolding only: extend their styles or replace them entirely. Building UI from scratch is fine — none of the game flow (book/bookEvent/emitterEvent) depends on these packages.
