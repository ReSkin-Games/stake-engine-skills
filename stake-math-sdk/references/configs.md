# Configs

`GameConfig` (per game) inherits `Config` (base). All required fields are declared in `__init__`. The engine relies on these values to drive simulation, symbol resolution, win evaluation, and output naming.

## Files in `src/config/`

- `config.py` — the `Config` base class. Holds defaults, `convert_range_table()`, `read_reels_csv()`, registration of `bet_modes`, gametype keys (default `"basegame"`/`"freegame"`).
- `constants.py` — engine-wide string constants and defaults.
- `paths.py` — resolves library subpaths (`library/books/`, `library/lookup_tables/`, etc.) relative to the game directory.
- `output_filenames.py` — `OutputFiles` class constructs filenames (`books_<betmode>.jsonl`, `lookUpTable_<betmode>.csv`, `force_record_<betmode>.json`, `config_*.json`). Creates missing folders.
- `optimization_paramaters.py` — default optimizer parameters baked into `config_math.json`.

## Required `GameConfig` fields

```python
class GameConfig(Config):
    def __init__(self):
        super().__init__()
        self.game_id = ""
        self.provider_number = 0
        self.working_name = ""
        self.wincap = 0                # max payout multiplier
        self.win_type = "lines"        # "lines" | "ways" | "cluster" | "scatter"
        self.rtp = 0                   # target RTP

        self.num_reels = 0
        self.num_rows = [0] * self.num_reels

        self.paytable = {(kind, symbol): payout}
        self.include_padding = True
        self.special_symbols = {"property": ["sym_name"]}

        self.freespin_triggers = {
            self.basegame_type: {3: 10, 4: 15, 5: 20},
            self.freegame_type: {2: 4, 3: 6, 4: 8, 5: 10},
        }
        self.reels = {}                # {"BR0": [strip_data], ...}
        self.bet_modes = []            # list of BetMode instances
```

## Field semantics

- `wincap` — hard cap on `payoutMultiplier`. Enforced by `evaluate_wincap()`.
- `win_type` — selects the win-evaluation class used by built-in helpers.
- `rtp` — target RTP for the base betmode; consumed by the optimizer.
- `paytable` — `(kind, symbol_name) -> payout`. For scatter/cluster ranges, build via `convert_range_table(pay_group)` where `pay_group = {((min_kind, max_kind), name): payout}`.
- `special_symbols` — `{attribute: [symbol_name, ...]}`. Each name listed becomes a `Symbol` with `symbol.<attribute> = True`. Symbols are valid iff they appear in `paytable` or `special_symbols`; otherwise loading reelstrips raises `RuntimeError`.
- `freespin_triggers` — `{gametype: {num_scatters: num_spins}}`. Indexed by current `gametype` for entry / retrigger.
- `reels` — `{reelset_id: <reelstrip>}`. Loaded from CSV:

  ```python
  reels = {"BR0": "BR0.csv", "FR0": "FR0.csv"}
  self.reels = {}
  for r, f in reels.items():
      self.reels[r] = self.read_reels_csv(str.join("/", [self.reels_path, f]))
  ```

- `include_padding` — if `True`, `top_symbols` and `bottom_symbols` are populated and emitted in `reveal` events; active board rows start at index 1.
- `bet_modes` — array of `BetMode` instances (see `betmodes.md`).

## Generated config files

After `generate_configs(gamestate)`:

- `library/configs/config.json` — backend; bet-mode info + file hashes.
- `library/configs/config_fe.json` — frontend; symbol/padding/betmode info needed for display.
- `library/configs/config_math.json` — optimizer input; bet modes, RTP splits, optimization parameters.
