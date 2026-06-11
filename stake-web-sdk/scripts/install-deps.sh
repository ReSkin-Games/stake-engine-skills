#!/usr/bin/env bash
# install-deps.sh — install web-sdk dependencies via pnpm.
#
# Usage: scripts/install-deps.sh <web-sdk-dir>
#
# Idempotent: pnpm install is naturally idempotent.

set -euo pipefail

SDK_DIR="${1:?Usage: install-deps.sh <web-sdk-dir>}"

if [ ! -f "${SDK_DIR}/turbo.json" ]; then
  echo "ERROR: ${SDK_DIR} is not a web-sdk directory" >&2
  exit 30
fi

# Verify node + pnpm versions before installing.
NODE_MAJOR=$(node -v | sed 's/v\([0-9]*\)\..*/\1/')
if [ "${NODE_MAJOR}" -lt 22 ]; then
  echo "ERROR: node is $(node -v), need 22.x" >&2
  echo "FIX: nvm install 22.16.0 && nvm use 22.16.0" >&2
  exit 10
fi

PNPM_MAJOR=$(pnpm -v | cut -d. -f1)
if [ "${PNPM_MAJOR}" -lt 10 ]; then
  echo "ERROR: pnpm is $(pnpm -v), need 10.x" >&2
  echo "FIX: npm install -g pnpm@10.5.0" >&2
  exit 10
fi

cd "${SDK_DIR}"
echo "Running pnpm install in ${SDK_DIR}..."
pnpm install
echo "OK: dependencies installed"
echo "Next: scripts/smoke-test.sh ${SDK_DIR}"
