# FAQ

Distilled from the Stake Engine math FAQ.

## What files are required to publish math?

Per game mode, three files are required:

1. **`index.json`** — exact filename, game-level. Declares all betmodes with `name`, `cost`, `events` (filename), `weights` (filename). See `rgs-output-contract.md`.
2. **Lookup-table CSV** — three columns: `simulation_number, round_probability, payout_multiplier`. All values `uint64` (no floats). `payout_multiplier` must exactly match the events file. No header row.
3. **Game logic `.jsonl.zst`** — Zstandard-compressed JSON Lines. Required per-line fields: `id`, `events`, `payoutMultiplier`. The `events` array is what `/play` returns.

A 2-mode game publishes 1 `index.json` + 2 CSVs + 2 `.jsonl.zst` files.

On upload, the RGS hashes `payoutMultiplier` values from both the CSV and the events file. Any mismatch rejects the upload.

## Does the 0.5% RTP variation rule apply to all modes?

**Yes** — to every declared mode regardless of mechanic. Side bets, bonus buys, features, superspins all must fall within ±0.5% RTP of the base game.

Concrete example: base game at 97.0% RTP requires every other mode in [96.5%, 97.5%].

Failure example (would be rejected):

| Mode | RTP | Delta vs base |
|---|---|---|
| Base | 97.0% | — |
| Side bet | 93.0% | -4.0% |
| Bonus buy | 95.5% | -1.5% |

Fix: adjust per-mode math (paytable, distributions, reelsets, optimizer weights) until every mode is within range before submitting.

## Common gotchas

- **Floats in the CSV** — rejected. Always emit `uint64`.
- **CSV / events mismatch** — re-export both together; never hand-edit one without regenerating the other.
- **Uncompressed books uploaded** — only `.jsonl.zst` is consumed by the RGS; uncompressed `books/` files are for local debugging.
- **Wild line-payouts dominating** — if `(short_kind, "W")` exists in `paytable`, short wild combinations can outrank longer real-symbol lines (see `calculations.md`). Restrict wild payouts to full reel-length where possible.
- **Ways wilds on reel 1** — the built-in ways calculation does not count wilds on the first reel.
- **`special_symbols_on_board` stale after mutation** — after custom symbol-removal or insertion, re-invoke `Board.get_special_symbols_on_board()` to refresh.
- **`final_win` ≠ `basegame_wins + freegame_wins`** — raises `RuntimeError`. Ensure `win_manager.update_gametype_wins(gametype)` is called after basegame actions complete and after each freegame spin.
- **Pre-assigned criteria + slow convergence** — strict `win_criteria` (e.g. max-win) with under-biased `conditions` causes long rejection loops. Bias `reel_weights` / `mult_values` to make rare outcomes reachable.
- **`auto_close_disabled` for bonus modes** — set `True` if the player must resume an interrupted bonus round; the frontend then closes the bet manually.
- **`weights` in `index.json` must point to the optimized lookup table** — typically `lookUpTable_<betmode>_0.csv`, not the pre-optimizer file.
