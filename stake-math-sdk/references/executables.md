# Executables

`Executables` (`math-sdk/src/executables/`) groups reusable game actions invoked from `run_spin()` / `run_freespin()`. Functions are mutators on `self` (the `GameState`) and generally do not return values. They are overridden in `GameExecutables` (`games/<game>/game_executables.py`) for game-specific behavior.

## Board

- `draw_board(emit_event: bool = True)` — if betmode criteria specify a forced scatter count, drives the reveal to satisfy it; otherwise draws a board and ensures it does not over-trigger.
- `force_special_board(force_criteria: str, num_force_syms: int)` — forces a specified count of a named symbol by overriding reel stops.
- `get_syms_on_reel(reel_id: str, target_symbol: str) -> List[List]` — reel stop positions where `target_symbol` appears.

## Tumbling and wincap

- `tumble_game_board()` — removes winning (`explode`-tagged) symbols and refills via `Tumble`, emits `tumble_board_event`.
- `evaluate_wincap()` — checks `running_bet_win` against `config.wincap`; sets `self.wincap_triggered` and short-circuits subsequent spin actions.

## Special-symbol queries

- `count_special_symbols(special_sym_criteria: str) -> int` — count active symbols of a given attribute.
- `check_fs_condition(scatter_key: str = "scatter") -> bool` — `True` if enough scatters are present to trigger freespins.
- `check_freespin_entry(scatter_key: str = "scatter") -> bool` — verifies that the betmode criteria expect a freespin trigger (guards against spurious scatter-driven entries during basegame-only criteria).

## Free spins

- `run_freespin_from_base(scatter_key: str = "scatter")` — `record()`s the trigger, sets `tot_fs`, calls `run_freespin()`.
- `update_freespin_amount(scatter_key: str = "scatter")` — sets initial `tot_fs` from `config.freespin_triggers[gametype][scatter_count]`; emits `fs_trigger_event`.
- `update_fs_retrigger_amt(scatter_key: str = "scatter")` — adds retrigger spins.
- `update_freespin()` — increments spin counter, resets `spin_win`, emits the spin counter event.
- `end_freespin()` — emits final freegame win event.

## Win emission

- `emit_linewin_events()` — line-win events.
- `emit_wayswin_events()` — ways-win events.
- `emit_tumble_win_events()` — emits both new-board and win-info events for the post-tumble state.

## Finalization

- `evaluate_finalwin()` — sums basegame + freegame contributions, sets `payoutMultiplier`.
- `update_global_mult()` — increments the global multiplier and emits the event.

## Extension pattern

Subclass `Executables` via `GameExecutables`:

```python
# games/0_0_scatter/game_executables.py
def update_freespin_amount(self, scatter_key: str = "scatter"):
    self.tot_fs = self.count_special_symbols(scatter_key) * 2
    fs_trigger_event(self, basegame_trigger=basegame_trigger, freegame_trigger=freegame_trigger)
```

Game-specific calculations belong in `GameCalculations` (inherits `GameExecutables`). One-off helpers stay in the game folder; anything broadly reusable should be promoted to `src/`.

## Dependencies

`Executables` imports:

- `src.state.state_conditions.Conditions`
- `src.calculations.{lines, ways, cluster, scatter, tumble}`
- `src.calculations.statistics.get_random_outcome`
- `src.events.events.*`
