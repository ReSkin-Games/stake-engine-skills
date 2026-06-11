#!/usr/bin/env bash
# install.sh — copy both Stake Engine skills into ~/.claude/skills/.
#
# Usage: ./install.sh
#
# Idempotent: re-running will overwrite existing copies (warns first if found).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${HOME}/.claude/skills"

mkdir -p "${TARGET}"

for skill in stake-math-sdk stake-web-sdk; do
  src="${SCRIPT_DIR}/${skill}"
  dst="${TARGET}/${skill}"

  if [ ! -d "${src}" ]; then
    echo "ERROR: ${src} not found in this bundle" >&2
    exit 1
  fi

  if [ -e "${dst}" ] || [ -L "${dst}" ]; then
    echo "WARN: ${dst} already exists — replacing"
    rm -rf "${dst}"
  fi

  cp -R "${src}" "${dst}"
  chmod +x "${dst}/scripts/"*.sh 2>/dev/null || true
  echo "OK: installed ${skill}"
done

echo
echo "Both Stake Engine skills installed at ${TARGET}/."
echo

# Offer to install the Stake docs MCP server for live doc access.
if [ "${SKIP_MCP:-0}" != "1" ] && [ -f "${SCRIPT_DIR}/install-mcp.sh" ]; then
  echo "Stake also publishes an MCP server that gives Claude live access to the"
  echo "current docs (search and fetch by page). The skills work fine without it"
  echo "but the MCP server keeps content fresh between skill releases."
  echo
  read -p "Install the Stake docs MCP server too? [Y/n] " yn
  case "${yn}" in
    [Nn]*)
      echo "Skipping MCP server. You can install later with: ./install-mcp.sh"
      ;;
    *)
      bash "${SCRIPT_DIR}/install-mcp.sh" || echo "WARN: MCP install failed; skills still work."
      ;;
  esac
  echo
fi

echo "Restart Claude Code (or open a new session) to load the skills."
echo
echo "Triggers:"
echo "  stake-math-sdk → mentions of math-sdk, slot math, books, RTP, optimizer, bet mode"
echo "  stake-web-sdk  → mentions of web-sdk, Storybook, Pixi, book events, Svelte slot frontend"
