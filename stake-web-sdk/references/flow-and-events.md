# Flow and Events

How a Stake Engine game frontend processes a round.

## Table of contents

- [High level](#high-level)
- [book](#book)
- [bookEvent](#bookevent)
- [bookEventHandler and bookEventHandlerMap](#bookeventhandler)
- [playBookEvents()](#playbookevents)
- [eventEmitter](#eventemitter)
- [emitterEvent and emitterEventHandlerMap](#emitterevent)
- [Task breakdown](#task-breakdown)
- [Stateless vs stateful games](#stateless-vs-stateful)

<a name="high-level"></a>
## High level

1. The frontend asks the RGS for a round via `/play`.
2. The RGS returns a `book` — JSON whose `events` array is a sequence of `bookEvent`s produced by the math model.
3. The frontend runs `playBookEvents()`, which dispatches each `bookEvent` in order to a `bookEventHandler`.
4. Each handler broadcasts one or more `emitterEvent`s. Svelte components subscribed to those events run the actual animations, sounds, and DOM/Pixi updates.

The order of `book.events` strictly determines what the player sees: render a "win" before a "spin" and the game is wrong.

<a name="book"></a>
## book

JSON returned per round. Example shape from `web-sdk/apps/lines/src/stories/data/base_books.ts`:

```ts
{
  id: 1,
  payoutMultiplier: 0.0,
  events: [
    {
      index: 0,
      type: 'reveal',
      board: [
        [{ name: 'L2' }, { name: 'L1' }, { name: 'L4' }, { name: 'H2' }, { name: 'L1' }],
        // ...
      ],
      paddingPositions: [216, 205, 195, 16, 65],
      gameType: 'basegame',
      anticipation: [0, 0, 0, 0, 0],
    },
    { index: 1, type: 'setTotalWin', amount: 0 },
    { index: 2, type: 'finalWin', amount: 0 },
  ],
  criteria: '0',
  baseGameWins: 0.0,
  freeGameWins: 0.0,
}
```

<a name="bookevent"></a>
## bookEvent

One element of `book.events`. Each has a `type` discriminator. Examples:

```ts
{ index: 0, type: 'reveal', board: [...], paddingPositions: [...], gameType: 'basegame', anticipation: [...] }
{ index: 1, type: 'setTotalWin', amount: 0 }
```

Type union is defined per app in `web-sdk/apps/<game>/src/game/typesBookEvent.ts`.

<a name="bookeventhandler"></a>
## bookEventHandler and bookEventHandlerMap

A `bookEventHandler` is an async function `(bookEvent) => Promise<void>`. It usually emits one or more `emitterEvent`s.

`bookEventHandlerMap` is an object keyed by `bookEvent.type`. Defined per app in `web-sdk/apps/<game>/src/game/bookEventHandlerMap.ts`.

```ts
export const bookEventHandlerMap: BookEventHandlerMap<BookEvent, BookEventContext> = {
  updateFreeSpin: async (bookEvent: BookEventOfType<'updateFreeSpin'>) => {
    eventEmitter.broadcast({ type: 'freeSpinCounterShow' });
    eventEmitter.broadcast({
      type: 'freeSpinCounterUpdate',
      current: bookEvent.amount,
      total: bookEvent.total,
    });
  },
};
```

<a name="playbookevents"></a>
## playBookEvents()

Created by `web-sdk/packages/utils-book/src/createPlayBookUtils.ts`.

- Walks `book.events` and dispatches each to `playBookEvent()`.
- `playBookEvent(event, ctx)` looks up `bookEventHandlerMap[event.type]` and awaits it.
- Resolution is strictly sequential via an internal `sequence()` helper (not `Promise.all`), because order is significant.

Storybook reuses both functions:

- `MODE_<MODE>/book/random` calls `playBookEvents()` against a random book.
- `MODE_<MODE>/bookEvent/<TYPE>` calls `playBookEvent()` against a single event.

<a name="eventemitter"></a>
## eventEmitter

Provided by `web-sdk/packages/utils-event-emitter`. Bridges the JavaScript scope (where handlers run) and the Svelte component scope (where animations live), avoiding heavy prop drilling.

Three primary methods:

- `eventEmitter.broadcast(emitterEvent)` — fire and forget, synchronous receivers.
- `eventEmitter.broadcastAsync(emitterEvent)` — awaits all async subscribers; used when a handler must wait for animations.
- `eventEmitter.subscribeOnMount(emitterEventHandlerMap)` — registers a component's handlers for its mounted lifetime.

<a name="emitterevent"></a>
## emitterEvent and emitterEventHandlerMap

An `emitterEvent` is the payload broadcast through `eventEmitter`. Conceptually a `bookEvent` is composed of many `emitterEvent`s, and the receivers can live in different Svelte components.

Synchronous receiver:

```ts
// In bookEventHandlerMap.ts
eventEmitter.broadcast({
  type: 'freeSpinCounterUpdate',
  current: undefined,
  total: bookEvent.totalFs,
});

// In FreeSpinCounter.svelte
context.eventEmitter.subscribeOnMount({
  freeSpinCounterUpdate: (emitterEvent) => {
    if (emitterEvent.current !== undefined) current = emitterEvent.current;
    if (emitterEvent.total !== undefined) total = emitterEvent.total;
  },
});
```

Asynchronous receiver — handler awaits animation completion via `waitForResolve`:

```ts
// In bookEventHandlerMap.ts
await eventEmitter.broadcastAsync({
  type: 'freeSpinIntroUpdate',
  totalFreeSpins: bookEvent.totalFs,
});

// In FreeSpinIntro.svelte
context.eventEmitter.subscribeOnMount({
  freeSpinIntroUpdate: async (emitterEvent) => {
    freeSpinsFromEvent = emitterEvent.totalFreeSpins;
    await waitForResolve((resolve) => (oncomplete = resolve));
  },
});
```

The `emitterEventHandlerMap` lives inside each component. Each handler should do the minimum needed for one named responsibility (Single Responsibility Principle) — e.g. `freeSpinCounterShow` only toggles visibility.

<a name="task-breakdown"></a>
## Task breakdown

When a `bookEvent` is complex, split it into many small `emitterEvent`s rather than one fat one. Example for `tumbleBoard`:

```ts
tumbleBoard: async (bookEvent: BookEventOfType<'tumbleBoard'>) => {
  eventEmitter.broadcast({ type: 'tumbleBoardShow' });
  eventEmitter.broadcast({ type: 'tumbleBoardInit', addingBoard: bookEvent.newSymbols });
  await eventEmitter.broadcastAsync({
    type: 'tumbleBoardExplode',
    explodingPositions: bookEvent.explodingSymbols,
  });
  eventEmitter.broadcast({ type: 'tumbleBoardRemoveExploded' });
  await eventEmitter.broadcastAsync({ type: 'tumbleBoardSlideDown' });
  eventEmitter.broadcast({
    type: 'boardSettle',
    board: stateGameDerived.tumbleBoardCombined().map(/* ... */),
  });
  eventEmitter.broadcast({ type: 'tumbleBoardReset' });
  eventEmitter.broadcast({ type: 'tumbleBoardHide' });
},
```

Receiving component subscribes to each subtask:

```svelte
context.eventEmitter.subscribeOnMount({
  tumbleBoardShow: () => {},
  tumbleBoardHide: () => {},
  tumbleBoardInit: () => {},
  tumbleBoardReset: () => {},
  tumbleBoardExplode: () => {},
  tumbleBoardRemoveExploded: () => {},
  tumbleBoardSlideDown: () => {},
});
```

Each subtask gets its own Storybook story under `COMPONENTS/<Game>/emitterEvent`, so each step can be tested in isolation.

<a name="stateless-vs-stateful"></a>
## Stateless vs stateful games

- **Stateless** — one RGS `/play` request resolves the whole round (typical slots). The frontend just plays back the returned `book`.
- **Stateful** — multiple RGS requests within a round (e.g. mines). The flow above still applies per request, but the frontend needs to track interim state between requests.
