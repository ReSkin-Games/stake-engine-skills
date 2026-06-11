# Adding a New bookEvent

End-to-end recipe for wiring a new `bookEvent` into the canonical `lines` sample. Replace `lines` with the target app and `updateGlobalMult` with the new event type.

Assumption: the math model already produces the new event. The frontend work is purely consuming it.

## 1. Add the event payload to story fixtures

Storybook data simulates the RGS response.

**`web-sdk/apps/lines/src/stories/data/bonus_books.ts`** — array of bonus-mode books for `MODE_BONUS/book/random`. Insert the new event inside an existing book's `events` array:

```ts
{
  type: 'updateGlobalMult',
  globalMult: 3,
},
```

**`web-sdk/apps/lines/src/stories/data/bonus_events.ts`** — object keyed by event type for `MODE_BONUS/bookEvent/<TYPE>`:

```ts
export default {
  // ...
  updateGlobalMult: {
    type: 'updateGlobalMult',
    globalMult: 3,
  },
  // ...
};
```

## 2. Register a Storybook story for the event

**`web-sdk/apps/lines/src/stories/ModeBonusBookEvent.stories.svelte`**:

```svelte
<Story
  name="updateGlobalMult"
  args={templateArgs({
    skipLoadingScreen: true,
    data: events.updateGlobalMult,
    action: async (data) => await playBookEvent(data, { bookEvents: [] }),
  })}
/>
```

After this step the story appears with an `Action` button. Clicking it currently does nothing — the handler is added in step 4.

## 3. Add the TypeScript type for the bookEvent

**`web-sdk/apps/lines/src/game/typesBookEvent.ts`**. Define the variant and add it to the `BookEvent` union:

```ts
type BookEventUpdateGlobalMult = {
  index: number;
  type: 'updateGlobalMult';
  globalMult: number;
};

export type BookEvent =
  | /* existing variants */
  | BookEventUpdateGlobalMult;
```

Adding this first gives TypeScript intellisense for the handler in step 4.

## 4. Add the bookEventHandler

**`web-sdk/apps/lines/src/game/bookEventHandlerMap.ts`** — add a new key that broadcasts the relevant emitter events. Intellisense from step 3 narrows `bookEvent` to the right variant.

## 5. Create the target Svelte component

**`web-sdk/apps/lines/src/components/GlobalMultiplier.svelte`**. Declare the component-local emitter event union in a `module` script — exported types are used by the global emitter event union in step 6:

```svelte
<script lang="ts" module>
  export type EmitterEventGlobalMultiplier =
    | { type: 'globalMultiplierShow' }
    | { type: 'globalMultiplierHide' }
    | { type: 'globalMultiplierUpdate'; multiplier: number };
</script>
```

## 6. Register the emitter events globally

**`web-sdk/apps/lines/src/game/typesEmitterEvent.ts`** — import the new component-local union and add it to `EmitterEventGame`:

```ts
import type { EmitterEventGlobalMultiplier } from '../components/GlobalMultiplier.svelte';

export type EmitterEventGame =
  | /* existing variants */
  | EmitterEventGlobalMultiplier;
```

**`web-sdk/apps/lines/src/game/eventEmitter.ts`** — `EmitterEvent` is composed of `EmitterEventUi`, `EmitterEventHotKey`, and `EmitterEventGame`, so the new union flows through automatically:

```ts
import type { EmitterEventGame } from './typesEmitterEvent';
export type EmitterEvent = EmitterEventUi | EmitterEventHotKey | EmitterEventGame;
export const { eventEmitter } = createEventEmitter<EmitterEvent>();
```

## 7. Subscribe inside the component

Back in `GlobalMultiplier.svelte`, add the subscriber and the visuals:

```svelte
<script lang="ts" module>
  export type EmitterEventGlobalMultiplier =
    | { type: 'globalMultiplierShow' }
    | { type: 'globalMultiplierHide' }
    | { type: 'globalMultiplierUpdate'; multiplier: number };
</script>

<script lang="ts">
  // ...
  context.eventEmitter.subscribeOnMount({
    globalMultiplierShow: () => (show = true),
    globalMultiplierHide: () => (show = false),
    globalMultiplierUpdate: async (emitterEvent) => {
      console.log(emitterEvent.multiplier);
    },
  });
</script>

<SpineProvider key="globalMultiplier" width={PANEL_WIDTH}>
  <SpineTrack trackIndex={0} {animationName} />
</SpineProvider>
```

## 8. Test in isolation

Storybook story `MODE_BONUS/bookEvent/updateGlobalMult` → click `Action`. Expect to see the component animate and an `Action is resolved` confirmation.

If debugging is awkward, add a lower-level story under `COMPONENTS/<GlobalMultiplierSpine>/component` that takes plain props instead of being driven by emitter events.

## 9. Test in a full book

Storybook story `MODE_BONUS/book/random`. The new event is now part of the fixture (step 1), so repeated `Action` clicks will eventually trigger it inside a full sequence.
