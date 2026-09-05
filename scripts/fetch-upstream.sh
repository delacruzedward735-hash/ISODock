#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck disable=SC1091
source "$ROOT/VERSION"
DEST="${ISODOCK_UPSTREAM_DIR:-$ROOT/.cache/upstream/Ventoy}"
URL="https://github.com/ventoy/Ventoy.git"

if [[ -d "$DEST/.git" ]]; then
  current="$(git -C "$DEST" rev-parse HEAD)"
  if [[ "$current" == "$VENTOY_UPSTREAM_COMMIT" ]]; then
    echo "Pinned Ventoy source already present: $current"
    "$ROOT/scripts/apply-upstream-overrides.sh" "$DEST"
    exit 0
  fi
  rm -rf "$DEST"
fi

mkdir -p "$(dirname "$DEST")"
git init -q "$DEST"
git -C "$DEST" remote add origin "$URL"
git -C "$DEST" fetch --depth 1 origin "$VENTOY_UPSTREAM_COMMIT"
git -C "$DEST" checkout -q --detach FETCH_HEAD

actual="$(git -C "$DEST" rev-parse HEAD)"
[[ "$actual" == "$VENTOY_UPSTREAM_COMMIT" ]] || {
  echo "Upstream commit verification failed: $actual" >&2
  exit 1
}

"$ROOT/scripts/apply-upstream-overrides.sh" "$DEST"
echo "Prepared Ventoy source at $DEST"
