# Optimizer

The optimizer tunes per-simulation weights in `lookUpTable_<betmode>.csv` so the betmode's overall RTP and hit-rate constraints match targets. It does not regenerate simulations — it only rewrites the `weight` column.

## What the optimizer does

Inputs:

- `library/lookup_tables/lookUpTable_<betmode>.csv` — pre-optimizer weights (all `1`).
- `library/lookup_tables/lookUpTableIdToCriteria_<betmode>.csv` — criteria per simulation ID.
- `library/lookup_tables/lookUpTableSegmented_<betmode>.csv` — basegame vs freegame splits.
- `library/forces/force_record_<betmode>.json` — keys that identify special-event books (wincap, freegame-trigger, etc.).
- `library/configs/config_math.json` — target RTP, optimization parameters.

Output:

- `library/lookup_tables/lookUpTable_<betmode>_0.csv` — same shape, modified weights. This file is the one referenced in `index.json` for publishing.

The algorithm assigns weights so that:

1. Total expected payout / total weight equals the target RTP.
2. Per-criteria contribution (basegame RTP, freegame RTP, max-win hit-rate, zero-win hit-rate) hits per-bucket targets.
3. The weight distribution stays well-conditioned (no near-zero or runaway weights).

The Rust-backed solver is invoked from Python; `rust_threads` in `run.py` controls its parallelism. Enable with `run_conditions["run_optimization"] = True`.

## Parameters

Default optimization parameters live in `math-sdk/src/config/optimization_paramaters.py` and are baked into `config_math.json` by `generate_configs()`. To customize, override values in `GameConfig` before `generate_configs(gamestate)` runs.

## When more flexibility is needed

The built-in optimizer covers the standard RTP-by-criteria case. For more complex constraints (joint distributions, custom hit-rate targets across multiple force keys, non-linear constraints), Stake Engine provides an alternative repo:

- `StakeEngine/convex-optimizer` — CVXPY-based convex solver with a Streamlit UI. Consumes the same `lookUpTable_<betmode>.csv` + criteria/segmented files but allows arbitrary linear/convex constraints. Suitable for handcrafted RTP-allocation problems that the Rust optimizer cannot express directly.

It is run as a separate step after `create_books()` and replaces the `_0.csv` produced by the built-in optimizer.

## Math-SDK optimizer docs

The current Stake Engine documentation set does not include a dedicated optimizer page; the relevant fields are referenced throughout `architecture/game-structure`, `gamestate/simulation`, and `source/outputs`. For deeper detail, consult `math-sdk/src/config/optimization_paramaters.py` and `math-sdk/src/write_data/write_configs.py` directly.
