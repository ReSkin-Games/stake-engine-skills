# Distributions

A `Distribution` defines one bucket of outcomes within a `BetMode`: a criteria name, a quota (share of simulations), optional win-amount acceptance, and a `conditions` dict that biases the game logic during sampling.

## Required fields

- `criteria` — single-word identifier (`"basegame"`, `"freegame"`, `"wincap"`, `"0"`, ...).
- `quota` — share of betmode simulations assigned to this criteria. Quotas across a betmode are normalized to sum to 1; a minimum of one simulation is allocated per criteria.
- `conditions` — arbitrary dict; required keys:
  - `reel_weights` — `{gametype: {reelset_id: weight}}`. Drives reelset selection.
  - `force_wincap` (default `False`).
  - `force_freegame` (default `False`).

Common optional keys: `mult_values`, `scatter_triggers`, `prize_values`, anything game-specific.

## Optional acceptance: `win_criteria`

`win_criteria` couples a criteria to a specific final payout multiplier. When `check_repeat()` runs and `win_criteria is not None`, the simulation's `final_win` must match exactly.

Common values:

- `win_criteria=0.0` — force a losing spin.
- `win_criteria=self.wincap` — force a max-win.

## Why pre-assign criteria

Criteria are assigned to specific simulation IDs **before** any simulation runs. This prevents straggler threads — for example, max-win criteria are rare and slow to satisfy naturally; pre-assignment plus biased `conditions` shortens convergence time and balances threads.

## Using conditions in game logic

During `run_spin()`, conditions are read via `BetMode.get_distribution_conditions()`:

```python
multiplier = get_random_outcome(
    self.get_current_distribution_conditions()["mult_values"][self.gametype]
)
```

```python
if self.get_current_distribution_conditions()["force_freegame"]:
    # bias reel-stop selection toward scatter symbols
    ...
```

`force_wincap` / `force_freegame` are read by `Executables.draw_board()` and `force_special_board()` to push the board into the required state.

## Acceptance flow

After a spin completes, `check_repeat()` verifies:

1. If `win_criteria` is set, `final_win == win_criteria`.
2. If `force_freegame` is set, the freegame was entered.
3. Game-specific extensions (added by the game).

If any check fails, `self.repeat = True` and the spin is re-rolled with the same seed-mutation.

The stricter the criteria, the longer the rejection-sample loop runs — keep `quota` realistic and bias `conditions` to make rare outcomes reachable.

## Example: four-criteria basegame

```python
distributions=[
    Distribution(criteria="winCap",   quota=0.001, win_criteria=self.wincap,
                 conditions={"reel_weights": {...}, "force_wincap": True, "force_freegame": True}),
    Distribution(criteria="freegame", quota=0.1,
                 conditions={"reel_weights": {...}, "force_freegame": True}),
    Distribution(criteria="0",        quota=0.4, win_criteria=0.0,
                 conditions={"reel_weights": {self.basegame_type: {"BR0": 1}}}),
    Distribution(criteria="basegame", quota=0.5,
                 conditions={"reel_weights": {self.basegame_type: {"BR0": 1}}}),
]
```

## Output artifacts

- `library/lookup_tables/lookUpTableIdToCriteria_<betmode>.csv` — map of simulation ID → criteria.
- `library/lookup_tables/lookUpTableSegmented_<betmode>.csv` — basegame vs freegame payout split per simulation. Used by the analysis (PAR sheet) and optimizer to allocate RTP across game types.
