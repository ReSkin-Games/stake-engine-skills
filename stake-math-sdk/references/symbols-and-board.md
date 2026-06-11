# Symbols and Board

## Contents

- Symbol class
- Special attributes and `special_functions`
- Paytable values
- Symbol methods
- Active board layout
- `special_symbols_on_board`
- Padding (top/bottom symbols)
- Reelsets

## Symbol class

A `Symbol` is constructed from a name string plus `GameConfig`. The class lives in the engine's symbol module and is instantiated by `SymbolStorage` when reelstrips are loaded.

```python
class Symbol:
    def __init__(self, config, name):
        self.name = name
        self.special_functions = []
        self.special = False
        # for each property in config.special_symbols where name matches,
        # setattr(self, property, True)
        self.assign_paying_bool(config)
```

A symbol name is valid iff it appears in `config.paytable` **or** in `config.special_symbols`. Any name outside both raises `RuntimeError` on reelstrip load.

## Special attributes

`config.special_symbols = {attribute: [name, ...]}` declares attributes per symbol. Multiple symbols can share an attribute; one symbol can have many attributes. Common attributes: `wild`, `scatter`, `multiplier`, `prize`. Default value is `True` unless overridden by a `special_function`.

### `special_functions`

`GameStateOverride.assign_special_sym_function()` registers callables run when a symbol is instantiated:

```python
def assign_special_sym_function(self):
    self.special_symbol_functions = {
        "W": [self.assign_mult_property],
    }

def assign_mult_property(self, symbol):
    multiplier_value = get_random_outcome(
        self.get_current_distribution_conditions()["mult_values"][self.gametype]
    )
    symbol.assign_attribute({"multiplier": multiplier_value})
```

Each entry has the form `{name: [callable, ...]}`; callables are stored on `symbol.special_functions`.

## Paytable values

`assign_paying_bool()` sets:

- `symbol.is_paying = True` and `symbol.paytable = {kind: payout}` if the name appears in `config.paytable`.
- `False` and `None` otherwise.

`config.paytable` format:

```python
self.paytable = {(kind, name): payout, ...}
```

For range-based payouts (scatter / cluster), build via `convert_range_table()`:

```python
self.pay_group = {((min_kind, max_kind), name): value, ...}
self.paytable = self.convert_range_table(self.pay_group)
```

Both bounds in `(min_kind, max_kind)` are inclusive.

## Symbol methods

- `symbol.assign_attribute({key: value})` — set or overwrite an attribute.
- `symbol.get_attribute(name)` — fetch a value (or `None`).
- `symbol.check_attribute(*names)` — `True` iff every named attribute exists and is truthy.

Example checks:

```python
if self.board[reel][row].check_attribute("prize", "multiplier"):
    ...

if symbol.check_attribute("prize"):
    win += symbol.get_attribute("prize")
```

Example assignment (loop over wilds, add multipliers driven by `enhance` symbols):

```python
if len(self.special_symbols_on_board["enhance"]) > 0:
    for sym in self.special_symbols_on_board["wild"]:
        mult_val = get_random_outcome(self.config.mult_values[self.gametype])
        self.board[sym["reel"]][sym["row"]].assign_attribute({"multiplier": mult_val})
```

## Active board layout

`self.board` is a 2D list of `Symbol` objects indexed as `self.board[reel][row]`. Built by `Board.create_board_reelstrips()` (see `calculations.md`).

`self.print_board(self.board)` writes a row-aligned dump to stdout:

```
L5 L3 L4 L4 L4
L3 H4 L3 H1 L4
L3 H1 S  L3 H1
```

## `special_symbols_on_board`

When the board is generated, the engine populates:

```python
self.special_symbols_on_board = {
    "scatter": [{"reel": 0, "row": 2}, ...],
    "wild":    [{"reel": 1, "row": 0}, ...],
}
```

One entry per attribute declared in `config.special_symbols`. Typical usage:

```python
if len(self.special_symbols_on_board["scatter"]) >= min_scatter:
    self.run_freespin_from_base()
```

Custom logic that adds or removes board symbols must re-invoke `Board.get_special_symbols_on_board()` to refresh this dict.

## Padding (top / bottom symbols)

`config.include_padding = True` enables padding symbols above and below the visible board. When enabled:

- Active rows index from `row=1` upward.
- `row=0` corresponds to `top_symbols[reel]`, `row=len(board)+1` to `bottom_symbols[reel]`.
- Both are stored as `self.top_symbols = [s1, s2, ...]` / `self.bottom_symbols = [...]`.
- Both are included in the `reveal` event payload (`paddingPositions`).
- During tumbling, the top symbol is preserved.

## Reelsets

Reelsets live in `config.reels = {reelset_id: <strip>}`. A betmode's `Distribution.conditions["reel_weights"][gametype]` is a weighted draw over reelset IDs:

```python
conditions={
    "reel_weights": {
        self.basegame_type: {"BR0": 2, "BR1": 1},
        self.freegame_type: {"FR0": 5, "FR1": 1},
    },
}
```

The selected ID is bound to `self.reelstrip_id` after `create_board_reelstrips()` runs. Mixing reelsets with different RTPs is the standard RTP-tuning lever before the optimizer runs.
