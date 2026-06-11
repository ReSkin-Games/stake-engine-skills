# Wins and Events

## Contents

- `win_data` structure
- Multiplier strategies
- Overlay positions
- WinManager (wallet)
- Event structure
- Event factory functions
- Source files

## `win_data` structure

All win-evaluation functions (`get_lines`, `get_ways`, `get_cluster_data`, `get_scatterpay_wins`) return:

```python
win_data = {
    "totalWin": float,
    "wins": [
        {
            "symbol": str,
            "kind": int,
            "win": float,
            "positions": [{"reel": int, "row": int}, ...],
            "meta": {...},
        },
        ...
    ],
}
```

`positions` is required when using the built-in win events (the renderer adjusts `row` for padding).

Lines `meta` example:

```python
"meta": {
    "lineIndex": 12,
    "multiplier": 10,
    "winWithoutMult": 30,
    "globalMult": 1,
    "lineMultiplier": 10,
}
```

## Multiplier strategies

`src/wins/multiplier_strategy.py` exposes `apply_mult(strategy, base_win, positions)` with three strategies:

- `"global"` — apply only the global multiplier.
- `"symbol"` — sum multipliers from `multiplier`-tagged symbols in `positions`.
- `"combined"` — sum symbol multipliers, then apply the global multiplier.

For `"symbol"` and `"combined"`, multiplier values **add** by default (lines/cluster/scatter). Ways wins multiply instead — see `calculations.md`.

## Overlay positions

Cluster and scatter `meta` blocks include:

```python
"meta": {
    ...,
    "overlay": {"reel": int, "row": int},
}
```

Computed as the board position closest to the cluster center of mass — used by the frontend to anchor win labels.

## WinManager (wallet)

`WinManager` (`math-sdk/src/wins/`) tracks wins at three scopes. Construction:

```python
class WinManager:
    def __init__(self, base_game_mode, free_game_mode):
        self.total_cumulative_wins = 0
        self.cumulative_base_wins = 0
        self.cumulative_free_wins = 0

        self.running_bet_win = 0.0
        self.basegame_wins = 0.0
        self.freegame_wins = 0.0
        self.spin_win = 0.0
        self.tumble_win = 0.0
```

Scope-by-scope:

- `spin_win` — win for a single `reveal` event; reset each new spin (including each freespin). Updated by `update_spinwin(win_amount)`.
- `running_bet_win` — cumulative win for the whole simulation; auto-updated by `set_spinwin()`. Its final value equals the book's `payoutMultiplier`.
- `basegame_wins` / `freegame_wins` — per-simulation gametype splits. Updated by `update_gametype_wins(self.gametype)` after basegame actions complete and after each freegame spin. **Invariant**: `final_win == basegame_wins + freegame_wins`. Mismatch raises `RuntimeError`. Used by `lookUpTableSegmented`.
- `cumulative_*` — across the simulation batch; updated in `imprint_wins()` via `update_end_round_wins()`. Printed in per-thread RTP summaries.

Typical spin block:

```python
self.win_data = self.get_lines()
self.win_manager.update_spinwin(self.win_data["totalWin"])
self.emit_linewin_events()
...
self.win_manager.update_gametype_wins(self.gametype)
```

## Event structure

Events are the JSON payload returned by the RGS `/play` API. They live in `book["events"]` and are the only data the frontend can render.

Schema:

```python
event = {
    "index": int,     # monotonically increasing position in the book
    "type": str,      # short identifier; e.g. "reveal", "winInfo", "setWin"
    # arbitrary additional fields per event type
}

gamestate.book.add_event(event)
```

Events are **snapshots**: they must be emitted immediately after the state change they describe. Mutating state without emitting an event means the frontend cannot render that change.

Events are imported as functions (not methods) and called with `self` (the `GameState`) as the first argument.

## Event factory functions

`math-sdk/src/events/events.py` provides the standard set. Each appends a dict to `gamestate.book["events"]` and deep-copies inputs.

- `reveal_event(gamestate)` — initial board (with padding if enabled).
- `fs_trigger_event(gamestate, include_padding_index, basegame_trigger, freegame_trigger)` — freespin start; asserts exactly one trigger flag and `tot_fs > 0`.
- `update_freespin_event(gamestate)` — current / total freespin counters.
- `freespin_end_event(gamestate, winlevel_key="endFeature")` — end of freegame.
- `win_info_event(gamestate, include_padding_index=True)` — winning positions and amounts.
- `set_win_event(gamestate, winlevel_key="standard")` — cumulative for one outcome.
- `set_total_event(gamestate)` — cumulative for the round (incl. all freespins).
- `set_tumble_event(gamestate)` — wins across consecutive tumbles.
- `update_tumble_win_event(gamestate)` — tumble win banner update.
- `tumble_board_event(gamestate)` — removed positions and replacement symbols.
- `update_global_mult_event(gamestate)` — global multiplier change.
- `wincap_event(gamestate)` — wincap reached; stops further spins.
- `final_win_event(gamestate)` — final `payoutMultiplier`.
- `json_ready_sym(symbol, special_attributes)` — helper that converts a symbol to a JSON dict, including only listed attributes when truthy.

Event-type identifiers used by the frontend live in `math-sdk/src/events/event_constants.py`.

## Source files

- `math-sdk/src/events/events.py` — factory functions.
- `math-sdk/src/events/event_constants.py` — type-name constants.
- `math-sdk/src/wins/win_manager.py` — `WinManager` class.
- `math-sdk/src/wins/multiplier_strategy.py` — `apply_mult`.
- `math-sdk/src/calculations/*.py` — `win_data` producers.
