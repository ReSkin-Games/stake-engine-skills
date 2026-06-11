#!/usr/bin/env bash
# clone-sdk.sh — clone or update Stake Engine math-sdk.
#
# Usage:
#   scripts/clone-sdk.sh <target-dir>           # clone if missing, no-op if present
#   scripts/clone-sdk.sh <target-dir> --update  # git pull on existing clone

set -euo pipefail

TARGET="${1:?Usage: clone-sdk.sh <target-dir> [--update]}"
MODE="${2:-init}"
UPSTREAM="https://github.com/StakeEngine/math-sdk.git"

if [ -d "${TARGET}" ]; then
  if [ -f "${TARGET}/Makefile" ] && [ -d "${TARGET}/src" ]; then
    if [ "${MODE}" = "--update" ]; then
      echo "Updating ${TARGET} from upstream..."
      cd "${TARGET}"
      git pull --ff-only origin main || git pull --ff-only origin master
      echo "OK: math-sdk updated"
    else
      echo "OK: math-sdk already at ${TARGET}"
    fi
    exit 0
  else
    echo "ERROR: ${TARGET} exists but does not look like math-sdk" >&2
    echo "FIX: choose a different path or remove ${TARGET}" >&2
    exit 30
  fi
fi

PARENT=$(dirname "${TARGET}")
if [ ! -d "${PARENT}" ]; then
  mkdir -p "${PARENT}"
fi

echo "Cloning ${UPSTREAM} → ${TARGET}..."
git clone --depth=1 "${UPSTREAM}" "${TARGET}"
echo "OK: cloned to ${TARGET}"
echo "Next: scripts/install-python-env.sh ${TARGET}"
