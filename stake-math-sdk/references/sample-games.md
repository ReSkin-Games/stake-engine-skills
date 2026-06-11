# Sample Games

Five sample games live under `math-sdk/games/`. Each has a `readme.txt` with rules. They are the recommended starting points — copy the closest match and edit.

All samples define a base betmode (cost `1.0`) and a freegame/bonus betmode unless noted.

## `0_0_lines` — Lines

3-row × 5-reel, 20 paylines.

- Wilds carry multipliers in the freegame only; line wins add wild multipliers when `> 1`.
- Scatters appear on all reels; 3+ scatters trigger the freegame.
- Freegame uses a separate reelset; scatters only on reels 2/3/4; 2 scatters retrigger.
- Wilds only pay on 5-kind to avoid edge cases (a 3-kind wild outranking a longer non-wild line).

Recommended starting point for any payline-based slot.

## `0_0_ways` — Ways

5-reel × 3-row standard ways game.

- 9 paying symbols (H1–H5, L1–L4), 1 wild, 1 scatter.
- Wild multipliers in freegame only; wilds do not appear on reel 1.
- Multiplier values compound **multiplicatively** (unlike lines, which add).
- 3+ scatters (max 1 per reel) trigger freegame.

Recommended starting point for 243/1024 ways slots.

## `0_0_cluster` — Cluster pays

Tumbling cluster game. 5+ neighboring like-symbols (no diagonals) pay.

- Basegame: standard tumbling with wild + scatter; 4+ scatters trigger freegame.
- Freegame: grid positions carry per-cell multipliers, doubling on each winning cluster up to 512x. Global multiplier increments by +1 per freespin and persists. 3+ scatters retrigger.
- Includes an explicit freespin entry-check guard so scatters that tumble into view during basegame criteria do not spuriously trigger.

Recommended starting point for grid/cluster cascading slots.

## `0_0_scatter` — Scatter pays (pay-anywhere)

6-reel × 5-row tumbling pay-anywhere game.

- 8 paying symbols (4 high, 4 low); 1 wild, 1 scatter.
- Payouts grouped by cluster size: (8–8), (9–10), (11–13), (14–36).
- Basegame: 3+ scatters trigger freegame; **2 spins per scatter** (overrides default `update_freespin_amount`).
- Freegame: every tumble increments a persistent global multiplier (+1); global mult is applied to tumble wins as removed; after all tumbles, the cumulative tumble win is multiplied by on-board multipliers; on-board multiplier symbols add to the global mult before final evaluation; no upper retrigger limit (scatters can tumble in).

Event types of note:

- `winInfo` — symbol/multiplier/position summary per tumble.
- `tumbleBanner` — cumulative tumble win with global mult applied.
- `setWin` — whole-spin (reveal-to-reveal) result.
- `setTotalWin` — round cumulative.

Recommended starting point for pay-anywhere cascading slots.

## `0_0_expwilds` — Expanding Wilds Lines + Superspin

5-reel × 5-row, 15 paylines.

- 9 paying symbols, 1 wild, 1 scatter; wilds pay on 3/4/5-kind.
- Freegame: one wild can land per reel and expands to fill active rows; expanded wild is sticky for the rest of the freegame; new random multiplier (2x–50x) per reveal; no retrigger.
- **Superspin** mode (cost `25x`, purchase-only): hold-em style. Player starts with 3 lives; landing a prize symbol resets to 3 spins. Prizes are sticky and evaluated when no spins remain. Independent of freegame; cannot be entered via scatters.

Recommended starting point for any game with multiple purchasable feature modes (incl. superspin / buy-feature mechanics).

## `fifty_fifty` — RGS demo

Trivial 2x-or-bust game. Not slot-shaped. Used by the RGS getting-started tutorial; not a useful template for production slot work.

## Picking a starting point

| Mechanic | Use |
|---|---|
| Payline slot | `0_0_lines` |
| 243/1024 ways | `0_0_ways` |
| Cluster cascade | `0_0_cluster` |
| Pay-anywhere cascade | `0_0_scatter` |
| Sticky/expanding wilds + buy feature | `0_0_expwilds` |
| Demo RGS plumbing only | `fifty_fifty` |
