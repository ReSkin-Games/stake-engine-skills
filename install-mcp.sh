#!/usr/bin/env bash
# install-mcp.sh — install Stake Engine docs MCP server for live doc access.
#
# Source: StakeEngine/docs repo (the mcp-server/ subfolder).
# Default install location: ~/.local/share/stake-engine-docs/
#
# After install, the server is registered with Claude Code via `claude mcp add`.
# For other tools (Cursor, Windsurf, Codex), see the printed JSON snippet at the end.
#
# Usage: ./install-mcp.sh [target-dir]

set -euo pipefail

TARGET="${1:-${HOME}/.local/share/stake-engine-docs}"
UPSTREAM="https://github.com/StakeEngine/docs.git"

echo "==> Installing Stake Engine docs MCP server"
echo "    target: ${TARGET}"

# Prerequisites.
if ! command -v git >/dev/null 2>&1; then
  echo "ERROR: git not installed" >&2
  exit 10
fi
if ! command -v node >/dev/null 2>&1; then
  echo "ERROR: node not installed (need 20+)" >&2
  echo "FIX: install Node via nvm (https://github.com/nvm-sh/nvm)" >&2
  exit 10
fi
NODE_MAJOR=$(node -v | sed 's/v\([0-9]*\)\..*/\1/')
if [ "${NODE_MAJOR}" -lt 20 ]; then
  echo "ERROR: node is $(node -v), need 20+ for MCP SDK" >&2
  exit 10
fi
if ! command -v pnpm >/dev/null 2>&1; then
  echo "ERROR: pnpm not installed" >&2
  echo "FIX: npm install -g pnpm@10.5.0" >&2
  exit 10
fi

# Clone or update the docs repo.
if [ -d "${TARGET}/.git" ]; then
  echo "==> Updating existing clone..."
  cd "${TARGET}"
  git pull --ff-only origin main 2>/dev/null || git pull --ff-only origin master
else
  echo "==> Cloning ${UPSTREAM}..."
  mkdir -p "$(dirname "${TARGET}")"
  git clone --depth=1 "${UPSTREAM}" "${TARGET}"
  cd "${TARGET}"
fi

# Build MCP server.
cd "${TARGET}/mcp-server"
echo "==> Installing MCP server dependencies..."
pnpm install --silent

echo "==> Building MCP server..."
pnpm build

ENTRY="${TARGET}/mcp-server/dist/index.js"
if [ ! -f "${ENTRY}" ]; then
  echo "ERROR: build did not produce ${ENTRY}" >&2
  exit 20
fi

# Smoke test: spawn briefly to confirm it starts.
if ! timeout 3 node "${ENTRY}" </dev/null >/dev/null 2>&1; then
  # stdio MCP servers expect input; exit on EOF is normal. The above just confirms it boots.
  : # ignore — timeout/EOF is expected
fi

echo "==> Server built at: ${ENTRY}"
echo ""

# Register with Claude Code (user scope) if the CLI is available.
if command -v claude >/dev/null 2>&1; then
  echo "==> Registering with Claude Code (user scope)..."
  # `claude mcp get` prints details on stdout and returns 0 if registered, 1 otherwise.
  # Grep on the specific server name to avoid false positives.
  if claude mcp get stake-engine-docs 2>&1 | grep -q "^stake-engine-docs:"; then
    echo "    already registered — skipping (use 'claude mcp remove stake-engine-docs' to reset)"
  else
    if claude mcp add -s user stake-engine-docs -- node "${ENTRY}"; then
      echo "    OK: registered at user scope (available in all projects)"
      echo "    Restart Claude Code to load the new MCP server."
    else
      echo "    WARN: registration failed; add manually with:" >&2
      echo "      claude mcp add -s user stake-engine-docs -- node ${ENTRY}" >&2
    fi
  fi
else
  echo "==> Claude Code CLI not found — skipping auto-registration."
  echo "    To use this MCP server in Claude Code, run:"
  echo "      claude mcp add -s user stake-engine-docs -- node ${ENTRY}"
fi

echo ""
echo "==> Manual config for other tools"
echo ""
echo "Cursor      → add to ~/.cursor/mcp.json:"
echo "Windsurf    → add to ~/.codeium/windsurf/mcp_config.json:"
echo "Codex / *   → any MCP-aware tool; same shape:"
echo ""
cat <<EOF
{
  "mcpServers": {
    "stake-engine-docs": {
      "command": "node",
      "args": ["${ENTRY}"]
    }
  }
}
EOF
echo ""
echo "==> Update: rerun this script to pull docs + rebuild."
