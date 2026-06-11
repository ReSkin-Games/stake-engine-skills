#!/usr/bin/env bash
# update-sdk.sh — pull latest math-sdk from upstream.
#
# Usage: scripts/update-sdk.sh <math-sdk-dir>

set -euo pipefail

SDK_DIR="${1:?Usage: update-sdk.sh <math-sdk-dir>}"
exec "$(dirname "$0")/clone-sdk.sh" "${SDK_DIR}" --update
