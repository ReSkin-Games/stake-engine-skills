# StakeEngine/math-sdk — Repo Map

Authoritative map of the upstream `StakeEngine/math-sdk` repository.
Source: `gh api repos/StakeEngine/math-sdk` (latest commit `403c9fa`, 2026-06-02).

## Table of Contents

- [Top-Level Layout](#top-level-layout)
- [src/ — Engine Source](#src--engine-source)
- [games/ — Official Sample Games](#games--official-sample-games)
- [Recommended Starting Point](#recommended-starting-point)
- [Other Top-Level Folders](#other-top-level-folders)

## Top-Level Layout

| Path | Purpose |
|------|---------|
| `src/` | Core engine: state, events, calculations, wins, write_data, executables. |
| `games/` | Sample games (one folder per game) — copy and adapt for new titles. |
| `utils/` | Stand-alone helper scripts (analysis, debugging, conversion). |
| `optimization_program/` | Custom optimizer used to fit reels to RTP / hit-frequency targets. |
| `tests/` | Pytest suite covering core engine and shared utilities. |
| `docs/` | Markdown sources for the math-sdk docs site. |
| `uploads/` | Output artifacts (books, lookup-tables, force files) for RGS upload. |
| `Makefile` | Common entry points: `make install`, `make run`, `make test`. |
| `requirements.txt` | Python dependencies. |
| `setup.py` | Package install metadata. |
| `mkdocs.yml` | MkDocs config for `docs/`. |
| `README.md`, `LICENSE` | Project metadata. |

## src/ — Engine Source

One-line purpose per subfolder. Cite as `math-sdk/src/<sub>/<file>.py`.

### `src/state/`
Round simulation state and book generation.
- `state.py` — base `GameState` carrying reels, board, wins, multipliers across a spin.
- `books.py` — `Book` / `BookEvent` serialization for the RGS book format.
- `run_sims.py` — top-level simulation driver invoked by executables.
- `state_conditions.py` — predicates over the current state (e.g. is bonus, is end-of-round).

### `src/events/`
Player-visible event stream emitted into the book.
- `events.py` — `emit_*` helpers (reveal, win, transition, board update).
- `event_constants.py` — string constants for event types consumed by the frontend.

### `src/calculations/`
Win-mechanic calculators — one module per board type.
- `board.py` — board construction / symbol placement utilities.
- `lines.py` — payline evaluation.
- `ways.py` — ways-style (left-to-right adjacency) evaluation.
- `cluster.py` — cluster-pays evaluation (flood-fill).
- `scatter.py` — scatter trigger and scatter-pays evaluation.
- `tumble.py` — cascading / tumble mechanic (remove winning symbols and refill).
- `symbol.py` — `Symbol` class and metadata helpers.
- `statistics.py` — aggregated statistics over simulated rounds.

### `src/wins/`
Win-amount finalization and multiplier policy.
- `win_manager.py` — accumulates wins per event, enforces caps.
- `multiplier_strategy.py` — strategies for combining and applying multipliers.

### `src/config/`
Per-game configuration surface.
- `config.py` — base `GameConfig` class (extended by each game's `gamestate.py`).
- `betmode.py` — `BetMode` definitions (base, bonus-buy, free-spin variants).
- `distributions.py` — symbol / reel distributions used during simulation.
- `optimization_paramaters.py` — knobs for the optimizer (target RTP, hit-rate windows).
- `constants.py` — shared engine constants.
- `paths.py` — canonical paths for game artifacts.
- `output_filenames.py` — naming convention for generated books / lookup-tables.

### `src/write_data/`
Output writers for RGS-bound artifacts.
- `write_data.py` — orchestrates writing books and lookup-tables.
- `write_configs.py` — emits per-betmode JSON consumed by the RGS.
- `force.py` — writes `force` files used to deterministically replay a round.

### `src/executables/`
- `executables.py` — `run_game(...)` entry consumed by each game's `run.py`.

## games/ — Official Sample Games

Verified via `gh api repos/StakeEngine/math-sdk/contents/games` (commit `403c9fa`).

| Game | Mechanic |
|------|----------|
| `0_0_lines` | Classic payline slot — recommended starting point. |
| `0_0_lines_feature_match` | Lines slot with a feature-match (extra) mechanic. |
| `0_0_ways` | Ways-pays (e.g. 243-ways) slot. |
| `0_0_cluster` | Cluster-pays slot (flood-fill wins). |
| `0_0_scatter` | Scatter-pays slot. |
| `0_0_expwilds` | Expanding wilds slot. |
| `fifty_fifty` | Minimal binary game — smallest-possible reference. |
| `template` | Skeleton scaffold to copy when starting a new game. |

(The local clone at `math_sdk/games/repoker/` is a user game, not an upstream sample.)

## Recommended Starting Point

For a first game, start from **`games/0_0_lines`**. It exercises the full pipeline (state, events, lines calculator, win manager, write_data) with the simplest payout model.

For an even more minimal reference, see `games/fifty_fifty`.

For an empty scaffold, copy `games/template`.

## Other Top-Level Folders

- **`optimization_program/`** — Native optimizer the engine shells out to when fitting reels.
- **`utils/`** — Misc analysis scripts (RTP scans, book inspectors).
- **`uploads/`** — Generated `books_*.jsonl.zst` and `lookUpTable_*.csv` artifacts staged for RGS upload.
- **`tests/`** — Pytest suite; run via `make test`.
