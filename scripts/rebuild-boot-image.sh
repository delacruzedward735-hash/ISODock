#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
RUNTIME="$ROOT/runtime-template"
SRC="${ISODOCK_UPSTREAM_DIR:-$ROOT/.cache/upstream/Ventoy}"
TOOL_SRC="$ROOT/tools/fatcopy/fatcopy.c"
INCLUDE="$SRC/vtoycli/fat_io_lib/include"
LIB="$SRC/vtoycli/fat_io_lib/lib/libfat_io_64.a"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
FATCOPY="$TMP/isodock-fatcopy"
RAW="$TMP/ventoy.disk.img"

[[ -f "$SRC/INSTALL/grub/grub.cfg" ]] || {
  echo "Prepared upstream source missing. Run: make prepare-upstream" >&2
  exit 1
}
command -v gcc >/dev/null || { echo "gcc is required" >&2; exit 1; }
command -v xz >/dev/null || { echo "xz is required" >&2; exit 1; }

gcc -no-pie -O2 -D_FILE_OFFSET_BITS=64 -I"$INCLUDE" "$TOOL_SRC" "$LIB" -o "$FATCOPY"
xz -dc "$RUNTIME/ventoy/ventoy.disk.img.xz" > "$RAW"

"$FATCOPY" put "$RAW" "$SRC/INSTALL/grub/grub.cfg" /grub/grub.cfg
"$FATCOPY" put "$RAW" "$ROOT/boot-theme/theme.txt" /grub/themes/ventoy/theme.txt
for f in background.png select_c.png slider_c.png slider_n.png slider_s.png; do
  "$FATCOPY" put "$RAW" "$ROOT/boot-theme/$f" "/grub/themes/ventoy/$f"
done

"$FATCOPY" get "$RAW" /grub/grub.cfg "$TMP/grub.cfg"
cmp "$SRC/INSTALL/grub/grub.cfg" "$TMP/grub.cfg"
for f in theme.txt background.png select_c.png slider_c.png slider_n.png slider_s.png; do
  "$FATCOPY" get "$RAW" "/grub/themes/ventoy/$f" "$TMP/$f"
  cmp "$ROOT/boot-theme/$f" "$TMP/$f"
done

[[ $(stat -c %s "$RAW") -eq 33554432 ]] || { echo "Unexpected VTOYEFI image size" >&2; exit 1; }
parsed="$($RUNTIME/tool/x86_64/vtoycli fat "$RAW")"
[[ "$parsed" == "1.1.17" ]] || { echo "Unexpected engine version: $parsed" >&2; exit 1; }
"$RUNTIME/tool/x86_64/vtoycli" fat -s "$RAW" >/dev/null

xz --check=crc32 -T1 -9 -c "$RAW" > "$RUNTIME/ventoy/ventoy.disk.img.xz"
xz -t "$RUNTIME/ventoy/ventoy.disk.img.xz"
"$ROOT/scripts/update-runtime-manifest.sh"
echo "Rebuilt IsoDock VTOYEFI boot image successfully."
