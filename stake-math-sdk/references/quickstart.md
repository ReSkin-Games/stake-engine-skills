# Quickstart

Run a first game simulation, inspect outputs, then scale up.

## Copy a sample as a template

The shortest path is to copy a sample game folder and edit it:

```bash
cp -r games/0_0_lines games/my_game
```

`games/0_0_lines/` is a 3-row, 5-reel, 20-line game. 3+ like-symbols on a payline award per `GameConfig.paytable`/`paylines`.

## Edit `run.py`

`run.py` holds simulation parameters. For a first debug run, use uncompressed output and a small count:

```python
num_threads = 1
compression = False

num_sim_args = {
    "base": 100,
    "bonus": 100,
}

run_conditions = {
    "run_sims": True,
    "run_optimization": False,
    "run_analysis": False,
}
```

## Execute

```bash
make run GAME=my_game
```

Or directly:

```bash
python3 games/my_game/run.py
```

## Where outputs land

All outputs sit under `games/my_game/library/`:

- `books/books_<betmode>.jsonl` — uncompressed per-simulation events (JSON Lines).
- `books_compressed/books_<betmode>.jsonl.zst` — Zstandard-compressed books for upload.
- `lookup_tables/lookUpTable_<betmode>.csv` — `id,weight,payout` per simulation.
- `lookup_tables/lookUpTableIdToCriteria_<betmode>.csv` — which Distribution criteria each simulation satisfies.
- `lookup_tables/lookUpTableSegmented_<betmode>.csv` — basegame vs freegame contribution to payout.
- `forces/force_record_<betmode>.json` — `record()` keys and matching `book` IDs.
- `configs/config.json`, `config_fe.json`, `config_math.json` — backend, frontend, optimizer configs.
- `publish_files/` — the subset required for RGS upload.

## Inspect a single simulation

A book entry in `books_base.jsonl` looks like:

```json
{
  "id": 58,
  "payoutMultiplier": 10,
  "events": [
    {"index": 0, "type": "reveal", "board": [], "paddingPositions": [], "gameType": "basegame", "anticipation": []},
    {"index": 1, "type": "winInfo", "totalWin": 10, "wins": [{"symbol": "L5", "kind": 3, "win": 10, "positions": [], "meta": {}}]},
    {"index": 2, "type": "setWin", "amount": 10, "winLevel": 2},
    {"index": 3, "type": "setTotalWin", "amount": 10},
    {"index": 4, "type": "finalWin", "amount": 10}
  ],
  "criteria": "basegame",
  "baseGameWins": 0.1,
  "freeGameWins": 0.0
}
```

The matching lookup-table row is `58,1,10`. Weights start at 1 and are tuned by the optimizer.

## Scale to a production batch

```python
num_threads = 20
compression = True

num_sim_args = {
    "base": int(1e5),
    "bonus": int(1e5),
}

run_conditions = {
    "run_sims": True,
    "run_optimization": True,
    "run_analysis": True,
    "upload_data": False,
}
```

100k+ simulations per betmode is the recommended floor for production. Optimization rewrites weights in `lookUpTable_<betmode>_0.csv`. Analysis (PAR sheet) consumes `lookUpTableSegmented_<betmode>.csv` plus `force_record_<betmode>.json`.

Per-thread RTP prints look like:

```text
Thread 0 finished with 1.632 RTP. [baseGame: 0.043, freeGame: 1.588]
```
