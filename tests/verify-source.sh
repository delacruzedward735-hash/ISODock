#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
APP="$ROOT/IsoDock"
RUNTIME="$APP/runtime-template"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
fail=0
ok(){ echo "[ OK ] $*"; }
bad(){ echo "[FAIL] $*"; fail=1; }

# Shell syntax
while IFS= read -r -d '' f; do
  bash -n "$f" || bad "shell syntax: ${f#$ROOT/}"
done < <(find "$APP" -type f \( -name '*.sh' -o -path "$APP/packaging/isodock" -o -path "$APP/packaging/postinst" -o -path "$APP/packaging/postrm" \) -print0)
(( fail == 0 )) && ok "shell syntax"

# JSON/XML metadata
python3 - "$RUNTIME/plugin/ventoy/ventoy.json" "$RUNTIME/tool/languages.json" "$APP/packaging/online.myportfoliohub.isodock.metainfo.xml" <<'PY'
import json, sys, xml.etree.ElementTree as ET
json.load(open(sys.argv[1], encoding='utf-8'))
json.load(open(sys.argv[2], encoding='utf-8'))
ET.parse(sys.argv[3])
PY
ok "JSON and AppStream XML parse"

# No sample/fake menu configuration in shipped plugin template
if grep -qE 'My Custom Menu|auto_install|MX 19\.1 ISO file For me|cn_windows_10' "$RUNTIME/plugin/ventoy/ventoy_grub.cfg" "$RUNTIME/plugin/ventoy/ventoy.json"; then
  bad "demo plugin entries remain"
else
  ok "no demo/fake boot entries"
fi

# Boot payload
[[ $(stat -c %s "$RUNTIME/boot/boot.img") -eq 512 ]] && ok "boot.img is 512 bytes" || bad "boot.img size"
xz -t "$RUNTIME/boot/core.img.xz" && ok "core.img.xz integrity" || bad "core.img.xz"
[[ $(xz -dc "$RUNTIME/boot/core.img.xz" | wc -c) -eq 1048064 ]] && ok "core.img payload size" || bad "core.img payload size"
xz -t "$RUNTIME/ventoy/ventoy.disk.img.xz" && ok "VTOYEFI xz integrity" || bad "VTOYEFI xz"
xz -dc "$RUNTIME/ventoy/ventoy.disk.img.xz" > "$TMP/vtoyefi.img"
[[ $(stat -c %s "$TMP/vtoyefi.img") -eq 33554432 ]] && ok "VTOYEFI 32 MiB" || bad "VTOYEFI size"
parsed="$($RUNTIME/tool/x86_64/vtoycli fat "$TMP/vtoyefi.img" 2>/dev/null || true)"
[[ "$parsed" == "1.1.17" ]] && ok "Ventoy FAT parser sees 1.1.17" || bad "FAT parser version ($parsed)"
"$RUNTIME/tool/x86_64/vtoycli" fat -s "$TMP/vtoyefi.img" >/dev/null 2>&1 && ok "Secure Boot files present" || bad "Secure Boot files missing"
grep -aF 'IsoDock 1.0.0  |  Ventoy Engine' "$TMP/vtoyefi.img" >/dev/null && ok "IsoDock boot branding marker" || bad "boot branding marker"

# Rebuild/read-back helper
command -v gcc >/dev/null || bad "gcc not available for fatcopy test"
if command -v gcc >/dev/null; then
  gcc -no-pie -O2 -D_FILE_OFFSET_BITS=64 \
    -I"$ROOT/Ventoy/vtoycli/fat_io_lib/include" \
    "$APP/tools/fatcopy/fatcopy.c" \
    "$ROOT/Ventoy/vtoycli/fat_io_lib/lib/libfat_io_64.a" \
    -o "$TMP/fatcopy"
  "$TMP/fatcopy" get "$TMP/vtoyefi.img" /grub/themes/ventoy/theme.txt "$TMP/theme.txt"
  "$TMP/fatcopy" get "$TMP/vtoyefi.img" /grub/themes/ventoy/background.png "$TMP/background.png"
  "$TMP/fatcopy" get "$TMP/vtoyefi.img" /grub/themes/ventoy/select_c.png "$TMP/select_c.png"
  "$TMP/fatcopy" get "$TMP/vtoyefi.img" /grub/themes/ventoy/slider_c.png "$TMP/slider_c.png"
  "$TMP/fatcopy" get "$TMP/vtoyefi.img" /grub/themes/ventoy/slider_n.png "$TMP/slider_n.png"
  "$TMP/fatcopy" get "$TMP/vtoyefi.img" /grub/themes/ventoy/slider_s.png "$TMP/slider_s.png"
  "$TMP/fatcopy" get "$TMP/vtoyefi.img" /grub/grub.cfg "$TMP/grub.cfg"
  cmp "$APP/boot-theme/theme.txt" "$TMP/theme.txt" && ok "embedded theme read-back" || bad "embedded theme mismatch"
  cmp "$APP/boot-theme/background.png" "$TMP/background.png" && ok "embedded background read-back" || bad "embedded background mismatch"
  cmp "$APP/boot-theme/select_c.png" "$TMP/select_c.png" && ok "embedded selection bar read-back" || bad "embedded selection bar mismatch"
  cmp "$APP/boot-theme/slider_c.png" "$TMP/slider_c.png" && ok "embedded scrollbar center read-back" || bad "embedded scrollbar center mismatch"
  cmp "$APP/boot-theme/slider_n.png" "$TMP/slider_n.png" && ok "embedded scrollbar top read-back" || bad "embedded scrollbar top mismatch"
  cmp "$APP/boot-theme/slider_s.png" "$TMP/slider_s.png" && ok "embedded scrollbar bottom read-back" || bad "embedded scrollbar bottom mismatch"
  cmp "$ROOT/Ventoy/INSTALL/grub/grub.cfg" "$TMP/grub.cfg" && ok "embedded grub.cfg read-back" || bad "embedded grub.cfg mismatch"
fi

# Runtime manifest
if (cd "$RUNTIME" && sha256sum -c --quiet RUNTIME-SHA256SUMS.txt); then ok "runtime SHA-256 manifest"; else bad "runtime SHA-256 manifest"; fi

# Native GUI and downstream mount fix
ldd "$RUNTIME/tool/x86_64/Ventoy2Disk.gtk3" 2>&1 | grep 'not found' && bad "GTK3 missing library" || ok "GTK3 dependencies resolved"
grep -F '>IsoDock<' "$RUNTIME/tool/VentoyGTK.glade" >/dev/null && ok "native window branding" || bad "native window branding"
grep -F 'IsoDock In Package' "$RUNTIME/tool/languages.json" >/dev/null && ok "native language branding" || bad "native language branding"
grep -F 'umount --all-targets -- "$srcdev"' "$RUNTIME/tool/ventoy_lib.sh" >/dev/null && ok "USB source-device unmount patch" || bad "USB unmount patch"

# Optional virtual GUI smoke test (non-destructive)
if [[ "${ISODOCK_GUI_SMOKE:-0}" == "1" ]] && command -v xvfb-run >/dev/null && command -v timeout >/dev/null; then
  cfg="$TMP/isodock.ini"; cp "$RUNTIME/Ventoy2Disk.ini" "$cfg"
  set +e
  (cd "$RUNTIME" && timeout 3s xvfb-run -a ./VentoyGUI.x86_64 --gtk3 -i "$cfg" -l "$TMP/gui.log")
  rc=$?
  set -e
  if [[ $rc -eq 124 || $rc -eq 0 ]]; then ok "native GUI smoke launch"; else bad "native GUI smoke launch rc=$rc"; fi
fi

if (( fail )); then
  echo "Source verification: FAILED"
  exit 1
fi
echo "Source verification: PASS"
