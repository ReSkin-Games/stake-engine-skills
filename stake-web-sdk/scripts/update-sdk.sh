#!/usr/bin/env bash
# update-sdk.sh — pull latest web-sdk from upstream.
#
# Usage: scripts/update-sdk.sh <web-sdk-dir>

set -euo pipefail

SDK_DIR="${1:?Usage: update-sdk.sh <web-sdk-dir>}"
exec "$(dirname "$0")/clone-sdk.sh" "${SDK_DIR}" --update
