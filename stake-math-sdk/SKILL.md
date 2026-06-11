---
name: stake-math-sdk
description: Bootstraps and assists with Stake Engine Math SDK (Python) for slot game development. Handles cloning upstream StakeEngine/math-sdk, setting up a Python venv, installing dependencies, and verifying with a sample-game smoke run. Once set up, helps with GameState and calculations (lines, ways, cluster, scatter, tumble, board), bet modes and distributions, symbols and paytables, generating books and lookup-tables for RGS, running the optimizer to hit a target RTP, and satisfying Stake's math approval (RTP 90-98%, ±0.5% between modes, max-win frequency). Use when working on slot math, simulating outcomes, optimizing RTP, generating publication files, debugging payout distributions, or answering any question about the Math SDK.
allowed-tools: Bash, Read, Edit, Write, Glob, Grep, WebFetch
---

# Stake Engine Math SDK

This skill helps build slot game math models for [Stake Engine](https://engine.stake.com/) using the official Python Math SDK at <https://github.com/StakeEngine/math-sdk>. On first activation it bootstraps the environment; afterwards it answers questions and guides workflows.

## How to use this skill

1. **Always start with `scripts/detect-state.sh`** to see whether the SDK and environment are ready. The exit code routes the next step (see `references/bootstrap.md` for the full table).
2. **If not ready**: follow `references/bootstrap.md`. It calls atomic scripts in `scripts/` one at a time and tells you what to do if each step fails.
3. **If ready**: pick the right `references/*.md` for the user's question. The navigation map below maps topics → files.
4. **For canonical code**: read the actual upstream source in the user's `math-sdk/` clone, never guess. File-path hints in references are `math-sdk/<relative>` — append to the clone root.

Source of truth (in order of priority):
1. The user's clone of `StakeEngine/math-sdk` (the actual code).
2. Upstream README at <https://github.com/StakeEngine/math-sdk>.
3. Official docs at <https://stakeengine.github.io/math-sdk/>.
4. These references (distilled from the above).

## Glossary (use these terms consistently)

| Term | Meaning |
|---|---|
| **GameState** | The Python class in `math-sdk/src/state/state.py` that holds simulation parameters and runs a spin. |
| **betmode** | A configured way to bet (cost, RTP target, criteria). Defined per game. |
| **book** | One simulated game outcome: an `events` list + a `payoutMultiplier`. Lives in `library/books/books_<betmode>.jsonl`. |
| **lookup-table** | The CSV that maps simulation IDs to probability weights and payouts. Lives in `library/lookup_tables/lookUpTable_<betmode>.csv`. |
| **RGS** | Remote Game Server. Reads the lookup-table at `/play/` time, returns the matching book to the frontend. |
| **event** | A typed entry inside a book (`reveal`, `winInfo`, `updateGlobalMult`, etc.). The frontend renders these in order. |
| **force key** | A criteria/forcing rule used to filter simulation outcomes (e.g., "must contain max-win"). |
| **paytable** | Symbol-to-payout mapping. Part of `GameConfig`. |

## Quickstart (after bootstrap)

```bash
# 1. Copy a sample as a starting point.
cp -r math-sdk/games/0_0_lines math-sdk/games/my_game

# 2. Open math-sdk/games/my_game/run.py and adjust simulation counts:
#    num_sim_args = {"base": 100}  # for a quick check
#    run_conditions = {"run_sims": True, "run_optimization": False, "run_analysis": False}

# 3. Run.
cd math-sdk && make run GAME=my_game

# 4. Inspect outputs.
ls math-sdk/games/my_game/library/books/
ls math-sdk/games/my_game/library/lookup_tables/
```

For details and what to change for a real game, see `references/quickstart.md`.

## Navigation: pick a reference by topic

| User's question / task | Read first | Also useful |
|---|---|---|
| Set up environment, clone, smoke | `bootstrap.md` | `setup.md` |
| Repo layout, where files live | `repo-map.md` | |
| Write/modify the simulation loop | `gamestate.md` | `executables.md` |
| Configure a game (paytable, reels, betmodes) | `configs.md` | `betmodes.md`, `distributions.md` |
| Define symbols and board | `symbols-and-board.md` | |
| Compute wins and emit events | `wins-and-events.md` | `calculations.md` |
| Pick the right win calculator | `calculations.md` (board / lines / ways / scatter / cluster / tumble) | |
| Force outcomes / criteria filters | `force-and-criteria.md` | |
| Understand the publishable outputs | `outputs.md` | `rgs-output-contract.md` |
| Hit a target RTP / run the optimizer | `optimizer.md` | `distributions.md` |
| Pass Stake math approval | `approval-math.md` | `approval-rgs.md` |
| RGS HTTP contract | `rgs-api.md` | `how-rgs-works.md` |
| Currency / language / dimension reference data | `reference-locales.md` | |
| Stake's MCP server, AI agents | `ai-integration.md` | |
| What changed recently | `recent-changes.md` | |
| Math-specific FAQ (RTP variation, required files) | `faq.md` | |
| First-time / getting-started questions | `getting-started-faq.md` | |
| Publishing questions (ranking, exclusivity, removal) | `publishing-faq.md` | |
| Pick a sample to start from | `sample-games.md` | `quickstart.md` |

## Critical contracts (inline — do not break)

These are enforced by Stake on approval. Verify before publishing.

- **RTP per betmode**: 90.0%–98.0%. Across betmodes: maximum spread 0.5% (e.g., base 97% requires all others between 96.5–97.5%). See `approval-math.md`.
- **Max-win frequency**: typically ≥1 in 10,000,000 — must be actually obtainable.
- **Non-zero hit-rate**: ≥1 in 20 for "BASE" modes.
- **Simulation count**: 100k–1M for slot-type games.
- **Stateless**: each bet independent. No jackpots, gamble, cashout. See `approval-rgs.md`.
- **Output files** required for publication: `library/books/books_<mode>.jsonl`, `library/lookup_tables/lookUpTable_<mode>.csv`, `library/lookup_tables/lookUpTableIdToCriteria_<mode>.csv`, `library/configs/index.json`, `library/configs/config_<mode>.json`. See `outputs.md` + `rgs-output-contract.md`.

## Stack flexibility — what's contract vs convention

**Contract** (Stake enforces this; can't deviate):
- The output file format (books JSONL + lookup-table CSV + index.json + config_*.json).
- RTP/hit-rate/max-win statistical requirements.
- Stateless game semantics.

**Convention** (Python Math SDK is the official path, but the *output* is what's verified):
- Python 3.12+, `GameState`/MRO architecture, the bundled optimizer.
- A custom (non-Python) simulator that produces correct output files is theoretically acceptable, but: Stake's approval team and support reference the Python SDK in tickets — debugging a custom pipeline is on the user.
- Existing reason to keep a custom pipeline: hand-crafted special outcomes (e.g., bespoke max-win sequences) where the Python optimizer's constraints don't fit. See `optimizer.md` for the official optimizer's scope.

## Anti-patterns to avoid

- **Don't trust hardcoded RTP labels in UI as the source of truth** — the truth is the weighted lookup-table. Compute the displayed RTP from `lookUpTable_<mode>.csv`, not from `rtp` in config.
- **Don't refactor the books generator without a golden-master baseline** — special-card behavior is easy to break invisibly. Snapshot books before changes, diff byte-by-byte after.
- **Don't inject max-win only into books and forget lookup-table** — the optimizer reads payouts from the raw lookup-table, not from books. Both must stay in sync.
- **When deleting a betmode or regenerating books** — audit UI hardcodes (mode labels, RTP, limits, max-win) separately; the math golden-master does not catch these.

## What this skill does NOT do

- Build or modify the frontend. For Stake-Engine slot frontends, the sibling skill `stake-web-sdk` handles that. Activate it when the user asks about Svelte, PixiJS, Storybook, book events, or anything UI-side.
- Replace upstream code with copies. Always cite paths in the user's clone; do not paste large blocks of upstream source.
- Make publishing decisions for the user. The skill explains requirements; the user decides what to submit.
