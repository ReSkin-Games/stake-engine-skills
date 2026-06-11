#!/usr/bin/env bash
# detect-state.sh — report environment readiness for Stake Engine Web SDK work.
#
# Exit codes:
#   0  READY        — web-sdk cloned, deps installed, ready for storybook
#   10 NEEDS_DEPS   — prerequisites missing (git, node 22, pnpm 10)
#   20 NEEDS_CLONE  — prerequisites ok, web-sdk not present
#   30 NEEDS_INSTALL — web-sdk cloned, pnpm install not run
#   40 NEEDS_SMOKE  — installed, storybook not verified

set -u

SDK_DIR="${1:-}"
if [ -z "${SDK_DIR}" ]; then
  for candidate in "./web-sdk" "../web-sdk" "$HOME/stake-engine/web-sdk" "$HOME/StakeEngine/web-sdk"; do
    if [ -d "${candidate}" ] && [ -f "${candidate}/turbo.json" ]; then
      SDK_DIR="${candidate}"
      break
    fi
  done
fi

# 1. Prerequisites.
if ! command -v git >/dev/null 2>&1; then
  echo "NEEDS_DEPS: git not installed" >&2
  echo "FIX: install git (macOS: brew install git)" >&2
  exit 10
fi

# Node 22.x is what upstream README pins (was 18.18 in old docs).
if ! command -v node >/dev/null 2>&1; then
  echo "NEEDS_DEPS: node not installed" >&2
  echo "FIX: install Node 22.16.0 via nvm (https://github.com/nvm-sh/nvm)" >&2
  echo "  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash" >&2
  echo "  nvm install 22.16.0 && nvm use 22.16.0" >&2
  exit 10
fi
NODE_MAJOR=$(node -v | sed 's/v\([0-9]*\)\..*/\1/')
if [ "${NODE_MAJOR}" -lt 22 ]; then
  echo "NEEDS_DEPS: node is $(node -v) but Stake web-sdk requires 22.x" >&2
  echo "FIX: nvm install 22.16.0 && nvm use 22.16.0" >&2
  exit 10
fi

if ! command -v pnpm >/dev/null 2>&1; then
  echo "NEEDS_DEPS: pnpm not installed" >&2
  echo "FIX: npm install -g pnpm@10.5.0" >&2
  exit 10
fi
PNPM_MAJOR=$(pnpm -v | cut -d. -f1)
if [ "${PNPM_MAJOR}" -lt 10 ]; then
  echo "NEEDS_DEPS: pnpm is $(pnpm -v) but Stake web-sdk requires 10.x" >&2
  echo "FIX: npm install -g pnpm@10.5.0" >&2
  exit 10
fi

# 2. SDK present?
if [ -z "${SDK_DIR}" ] || [ ! -d "${SDK_DIR}" ] || [ ! -f "${SDK_DIR}/turbo.json" ]; then
  echo "NEEDS_CLONE: web-sdk not found" >&2
  echo "FIX: scripts/clone-sdk.sh <target-dir>" >&2
  exit 20
fi

# 3. Deps?
if [ ! -d "${SDK_DIR}/node_modules" ]; then
  echo "NEEDS_INSTALL: node_modules missing in ${SDK_DIR}" >&2
  echo "FIX: scripts/install-deps.sh ${SDK_DIR}" >&2
  exit 30
fi

# 4. Storybook can run?
if ! (cd "${SDK_DIR}" && pnpm storybook --help >/dev/null 2>&1); then
  echo "NEEDS_SMOKE: storybook not verified" >&2
  echo "FIX: scripts/smoke-test.sh ${SDK_DIR}" >&2
  exit 40
fi

echo "READY: web-sdk at ${SDK_DIR}"
echo "  node: $(node -v)"
echo "  pnpm: $(pnpm -v)"
exit 0
