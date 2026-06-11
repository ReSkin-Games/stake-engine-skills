# Calculations

Reusable win-evaluation and board-mechanic modules in `math-sdk/src/calculations/`. Each returns the standard `win_data` shape (see `wins-and-events.md`).

## Contents

- Board (`board.py`)
- Lines (`lines.py`)
- Ways (`ways.py`)
- Cluster (`cluster.py`)
- Scatter (`scatter.py`)
- Tumble (`tumble.py`)

## Board

`Board` (inherits `GeneralGameState`) generates the active board from reelstrips. The standard entrypoint is `create_board_reelstrips()`:

1. Pick a reelset via weighted draw from `conditions["reel_weights"][gametype]`. Result stored on `self.reelstrip_id`.
2. For each reel, pick a uniform-random stop position in `[0, len(reelstrip[reel]) - 1]`.
3. Build the 2D `Symbol` array; if the stop position + board height exceeds the strip length, wrap with `(reel_pos - 1) % len(self.reelstrip[reel])`.
4. Populate `self.special_symbols_on_board`, `self.reel_positions`, `self.padding_positions`, and `self.anticipation`.

`anticipation` is a per-reel integer array that increments after the count of trigger scatters meets the freegame threshold. For a 5-reel game needing 3 scatters with scatters already on reels 0 and 1:

```python
self.anticipation = [0, 0, 1, 2, 3]
```

`force_board_from_reelstrips()` allows specific reel-stop overrides; missing reels are randomized. Often paired with `Executables.force_special_board(force_criteria, num_force_syms)` to land a specified count of a named symbol.

Use when: every spin needs a board. This runs first in `run_spin()` via `draw_board()`.

## Lines

`LinesWins.get_lines()` — evaluates winning combinations along paylines from `config.paylines`:

```python
config.paylines = {
    0: [0, 0, 0, 0, 0],
    1: [0, 1, 0, 1, 0],
    ...
}
```

Default 3+ consecutive matching symbols pay; payout from `config.paytable[(kind, name)]`. Wilds use the configured wild attribute (default `"wild"`) and wild symbol name (default `"W"`).

Tie-breaking: if `(kind, "W")` exists, the wild combination is compared to the longer non-wild combination using the same lead symbol; the higher base payout wins. Therefore a common pattern is to only pay wilds at full reel-length (`5-kind` on a 5-reel board) to avoid wild-payouts overriding real wins.

`meta` includes `lineIndex`, `multiplier`, `winWithoutMult`, `globalMult`, `lineMultiplier`.

Use when: standard payline slots.

## Ways

`WaysWins.get_ways()` — evaluates like-symbols on **consecutive reels** independent of row position. Max ways: `num_rows ^ num_columns`.

Multiplier handling differs from lines: instead of adding symbol multipliers, the **ways count is multiplied** by the multiplier value. Example: board

```
L5 H1 L4 L4 L4
L1 H4 L3 H2 L4
H1 H1 H1 L3 H3
```

with a 3x multiplier on the H1 on reel 3 gives `(1) * (2) * (3) = 6` ways for `(3, H1)`.

Wilds **do not pay on reel 1** in the built-in implementation.

`meta` includes total ways and multiplier contributions.

Use when: 243/1024/etc. ways-style slots with multiplicative multipliers.

## Cluster

`ClusterWins.get_cluster_data()` — BFS over the board, grouping like-symbols that share a reel or row (no diagonals). Default 5+ symbol clusters pay.

Wilds can join clusters of multiple symbol types simultaneously.

Pay groups via `convert_range_table()` (see `configs.md`).

Use when: cluster-pays grids (e.g. 7x7 cluster slots), typically paired with tumbling.

## Scatter

`ScatterWins.get_scatterpay_wins(record_wins=True)` — pay-anywhere counting of like-symbols across the entire board. Default 8+ symbols pay.

Wilds contribute to any symbol's count. Multiplier-tagged symbols apply per the active `multiplier_strategy`.

Pay groups via `convert_range_table()` for ranged payouts.

Use when: pay-anywhere mechanic; usually combined with tumbling and global multipliers.

## Tumble

`Tumble` (inherits `Board`) — removes winning symbols (`sym.check_attribute("explode")`) and refills from the reelstrip above the prior stop position. Implementation: for each reel, count the explode positions; append that many symbols counting backwards from `self.reel_positions[reel]`; if padding is enabled, the existing `top_symbols[reel]` fills the topmost vacated cell first.

Win-evaluation functions for cluster/scatter assign `explode = True` to winning symbols. Standard cascade loop:

```python
while self.win_data["totalWin"] > 0 and not self.wincap_triggered:
    self.tumble_game_board()
    self.win_data = self.get_cluster_data(record_wins=True)  # or get_scatterpay_wins
    self.win_manager.update_spinwin(self.win_data["totalWin"])
    self.emit_tumble_win_events()
```

Use when: cascading / dropping-symbols mechanic.
