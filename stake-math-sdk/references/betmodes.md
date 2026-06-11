# Betmodes

A `BetMode` is one purchasable bet variant (e.g. `base`, `bonus`, `superspin`). It carries cost, RTP target, max-win, behavior flags, and a list of `Distribution` entries that partition the simulation outcomes.

All betmodes for a game are registered in `GameConfig.bet_modes = [...]`.

## Required arguments

```python
BetMode(
    name=str,
    cost=float,           # bet cost multiplier (1.0 for base, 100.0 for bonus buy, etc.)
    rtp=float,            # target RTP
    max_win=float,        # payout cap
    auto_close_disabled=bool,
    is_feature=bool,
    is_buybonus=bool,
    distributions=[Distribution(...), ...],
)
```

## Flags

- `auto_close_disabled` (default `False`) — when `False`, the RGS calls `/endround` automatically when a bet closes. Set `True` for bonus modes where the player must be able to resume an interrupted round (the frontend then must close the bet manually).
- `is_feature` — when `True`, the frontend keeps this betmode active across spins without re-confirmation. Used for non-bonus feature modes where the spin button should re-trigger the same mode.
- `is_buybonus` — frontend flag that this mode was purchased directly (may change assets shown).

## Distributions (summary)

Each `Distribution` partitions simulations by win criteria; `quota` is normalized across the betmode. The `BetMode.get_distribution_conditions()` method exposes per-criteria conditions during a spin. See `distributions.md` for full details.

## Example: bonus buy from `0_0_lines`

```python
BetMode(
    name="bonus",
    cost=100.0,
    rtp=self.rtp,
    max_win=self.wincap,
    auto_close_disabled=False,
    is_feature=False,
    is_buybonus=True,
    distributions=[
        Distribution(
            criteria="wincap",
            quota=0.001,
            win_criteria=self.wincap,
            conditions={
                "reel_weights": {
                    self.basegame_type: {"BR0": 1},
                    self.freegame_type: {"FR0": 1, "WCAP": 5},
                },
                "mult_values": {
                    self.basegame_type: {1: 1},
                    self.freegame_type: {2: 10, 3: 20, 4: 50, 5: 60, 10: 100, 20: 90, 50: 50},
                },
                "scatter_triggers": {4: 1, 5: 2},
                "force_wincap": True,
                "force_freegame": True,
            },
        ),
        Distribution(
            criteria="freegame",
            quota=0.999,
            conditions={
                "reel_weights": {
                    self.basegame_type: {"BR0": 1},
                    self.freegame_type: {"FR0": 1},
                },
                "scatter_triggers": {3: 20, 4: 10, 5: 2},
                "mult_values": {
                    self.basegame_type: {1: 1},
                    self.freegame_type: {2: 100, 3: 80, 4: 50, 5: 20, 10: 10, 20: 5, 50: 1},
                },
                "force_wincap": False,
                "force_freegame": True,
            },
        ),
    ],
),
```

## Adding a new betmode

1. Append a `BetMode(...)` to `GameConfig.bet_modes`.
2. Provide at least one `Distribution` covering all simulations of that mode.
3. Add an entry to `num_sim_args` in `run.py` matching the new `name`.
4. Reference `conditions["reel_weights"]` to existing reelset IDs registered in `GameConfig.reels`.
5. Re-run with `run_sims: True`, then enable `run_optimization: True` once book output is correct.

## RTP constraint

Every betmode must fall within 0.5% RTP of the base betmode (Stake Engine validation rule). See `faq.md`.
