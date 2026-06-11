# Bootstrap workflow

Walkthrough for setting up `math-sdk` from scratch. Each step calls an atomic script in `scripts/`. Follow in order; skip steps where `detect-state.sh` reports them already complete.

## Contents

- Pre-flight checks
- Step 1: Choose location
- Step 2: Clone math-sdk
- Step 3: Install Python environment
- Step 4: Smoke test
- Step 5: Done — what to do next
- Troubleshooting

## Pre-flight checks

Run `scripts/detect-state.sh` first. It returns:

| Exit | Meaning | Next step |
|------|---------|-----------|
| 0 | READY | Skip to "Step 5: Done" |
| 10 | NEEDS_DEPS | Install missing prerequisite (the script tells you which) |
| 20 | NEEDS_CLONE | Step 2 |
| 30 | NEEDS_INSTALL | Step 3 |
| 40 | NEEDS_SMOKE | Step 4 |

Prerequisites:
- macOS or Linux (Windows: use WSL).
- `git` installed.
- `python3 --version` reports 3.12 or higher. Install via Homebrew (`brew install python@3.12`) or pyenv if older.
- `make` installed (macOS: `xcode-select --install`; Debian/Ubuntu: `sudo apt install build-essential`).
- Rust/Cargo is needed only if the bundled optimization algorithm will be used. Install from <https://rustup.rs/>.

## Step 1: Choose location

Ask the user where to put `math-sdk`. Reasonable defaults:

- Inside the current project folder: `./math-sdk` (good when this project IS the game).
- A shared parent: `$HOME/stake-engine/math-sdk` (good when multiple games will use it).

Record the chosen path. All later scripts take it as `$1`.

## Step 2: Clone math-sdk

```bash
scripts/clone-sdk.sh <chosen-path>
```

Clones `https://github.com/StakeEngine/math-sdk.git` (shallow). If the target already looks like a math-sdk clone, the script is a no-op.

## Step 3: Install Python environment

```bash
scripts/install-python-env.sh <chosen-path>
```

Runs `make setup` if the Makefile has it (upstream README's canonical setup). Otherwise creates a `venv/` and `pip install -r requirements.txt`.

If Rust/Cargo is missing, the script warns but does not fail — Rust is only required for the bundled optimizer, not for sampling.

## Step 4: Smoke test

```bash
scripts/smoke-test.sh <chosen-path>
```

Runs the first official sample game found in `games/` (preferring `0_0_*` samples). Confirms that `library/books/books_*.jsonl` is produced. Takes ~5-30 seconds depending on sample.

If smoke fails — read the script's stderr for the failing step; it points at the right fix.

## Step 5: Done — what to do next

Now `math-sdk` is functional. Common next actions:

- **Look at a sample**: open `games/0_0_lines/run.py` and the surrounding files. See `references/sample-games.md` for what each sample demonstrates.
- **Start your own game**: copy a sample folder, rename, edit `game_config.py`. See `references/quickstart.md`.
- **Understand the engine**: `references/gamestate.md` walks through `GameState` and the simulation loop.
- **Hit a target RTP**: see `references/optimizer.md`.

## Troubleshooting

**`python3` missing on macOS**
```
brew install python@3.12
```

**`python3` too old**
The system Python on older macOS is 3.9 or 3.10. Install 3.12 via Homebrew or pyenv:
```
brew install python@3.12
# or
pyenv install 3.12 && pyenv local 3.12
```

**`make: command not found`**
- macOS: `xcode-select --install`
- Debian/Ubuntu: `sudo apt install build-essential`

**`pip install` fails on some dependency**
Re-run with `pip install -r requirements.txt -v` to see the failing wheel. Most common: missing system libraries (e.g., `gcc` for compiled wheels). Install via package manager.

**`make run` produces no books**
- Check `games/<name>/library/books/`.
- The sample's `run.py` may be set to `num_sim_args["base"] = 0`. Increase to ≥100 and rerun.

**Update existing clone**
```bash
scripts/update-sdk.sh <math-sdk-dir>
```
Pulls latest from upstream. Re-runs `pip install` may be needed if `requirements.txt` changed.
