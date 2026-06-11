#!/usr/bin/env bash
# smoke-test.sh — run the canonical sample game to verify the environment.
#
# Usage: scripts/smoke-test.sh <math-sdk-dir> [game-name]
#
# Default game: detected from games/ (first 0_0_* sample, falling back to first directory).

set -euo pipefail

SDK_DIR="${1:?Usage: smoke-test.sh <math-sdk-dir> [game-name]}"
GAME="${2:-}"

if [ ! -d "${SDK_DIR}/games" ]; then
  echo "ERROR: ${SDK_DIR}/games does not exist" >&2
  exit 30
fi

cd "${SDK_DIR}"

if [ -z "${GAME}" ]; then
  # Prefer official samples named like 0_0_lines, 0_0_cluster, etc.
  GAME=$(find games -mindepth 1 -maxdepth 1 -type d -name '0_0_*' | head -1 | xargs -I{} basename {})
  if [ -z "${GAME}" ]; then
    GAME=$(find games -mindepth 1 -maxdepth 1 -type d | head -1 | xargs -I{} basename {})
  fi
fi

if [ -z "${GAME}" ] || [ ! -d "games/${GAME}" ]; then
  echo "ERROR: no game found in ${SDK_DIR}/games" >&2
  exit 30
fi

echo "Smoke-testing with games/${GAME}..."

# Activate venv if present.
if [ -d venv ]; then
  # shellcheck source=/dev/null
  . venv/bin/activate
elif [ -d .venv ]; then
  # shellcheck source=/dev/null
  . .venv/bin/activate
fi

# Run via make if available, otherwise call run.py directly.
if grep -qE '^run:' Makefile 2>/dev/null; then
  make run GAME="${GAME}"
elif [ -f "games/${GAME}/run.py" ]; then
  python3 "games/${GAME}/run.py"
else
  echo "ERROR: cannot determine how to run ${GAME}" >&2
  exit 30
fi

# Verify output.
BOOKS=$(find "games/${GAME}/library/books" -name 'books_*.jsonl' 2>/dev/null | head -1)
if [ -z "${BOOKS}" ]; then
  echo "ERROR: no books output produced — smoke failed" >&2
  exit 40
fi

LOOKUP=$(find "games/${GAME}/library/lookup_tables" -name 'lookUpTable_*.csv' 2>/dev/null | head -1)

echo "OK: smoke passed"
echo "  books:   ${BOOKS}"
[ -n "${LOOKUP}" ] && echo "  lookup:  ${LOOKUP}"
