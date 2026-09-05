#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="${1:-$ROOT/out}"
DEB="$OUT/isodock_1.0.0-6_amd64.deb"
SRC="$OUT/IsoDock-1.0.0-6-Complete-Source.tar.xz"
mkdir -p "$OUT"

[[ -f "$DEB" ]] || "$ROOT/packaging/build-deb.sh" "$DEB"
[[ -f "$SRC" ]] || "$ROOT/scripts/build-source-archive.sh" "$OUT"
sha256sum "$DEB" > "$DEB.sha256"
sha256sum "$SRC" > "$SRC.sha256"

cat > "$OUT/SHA256SUMS.txt" <<SUMS
$(sha256sum "$DEB" | sed "s#  $OUT/#  #")
$(sha256sum "$SRC" | sed "s#  $OUT/#  #")
SUMS

echo "Release artifacts written to $OUT"
