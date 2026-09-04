#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
OUT="${1:-$ROOT/out}"
mkdir -p "$OUT"
DEB="$OUT/isodock_1.0.0-6_amd64.deb"
[[ -f "$DEB" ]] || "$ROOT/IsoDock/packaging/build-deb.sh" "$DEB"
sha256sum "$DEB" > "$DEB.sha256"
# Source archive excludes generated out/ but includes the full corresponding Ventoy source.
tar --exclude='./out' --sort=name --mtime='UTC 2026-09-03' --owner=0 --group=0 --numeric-owner \
  -cJf "$OUT/IsoDock-1.0.0-Complete-Source.tar.xz" -C "$(dirname "$ROOT")" "$(basename "$ROOT")"
sha256sum "$OUT/IsoDock-1.0.0-Complete-Source.tar.xz" > "$OUT/IsoDock-1.0.0-Complete-Source.tar.xz.sha256"
echo "Release artifacts written to $OUT"
