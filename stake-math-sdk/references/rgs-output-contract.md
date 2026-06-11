# RGS Output Contract

The byte-level contract between the Math SDK output and the Stake Engine RGS. The RGS verifies on upload; mismatches reject the publish.

## Contents

- Required file set per game
- `index.json`
- Lookup-table CSV format
- Book / events file format
- Verification

## Required file set per game

Per betmode, three files are required:

1. `index.json` — manifest declaring all betmodes (single file, game-level).
2. `<lookup_table>.csv` — weighted payout summary per betmode.
3. `<events>.jsonl.zst` — Zstandard-compressed book file per betmode.

A 2-mode game therefore publishes 1 `index.json` + 2 CSVs + 2 `.jsonl.zst` files = 5 files total. All are produced by `create_books()` / optimizer / `generate_configs()` and copied into `library/publish_files/`.

## `index.json`

Exact filename: `index.json`. Schema:

```json
{
  "modes": [
    {
      "name": "<mode_name>",
      "cost": 1.0,
      "events": "<logic_file>.jsonl.zst",
      "weights": "<lookup_table>.csv"
    }
  ]
}
```

Per-entry fields:

- `name` — betmode identifier (matches `BetMode.name`, e.g. `"base"`, `"bonus"`).
- `cost` — cost multiplier as a number.
- `events` — filename of the compressed book file.
- `weights` — filename of the lookup-table CSV.

Concrete 2-mode example:

```json
{
  "modes": [
    {"name": "base",  "cost": 1.0,   "events": "books_base.jsonl.zst",  "weights": "lookUpTable_base_0.csv"},
    {"name": "bonus", "cost": 100.0, "events": "books_bonus.jsonl.zst", "weights": "lookUpTable_bonus_0.csv"}
  ]
}
```

Note: `weights` references the **optimized** lookup table (`_0` suffix), not the pre-optimizer file.

## Lookup-table CSV format

Each row is exactly three `uint64` values:

```
simulation_number, round_probability, payout_multiplier
```

Example:

```csv
1,199895486317,0
2,25668581149,20
3,126752606,140
```

Rules:

- All values must be unsigned integers; floats are rejected. Integer-only avoids RNG drift from rounding.
- `payout_multiplier` values must **exactly match** the `payoutMultiplier` for the same `id` in the events file. The RGS extracts and hashes both for comparison.
- No header row.

`round_probability` is the weight produced by the optimizer (relative; normalized RGS-side for sampling).

## Book / events file format

Zstandard-compressed JSON Lines (`.jsonl.zst`). One simulation per line. Required fields per line:

```json
{
  "id": 1,
  "events": [{}, ...],
  "payoutMultiplier": 1150
}
```

- `id` — simulation number; must match a row in the CSV.
- `events` — array of event objects; returned verbatim in the `/play` response.
- `payoutMultiplier` — integer; the multiplier interpretation depends on the betmode `cost`. (For example `1150` with `cost: 1.0` equals 11.5x bet; with `cost: 100.0` interpretation depends on the game's internal scale.)

Additional fields (e.g. `criteria`, `baseGameWins`, `freeGameWins`) are tolerated but optional.

## Verification

On upload the RGS:

1. Parses `index.json` to discover betmodes.
2. Streams each `.jsonl.zst` and each CSV.
3. Extracts `payoutMultiplier` from each pair.
4. Hashes the multipliers from both sources and compares.

Any mismatch — different value, missing ID, extra ID — fails the upload. Always re-export both files together; never hand-edit one without regenerating the other.

## RTP validation

Separate from byte-level verification, every betmode must fall within ±0.5% RTP of the base mode. See `faq.md`.
