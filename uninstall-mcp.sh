#!/usr/bin/env bash
# uninstall-mcp.sh — remove Stake Engine docs MCP server.
#
# Usage: ./uninstall-mcp.sh [target-dir]

set -euo pipefail

TARGET="${1:-${HOME}/.local/share/stake-engine-docs}"

if command -v claude >/dev/null 2>&1; then
  if claude mcp get stake-engine-docs >/dev/null 2>&1; then
    claude mcp remove stake-engine-docs && echo "OK: unregistered from Claude Code"
  fi
fi

if [ -d "${TARGET}" ]; then
  read -p "Remove ${TARGET}? [y/N] " confirm
  if [ "${confirm}" = "y" ] || [ "${confirm}" = "Y" ]; then
    rm -rf "${TARGET}"
    echo "OK: removed ${TARGET}"
  fi
fi
