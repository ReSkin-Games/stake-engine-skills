#!/usr/bin/env bash
# detect-state.sh — report environment readiness for Stake Engine Math SDK work.
#
# Exit codes:
#   0  READY        — math-sdk cloned, venv active, smoke output exists
#   10 NEEDS_DEPS   — prerequisites missing (python, git, etc.)
#   20 NEEDS_CLONE  — prerequisites ok, math-sdk not present
#   30 NEEDS_INSTALL — math-sdk cloned, venv/deps missing
#   40 NEEDS_SMOKE  — installed, sample never run

set -u

SDK_DIR="${1:-}"
if [ -z "${SDK_DIR}" ]; then
  # Try common locations relative to current directory.
  for candidate in "./math-sdk" "../math-sdk" "$HOME/stake-engine/math-sdk" "$HOME/StakeEngine/math-sdk"; do
    if [ -d "${candidate}" ] && [ -f "${candidate}/Makefile" ]; then
      SDK_DIR="${candidate}"
      break
    fi
  done
fi

# 1. Prerequisites.
if ! command -v git >/dev/null 2>&1; then
  echo "NEEDS_DEPS: git not installed" >&2
  echo "FIX: install git (macOS: brew install git; Debian/Ubuntu: sudo apt install git)" >&2
  exit 10
fi
if ! command -v python3 >/dev/null 2>&1; then
  echo "NEEDS_DEPS: python3 not installed" >&2
  echo "FIX: install Python 3.12+ (macOS: brew install python@3.12)" >&2
  exit 10
fi
PYVER=$(python3 -c 'import sys; print(f"{sys.version_info[0]}.{sys.version_info[1]}")')
if ! python3 -c 'import sys; sys.exit(0 if sys.version_info >= (3,12) else 1)'; then
  echo "NEEDS_DEPS: python3 is ${PYVER} but Stake math-sdk requires 3.12+" >&2
  echo "FIX: install Python 3.12 (macOS: brew install python@3.12)" >&2
  exit 10
fi
if ! command -v make >/dev/null 2>&1; then
  echo "NEEDS_DEPS: make not installed" >&2
  echo "FIX: macOS: xcode-select --install; Debian/Ubuntu: sudo apt install build-essential" >&2
  exit 10
fi

# 2. SDK present?
if [ -z "${SDK_DIR}" ] || [ ! -d "${SDK_DIR}" ] || [ ! -f "${SDK_DIR}/Makefile" ]; then
  echo "NEEDS_CLONE: math-sdk not found" >&2
  echo "FIX: scripts/clone-sdk.sh <target-dir>" >&2
  exit 20
fi

# 3. venv + deps?
if [ ! -d "${SDK_DIR}/venv" ] && [ ! -d "${SDK_DIR}/.venv" ]; then
  echo "NEEDS_INSTALL: no venv in ${SDK_DIR}" >&2
  echo "FIX: scripts/install-python-env.sh ${SDK_DIR}" >&2
  exit 30
fi

# 4. Sample run?
if ! find "${SDK_DIR}/games" -maxdepth 3 -name 'books_*.jsonl' 2>/dev/null | grep -q .; then
  echo "NEEDS_SMOKE: no books output found — sample never run" >&2
  echo "FIX: scripts/smoke-test.sh ${SDK_DIR}" >&2
  exit 40
fi

# 5. All good.
echo "READY: math-sdk at ${SDK_DIR}"
echo "  python: ${PYVER}"
echo "  smoke output: $(find "${SDK_DIR}/games" -maxdepth 3 -name 'books_*.jsonl' | head -1)"
exit 0
