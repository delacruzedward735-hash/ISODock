#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="${1:-$PWD/isodock_1.0.0-6_amd64.deb}"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
PKG="$TMP/pkg"
RUNTIME="$PKG/usr/lib/isodock/engine/1.1.17"

mkdir -p \
  "$PKG/DEBIAN" "$RUNTIME" "$PKG/usr/bin" \
  "$PKG/usr/share/applications" "$PKG/usr/share/metainfo" \
  "$PKG/usr/share/doc/isodock" "$PKG/usr/share/isodock" \
  "$PKG/usr/share/icons"

cp -a "$ROOT/runtime-template/." "$RUNTIME/"
cp "$ROOT/packaging/isodock" "$PKG/usr/bin/isodock"
cp "$ROOT/packaging/isodock.desktop" "$PKG/usr/share/applications/isodock.desktop"
cp "$ROOT/packaging/online.myportfoliohub.isodock.metainfo.xml" "$PKG/usr/share/metainfo/"
cp "$ROOT/packaging/control" "$PKG/DEBIAN/control"
cp "$ROOT/packaging/postinst" "$PKG/DEBIAN/postinst"
cp "$ROOT/packaging/postrm" "$PKG/DEBIAN/postrm"
cp -a "$ROOT/docs/." "$PKG/usr/share/doc/isodock/"
cp -a "$ROOT/icons/hicolor" "$PKG/usr/share/icons/"
cp "$ROOT/branding/isodock-icon-master.png" "$PKG/usr/share/isodock/isodock-icon-master.png"
cp "$ROOT/branding/isodock-boot-background.png" "$PKG/usr/share/isodock/isodock-boot-background.png"

find "$PKG" -type d -exec chmod 0755 {} +
find "$PKG" -type d -exec chmod g-s {} +
chmod 0755 "$PKG/usr/bin/isodock" "$PKG/DEBIAN/postinst" "$PKG/DEBIAN/postrm"
chmod 0755 \
  "$RUNTIME/VentoyGUI.x86_64" "$RUNTIME/Ventoy2Disk.sh" \
  "$RUNTIME/VentoyPlugson.sh" "$RUNTIME/VentoyWeb.sh" \
  "$RUNTIME/CreatePersistentImg.sh" "$RUNTIME/ExtendPersistentImg.sh" \
  "$RUNTIME/tool/VentoyWorker.sh" "$RUNTIME/tool/create_ventoy_iso_part_dm.sh" \
  "$RUNTIME/tool/ventoy_lib.sh"
find "$RUNTIME/tool/x86_64" -maxdepth 1 -type f -exec chmod 0755 {} +

dpkg-deb --root-owner-group --build "$PKG" "$OUT"
sha256sum "$OUT" > "$OUT.sha256"
