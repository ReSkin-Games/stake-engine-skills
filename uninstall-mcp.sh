#!/usr/bin/env bash
# uninstall-mcp.sh — remove Stake Engine docs MCP server.
#
# Usage: ./uninstall-mcp.sh [target-dir]

set -euo pipefail

TARGET="${1:-${HOME}/.local/share/stake-engine-docs}"

if command -v claude >/dev/null 2>&1; then
  # Try user scope first (the default for install-mcp.sh), then local as fallback.
  if claude mcp get stake-engine-docs 2>&1 | grep -q "^stake-engine-docs:"; then
    claude mcp remove stake-engine-docs -s user 2>/dev/null && echo "OK: unregistered (user scope)" ||
    claude mcp remove stake-engine-docs -s local 2>/dev/null && echo "OK: unregistered (local scope)" ||
    echo "WARN: could not unregister automatically; run 'claude mcp remove stake-engine-docs' manually"
  fi
fi

if [ -d "${TARGET}" ]; then
  read -p "Remove ${TARGET}? [y/N] " confirm
  if [ "${confirm}" = "y" ] || [ "${confirm}" = "Y" ]; then
    rm -rf "${TARGET}"
    echo "OK: removed ${TARGET}"
  fi
fi
