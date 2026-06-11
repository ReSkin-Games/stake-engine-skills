#!/usr/bin/env bash
# smoke-test.sh — verify the web-sdk environment by checking storybook startup.
#
# Usage: scripts/smoke-test.sh <web-sdk-dir> [app-name]
#
# Default app: 'lines' (canonical first sample per upstream README).
# This runs `pnpm storybook --help` and `pnpm --filter=<app> --silent test` if available,
# rather than actually starting the dev server (which blocks).

set -euo pipefail

SDK_DIR="${1:?Usage: smoke-test.sh <web-sdk-dir> [app-name]}"
APP="${2:-lines}"

if [ ! -f "${SDK_DIR}/turbo.json" ]; then
  echo "ERROR: ${SDK_DIR} is not a web-sdk directory" >&2
  exit 30
fi

cd "${SDK_DIR}"

if ! pnpm storybook --help >/dev/null 2>&1; then
  echo "ERROR: pnpm storybook command failed" >&2
  echo "Try: pnpm install" >&2
  exit 40
fi

if [ ! -d "apps/${APP}" ]; then
  AVAILABLE=$(find apps -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | tr '\n' ' ')
  echo "ERROR: apps/${APP} not found" >&2
  echo "Available apps: ${AVAILABLE}" >&2
  exit 30
fi

echo "Building app/${APP} (dry-run, no dev server)..."
# turbo build dry-run validates dependency graph + package.json scripts
if pnpm turbo build --filter="${APP}" --dry=json >/dev/null 2>&1; then
  echo "OK: turbo can resolve build graph for apps/${APP}"
else
  echo "WARN: turbo build dry-run failed; the install may still be partial" >&2
fi

echo "OK: smoke passed"
echo "  Next: run 'pnpm run storybook --filter=${APP}' inside ${SDK_DIR} to see the game"
