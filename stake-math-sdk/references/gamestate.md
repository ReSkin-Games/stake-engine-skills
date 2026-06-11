# GameState

`GameState` is the central object that coordinates a simulation batch. It owns global config, the simulation library, the WinManager, and (per-spin) the active book.

## Contents

- Role
- Class inheritance / MRO
- Per-spin lifecycle: `run_spin`
- `reset_book`
- Books and library
- Where to look in source

## Role

A single `GameState` instance is constructed in `run.py` and passed to `create_books()`. It carries:

- simulation parameters (compression, threads, batching)
- betmodes (cost, RTP, criteria)
- paytable, symbols, reelsets
- the cumulative `WinManager`
- the in-progress `book` for the current simulation

When `run_spin()` is called, `self` is mutated in place rather than passing state between functions.

## Class inheritance / MRO

Game-specific behavior is layered on by Python MRO:

1. `GameStateOverride` (`games/<game>/game_override.py`) — first in MRO; overrides anything from `state.py`. Sample games override `reset_book()` here to add `grid_mults`, `tumble_win`, etc.
2. `GameExecutables` (`games/<game>/game_executables.py`) — overrides shared executables (e.g. `update_freespin_amount`).
3. `GameCalculations` (`games/<game>/game_calculations.py`) — inherits `GameExecutables`; holds game-specific math.

The base class `GeneralGameState` lives at `math-sdk/src/state/state.py` and is an ABC: `assign_special_sym_function`, `run_spin`, `run_freespin` must be implemented downstream.

### `reset_book` override example

```python
def reset_book(self):
    super().reset_book()
    self.reset_grid_mults()
    self.reset_grid_bool()
    self.tumble_win = 0
```

## Per-spin lifecycle: `run_spin`

Canonical sample-game structure:

```python
def run_spin(self, sim):
    self.reset_seed(sim)        # seed RNG with simulation index
    self.repeat = True
    while self.repeat:
        self.reset_book()       # clears self.book and per-spin state
        self.draw_board()       # picks reelset, stop positions, builds board

        # evaluate win_data
        # update win_manager
        # emit relevant events

        self.win_manager.update_gametype_wins(self.gametype)
        if self.check_fs_condition():
            self.run_freespin_from_base()

        self.evaluate_finalwin()
        self.check_repeat()     # verifies betmode Distribution criteria

    self.imprint_wins()         # commits accepted simulation to library
```

The `self.repeat` flag drives rejection sampling — a simulation is re-rolled until it satisfies the pre-assigned Distribution criteria. `reset_book()` resets `self.repeat = False`; `check_repeat()` sets it back to `True` if the criteria are not met.

`reset_seed(sim)` makes simulations reproducible — given the same RNG seed and same config, simulation `id=N` always yields the same result.

## `reset_book`

Defined in `math-sdk/src/state/state.py`. Default body:

```python
def reset_book(self) -> None:
    self.book = {
        "id": self.sim + 1,
        "payoutMultiplier": 0.0,
        "events": [],
        "criteria": self.criteria,
    }
```

Plus resets to `board`, `book_id`, `win_data`, and `win_manager` spin-level counters.

## Books and library

A "book" is one simulation's result:

```json
{
  "id": 1,
  "payoutMultiplier": 10.0,
  "events": [{}, {}],
  "criteria": "basegame",
  "baseGameWins": 0.1,
  "freeGameWins": 0.0
}
```

Books accumulate in `self.library` (per betmode) and are serialized by `src/write_data/`. `book["events"]` is the exact payload returned by the RGS `/play` API.

## Useful `GameState` attributes (selected)

- `self.config` — the `GameConfig` instance.
- `self.gametype` — `"basegame"` or `"freegame"` (or game-defined alternative).
- `self.criteria` — the Distribution criteria pre-assigned to this simulation.
- `self.sim` / `self.book_id` — current simulation index.
- `self.board` / `self.top_symbols` / `self.bottom_symbols` — current display state.
- `self.special_symbols_on_board` — `{property: [{"reel": int, "row": int}, ...]}`.
- `self.win_data` — `{"totalWin": float, "wins": [...]}` from the last evaluation.
- `self.win_manager` — see `wins-and-events.md`.
- `self.tot_fs` / `self.fs` — total / current free spin counters.
- `self.repeat` / `self.wincap_triggered` — control flags.

## Where to look in source

- `math-sdk/src/state/state.py` — `GeneralGameState` base.
- `math-sdk/src/state/state_conditions.py` — `Conditions` helpers (`in_criteria`, `check_fs_condition`).
- `games/<game>/gamestate.py` — concrete `GameState` with `run_spin` / `run_freespin`.
- `games/<game>/game_override.py` — first-in-MRO overrides.
