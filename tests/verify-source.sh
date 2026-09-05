#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
RUNTIME="$ROOT/runtime-template"
UPSTREAM="${ISODOCK_UPSTREAM_DIR:-$ROOT/.cache/upstream/Ventoy}"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
fail=0
ok(){ echo "[ OK ] $*"; }
bad(){ echo "[FAIL] $*"; fail=1; }

# shellcheck disable=SC1091
source "$ROOT/VERSION"
[[ "$ISODOCK_VERSION" == "1.0.0" && "$PACKAGE_REVISION" == "6" ]] \
  && ok "version metadata 1.0.0-6" || bad "version metadata"
grep -F 'Version: 1.0.0-6' "$ROOT/packaging/control" >/dev/null \
  && ok "Debian control version" || bad "Debian control version"

while IFS= read -r -d '' f; do
  bash -n "$f" || bad "shell syntax: ${f#$ROOT/}"
done < <(find "$ROOT" -type f \( -name '*.sh' -o -path "$ROOT/packaging/isodock" -o -path "$ROOT/packaging/postinst" -o -path "$ROOT/packaging/postrm" \) \
  -not -path "$ROOT/.cache/*" -print0)
(( fail == 0 )) && ok "shell syntax"

python3 - "$RUNTIME/plugin/ventoy/ventoy.json" "$RUNTIME/tool/languages.json" "$ROOT/packaging/online.myportfoliohub.isodock.metainfo.xml" <<'PY'
import json, sys, xml.etree.ElementTree as ET
json.load(open(sys.argv[1], encoding='utf-8'))
json.load(open(sys.argv[2], encoding='utf-8'))
ET.parse(sys.argv[3])
PY
ok "JSON and AppStream XML parse"

if grep -qE 'My Custom Menu|auto_install|MX 19\.1 ISO file For me|cn_windows_10' "$RUNTIME/plugin/ventoy/ventoy_grub.cfg" "$RUNTIME/plugin/ventoy/ventoy.json"; then
  bad "demo plugin entries remain"
else
  ok "no demo/fake boot entries"
fi

[[ $(stat -c %s "$RUNTIME/boot/boot.img") -eq 512 ]] && ok "boot.img is 512 bytes" || bad "boot.img size"
xz -t "$RUNTIME/boot/core.img.xz" && ok "core.img.xz integrity" || bad "core.img.xz"
[[ $(xz -dc "$RUNTIME/boot/core.img.xz" | wc -c) -eq 1048064 ]] && ok "core.img payload size" || bad "core.img payload size"
xz -t "$RUNTIME/ventoy/ventoy.disk.img.xz" && ok "VTOYEFI xz integrity" || bad "VTOYEFI xz"
xz -dc "$RUNTIME/ventoy/ventoy.disk.img.xz" > "$TMP/vtoyefi.img"
[[ $(stat -c %s "$TMP/vtoyefi.img") -eq 33554432 ]] && ok "VTOYEFI 32 MiB" || bad "VTOYEFI size"
parsed="$($RUNTIME/tool/x86_64/vtoycli fat "$TMP/vtoyefi.img" 2>/dev/null || true)"
[[ "$parsed" == "$VENTOY_ENGINE_VERSION" ]] && ok "Ventoy FAT parser sees $VENTOY_ENGINE_VERSION" || bad "FAT parser version ($parsed)"
"$RUNTIME/tool/x86_64/vtoycli" fat -s "$TMP/vtoyefi.img" >/dev/null 2>&1 && ok "Secure Boot files present" || bad "Secure Boot files missing"
grep -aF 'IsoDock 1.0.0  |  Ventoy Engine' "$TMP/vtoyefi.img" >/dev/null && ok "IsoDock boot branding marker" || bad "boot branding marker"

if [[ -f "$UPSTREAM/vtoycli/fat_io_lib/lib/libfat_io_64.a" ]]; then
  gcc -no-pie -O2 -D_FILE_OFFSET_BITS=64 \
    -I"$UPSTREAM/vtoycli/fat_io_lib/include" \
    "$ROOT/tools/fatcopy/fatcopy.c" \
    "$UPSTREAM/vtoycli/fat_io_lib/lib/libfat_io_64.a" \
    -o "$TMP/fatcopy"
  "$TMP/fatcopy" get "$TMP/vtoyefi.img" /grub/grub.cfg "$TMP/grub.cfg"
  cmp "$UPSTREAM/INSTALL/grub/grub.cfg" "$TMP/grub.cfg" && ok "embedded grub.cfg read-back" || bad "embedded grub.cfg mismatch"
  for f in theme.txt background.png select_c.png slider_c.png slider_n.png slider_s.png; do
    "$TMP/fatcopy" get "$TMP/vtoyefi.img" "/grub/themes/ventoy/$f" "$TMP/$f"
    cmp "$ROOT/boot-theme/$f" "$TMP/$f" && ok "embedded $f read-back" || bad "embedded $f mismatch"
  done
else
  echo "[INFO] upstream source not prepared; skipping FAT file read-back (run make prepare-upstream)"
fi

if (cd "$RUNTIME" && sha256sum -c --quiet RUNTIME-SHA256SUMS.txt); then
  ok "runtime SHA-256 manifest"
else
  bad "runtime SHA-256 manifest"
fi

if command -v ldd >/dev/null 2>&1; then
  ldd "$RUNTIME/tool/x86_64/Ventoy2Disk.gtk3" 2>&1 | grep 'not found' && bad "GTK3 missing library" || ok "GTK3 dependencies resolved"
fi
grep -F '>IsoDock<' "$RUNTIME/tool/VentoyGTK.glade" >/dev/null && ok "native window branding" || bad "native window branding"
grep -F 'IsoDock In Package' "$RUNTIME/tool/languages.json" >/dev/null && ok "native language branding" || bad "native language branding"
grep -F 'umount --all-targets -- "$srcdev"' "$RUNTIME/tool/ventoy_lib.sh" >/dev/null && ok "USB source-device unmount patch" || bad "USB unmount patch"

for f in LICENSE NOTICE.md UPSTREAM.md SOURCE-POLICY.md CONTRIBUTING.md CODE_OF_CONDUCT.md SECURITY.md SUPPORT.md; do
  [[ -s "$ROOT/$f" ]] && ok "open-source metadata: $f" || bad "missing $f"
done

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
