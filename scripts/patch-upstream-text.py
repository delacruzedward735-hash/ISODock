#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
from pathlib import Path
import sys

if len(sys.argv) != 2:
    raise SystemExit("usage: patch-upstream-text.py VENTOY_SOURCE_DIR")

root = Path(sys.argv[1])

def replace_required(path: Path, old: str, new: str) -> None:
    text = path.read_text(encoding="utf-8")
    if new in text:
        return
    if old not in text:
        raise SystemExit(f"expected upstream text not found in {path}: {old!r}")
    path.write_text(text.replace(old, new), encoding="utf-8")

# Keep the upstream identity visible while adding the downstream product label.
grub = root / "INSTALL/grub/grub.cfg"
text = grub.read_text(encoding="utf-8")
marker = "# IsoDock branding layer; Ventoy engine attribution and license retained."
if marker not in text:
    needle = "#************************************************************************************\n\nif [ \"$grub_platform\" = \"pc\" ]; then"
    replacement = f"#************************************************************************************\n{marker}\n\nif [ \"$grub_platform\" = \"pc\" ]; then"
    if needle not in text:
        raise SystemExit("could not locate grub.cfg branding insertion point")
    grub.write_text(text.replace(needle, replacement, 1), encoding="utf-8")

for old, new in [
    ("Ventoy $VENTOY_VERSION BIOS  www.ventoy.net", "IsoDock 1.0.0  |  Ventoy Engine $VENTOY_VERSION  |  BIOS"),
    ("Ventoy $VENTOY_VERSION IA32  www.ventoy.net", "IsoDock 1.0.0  |  Ventoy Engine $VENTOY_VERSION  |  IA32"),
    ("Ventoy $VENTOY_VERSION AA64  www.ventoy.net", "IsoDock 1.0.0  |  Ventoy Engine $VENTOY_VERSION  |  AA64"),
    ("Ventoy $VENTOY_VERSION MIPS  www.ventoy.net", "IsoDock 1.0.0  |  Ventoy Engine $VENTOY_VERSION  |  MIPS"),
    ("Ventoy $VENTOY_VERSION UEFI  www.ventoy.net", "IsoDock 1.0.0  |  Ventoy Engine $VENTOY_VERSION  |  UEFI"),
]:
    replace_required(grub, old, new)

# Use the shorter visible label from the approved IsoDock theme while preserving the F6 action.
en_us = root / "INSTALL/grub/menu/en_US.json"
text = en_us.read_text(encoding="utf-8")
if "F6:ExMenu" in text:
    en_us.write_text(text.replace("F6:ExMenu", "F6:Menu"), encoding="utf-8")

print("Applied IsoDock text-level upstream changes.")
