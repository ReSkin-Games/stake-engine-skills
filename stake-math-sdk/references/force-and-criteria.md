# Force Files and Criteria

`force_record_<betmode>.json` is the artifact of `self.record(...)`. It maps custom-defined search keys to the set of simulation IDs (`book` IDs) that satisfied them. It serves two purposes: post-hoc analysis (frequency / hit-rate per event) and optimizer input (identifying max-win and freegame books).

## `record()`

```python
def record(self, description: dict) -> None:
    self.temp_wins.append(description)
    self.temp_wins.append(self.book_id)
```

`record()` does **not** write to disk directly. It appends the (key, book_id) pair to `self.temp_wins`. Only when a simulation is accepted (`check_repeat` returns false, `imprint_wins` runs) are the temp entries committed to the force record. This guards against rejected-and-retried simulations polluting the force file.

Keys are unique; a book ID is not duplicated within a single key, but the same book ID can appear under multiple keys.

## Typical use: track freegame trigger sources

```python
def run_freespin_from_base(self, scatter_key: str = "scatter") -> None:
    self.record({
        "kind": self.count_special_symbols(scatter_key),
        "symbol": scatter_key,
        "gametype": self.gametype,
    })
    self.update_freespin_amount()
    self.run_freespin()
```

Produces entries in `library/forces/force_record_<betmode>.json`:

```json
[
  {
    "search": {"gametype": "basegame", "kind": 5, "symbol": "scatter"},
    "timesTriggered": 22134,
    "bookIds": [7, 12, ...]
  },
  {
    "search": {"gametype": "basegame", "kind": 6, "symbol": "scatter"},
    "timesTriggered": 1196,
    "bookIds": [9, 10, ...]
  }
]
```

## Aggregated `force.json`

After all betmodes finish, `force.json` is written with the union of unique search fields and keys across modes. It is intended as a manifest for prototyping UIs (e.g. dropdown of replayable scenarios).

## Force keys and the optimizer

The optimizer uses force-record entries to identify which simulations correspond to specific outcomes (e.g. wincap, freegame-trigger). It then biases the weights of those simulations to hit target hit-rates. Recording the right keys is therefore part of optimizer setup, not just analytics.

## Distribution criteria recap

Criteria are pre-assigned to simulation IDs before any simulation runs (see `distributions.md`). The criteria-to-ID mapping is dumped to `library/lookup_tables/lookUpTableIdToCriteria_<betmode>.csv`. The intersection of "pre-assigned criteria" + "accepted by `check_repeat`" + "matching `record()` entries" is what `lookUpTableSegmented` and the optimizer consume.

## Max-win injection

To force a wincap outcome:

1. Add a `Distribution` with `win_criteria=self.wincap`, `force_wincap=True`, and a high-paying `reel_weights` mix (often a dedicated `"WCAP"` reelstrip).
2. Bias `mult_values` toward large multipliers within `conditions`.
3. The spin loop generates candidates until `final_win == wincap`; the (rare-naturally) outcome becomes reachable in reasonable wall-clock time.

## Source

- `math-sdk/src/state/state.py` — `record`, `temp_wins`, `imprint_wins`.
- `math-sdk/src/write_data/force.py` — force file writer.
