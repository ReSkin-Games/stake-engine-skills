#!/usr/bin/env bash
# install-python-env.sh — set up Python venv and install math-sdk dependencies.
#
# Usage: scripts/install-python-env.sh <math-sdk-dir>
#
# Idempotent: skips work that's already done.

set -euo pipefail

SDK_DIR="${1:?Usage: install-python-env.sh <math-sdk-dir>}"

if [ ! -f "${SDK_DIR}/Makefile" ]; then
  echo "ERROR: ${SDK_DIR} is not a math-sdk directory" >&2
  exit 30
fi

cd "${SDK_DIR}"

if ! python3 -c 'import sys; sys.exit(0 if sys.version_info >= (3,12) else 1)'; then
  echo "ERROR: Python 3.12+ required" >&2
  echo "FIX: install Python 3.12 (macOS: brew install python@3.12)" >&2
  exit 10
fi

# Math SDK uses `make setup` per upstream README.
# If that target doesn't exist, fall back to manual venv+pip.
if grep -qE '^setup:' Makefile 2>/dev/null; then
  echo "Running 'make setup'..."
  make setup
else
  echo "No 'make setup' target — falling back to manual venv + pip install."
  if [ ! -d venv ] && [ ! -d .venv ]; then
    python3 -m venv venv
  fi
  VENV_DIR=$([ -d venv ] && echo venv || echo .venv)
  # shellcheck source=/dev/null
  . "${VENV_DIR}/bin/activate"
  if [ -f requirements.txt ]; then
    pip install --upgrade pip
    pip install -r requirements.txt
  elif [ -f setup.py ]; then
    pip install --upgrade pip
    pip install -e .
  else
    echo "WARN: no requirements.txt or setup.py — nothing to install" >&2
  fi
fi

# Rust/Cargo is needed for the bundled optimization algorithm.
if ! command -v cargo >/dev/null 2>&1; then
  echo "NOTE: Rust/Cargo not detected. Required only if the bundled optimizer is used." >&2
  echo "      Install: https://rustup.rs/" >&2
fi

echo "OK: Python environment ready at ${SDK_DIR}"
echo "Next: scripts/smoke-test.sh ${SDK_DIR}"
