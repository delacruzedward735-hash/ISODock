#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
RUNTIME="$ROOT/IsoDock/runtime-template"
SRC="$ROOT/Ventoy"
TOOL_SRC="$ROOT/IsoDock/tools/fatcopy/fatcopy.c"
INCLUDE="$SRC/vtoycli/fat_io_lib/include"
LIB="$SRC/vtoycli/fat_io_lib/lib/libfat_io_64.a"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
FATCOPY="$TMP/isodock-fatcopy"
RAW="$TMP/ventoy.disk.img"

command -v gcc >/dev/null || { echo "gcc is required" >&2; exit 1; }
command -v xz >/dev/null || { echo "xz is required" >&2; exit 1; }

gcc -no-pie -O2 -D_FILE_OFFSET_BITS=64 -I"$INCLUDE" "$TOOL_SRC" "$LIB" -o "$FATCOPY"
xz -dc "$RUNTIME/ventoy/ventoy.disk.img.xz" > "$RAW"

"$FATCOPY" put "$RAW" "$SRC/INSTALL/grub/grub.cfg" /grub/grub.cfg
"$FATCOPY" put "$RAW" "$ROOT/IsoDock/boot-theme/theme.txt" /grub/themes/ventoy/theme.txt
"$FATCOPY" put "$RAW" "$ROOT/IsoDock/boot-theme/background.png" /grub/themes/ventoy/background.png
"$FATCOPY" put "$RAW" "$ROOT/IsoDock/boot-theme/select_c.png" /grub/themes/ventoy/select_c.png
"$FATCOPY" put "$RAW" "$ROOT/IsoDock/boot-theme/slider_c.png" /grub/themes/ventoy/slider_c.png
"$FATCOPY" put "$RAW" "$ROOT/IsoDock/boot-theme/slider_n.png" /grub/themes/ventoy/slider_n.png
"$FATCOPY" put "$RAW" "$ROOT/IsoDock/boot-theme/slider_s.png" /grub/themes/ventoy/slider_s.png

"$FATCOPY" get "$RAW" /grub/grub.cfg "$TMP/grub.cfg"
"$FATCOPY" get "$RAW" /grub/themes/ventoy/theme.txt "$TMP/theme.txt"
"$FATCOPY" get "$RAW" /grub/themes/ventoy/background.png "$TMP/background.png"
"$FATCOPY" get "$RAW" /grub/themes/ventoy/select_c.png "$TMP/select_c.png"
"$FATCOPY" get "$RAW" /grub/themes/ventoy/slider_c.png "$TMP/slider_c.png"
"$FATCOPY" get "$RAW" /grub/themes/ventoy/slider_n.png "$TMP/slider_n.png"
"$FATCOPY" get "$RAW" /grub/themes/ventoy/slider_s.png "$TMP/slider_s.png"
cmp "$SRC/INSTALL/grub/grub.cfg" "$TMP/grub.cfg"
cmp "$ROOT/IsoDock/boot-theme/theme.txt" "$TMP/theme.txt"
cmp "$ROOT/IsoDock/boot-theme/background.png" "$TMP/background.png"
cmp "$ROOT/IsoDock/boot-theme/select_c.png" "$TMP/select_c.png"
cmp "$ROOT/IsoDock/boot-theme/slider_c.png" "$TMP/slider_c.png"
cmp "$ROOT/IsoDock/boot-theme/slider_n.png" "$TMP/slider_n.png"
cmp "$ROOT/IsoDock/boot-theme/slider_s.png" "$TMP/slider_s.png"

[[ $(stat -c %s "$RAW") -eq 33554432 ]] || { echo "Unexpected VTOYEFI image size" >&2; exit 1; }
parsed="$($RUNTIME/tool/x86_64/vtoycli fat "$RAW")"
[[ "$parsed" == "1.1.17" ]] || { echo "Unexpected engine version: $parsed" >&2; exit 1; }
"$RUNTIME/tool/x86_64/vtoycli" fat -s "$RAW" >/dev/null

xz --check=crc32 -T1 -9 -c "$RAW" > "$RUNTIME/ventoy/ventoy.disk.img.xz"
xz -t "$RUNTIME/ventoy/ventoy.disk.img.xz"
"$ROOT/IsoDock/scripts/update-runtime-manifest.sh"
echo "Rebuilt IsoDock VTOYEFI boot image successfully."
