#!/usr/bin/env bash
# pack.sh — build a release tarball.
#
# Usage: ./pack.sh
# Output: ../stake-engine-skills-v<VERSION>.tar.gz

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}"

VERSION=$(cat VERSION)
ARCHIVE="../stake-engine-skills-v${VERSION}.tar.gz"

# Ensure scripts are executable in the archive.
chmod +x install.sh pack.sh stake-*/scripts/*.sh 2>/dev/null || true

tar -czf "${ARCHIVE}" \
  --exclude='.git' \
  --exclude='.DS_Store' \
  --exclude='*.tar.gz' \
  -C .. \
  "$(basename "${SCRIPT_DIR}")"

echo "OK: ${ARCHIVE}"
ls -lh "${ARCHIVE}"
