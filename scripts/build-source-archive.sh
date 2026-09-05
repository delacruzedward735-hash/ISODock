#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="${1:-$ROOT/out}"
SRC="${ISODOCK_UPSTREAM_DIR:-$ROOT/.cache/upstream/Ventoy}"
STAGE="$ROOT/.cache/source-stage"
ARCHIVE="$OUT/IsoDock-1.0.0-6-Complete-Source.tar.xz"

[[ -d "$SRC/.git" ]] || "$ROOT/scripts/fetch-upstream.sh"
mkdir -p "$OUT"
rm -rf "$STAGE"
mkdir -p "$STAGE/IsoDock-1.0.0-6/downstream" "$STAGE/IsoDock-1.0.0-6/upstream"

rsync -a \
  --exclude='.git/' --exclude='.cache/' --exclude='out/' \
  "$ROOT/" "$STAGE/IsoDock-1.0.0-6/downstream/"
rsync -a --exclude='.git/' "$SRC/" "$STAGE/IsoDock-1.0.0-6/upstream/Ventoy/"

tar --sort=name --mtime='UTC 2026-09-05' --owner=0 --group=0 --numeric-owner \
  -cJf "$ARCHIVE" -C "$STAGE" IsoDock-1.0.0-6
sha256sum "$ARCHIVE" > "$ARCHIVE.sha256"
echo "Complete corresponding source: $ARCHIVE"
