#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="${1:-${ISODOCK_UPSTREAM_DIR:-$ROOT/.cache/upstream/Ventoy}}"

[[ -d "$SRC/INSTALL" ]] || { echo "Ventoy source not found at $SRC" >&2; exit 1; }

"$ROOT/scripts/patch-upstream-text.py" "$SRC"

# Source/runtime overrides maintained by IsoDock.
install -Dm0644 "$ROOT/runtime-template/plugin/ventoy/ventoy.json" "$SRC/INSTALL/plugin/ventoy/ventoy.json"
install -Dm0644 "$ROOT/runtime-template/plugin/ventoy/ventoy_grub.cfg" "$SRC/INSTALL/plugin/ventoy/ventoy_grub.cfg"
install -Dm0644 "$ROOT/runtime-template/tool/VentoyGTK.glade" "$SRC/INSTALL/tool/VentoyGTK.glade"
install -Dm0755 "$ROOT/runtime-template/tool/ventoy_lib.sh" "$SRC/INSTALL/tool/ventoy_lib.sh"
install -Dm0644 "$ROOT/runtime-template/tool/languages.json" "$SRC/LANGUAGES/languages.json"

# Theme assets.
install -Dm0644 "$ROOT/boot-theme/theme.txt" "$SRC/INSTALL/grub/themes/ventoy/theme.txt"
for f in background.png select_c.png slider_c.png slider_n.png slider_s.png; do
  install -Dm0644 "$ROOT/boot-theme/$f" "$SRC/INSTALL/grub/themes/ventoy/$f"
done

# Reproducibly generate the GTK icon source from the committed 128px PNG.
"$ROOT/scripts/generate-window-icon.py" \
  "$ROOT/icons/hicolor/128x128/apps/isodock.png" \
  "$SRC/LinuxGUI/Ventoy2Disk/GTK/window_icon_data.c"

echo "Applied IsoDock downstream source changes to $SRC"
