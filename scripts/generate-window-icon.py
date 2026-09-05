#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
from pathlib import Path
import sys

if len(sys.argv) != 3:
    raise SystemExit("usage: generate-window-icon.py ICON.png OUTPUT.c")

src = Path(sys.argv[1])
out = Path(sys.argv[2])
data = src.read_bytes()

lines = []
for i in range(0, len(data), 16):
    chunk = data[i:i+16]
    lines.append("    " + ", ".join(f"0x{b:02X}" for b in chunk) + ",")

text = """/******************************************************************************
 * window_icon_data.c - IsoDock downstream icon resource
 *
 * Generated from the IsoDock 128x128 PNG for the GPLv3+ Ventoy GTK GUI.
 * SPDX-License-Identifier: GPL-3.0-or-later
 ******************************************************************************/

#include <stdio.h>
#include <stdlib.h>

static unsigned char window_icon_hexData[] =
{
%s
};

void *get_window_icon_raw_data(int *len)
{
    *len = (int)sizeof(window_icon_hexData);
    return window_icon_hexData;
}
""" % "\n".join(lines)
out.parent.mkdir(parents=True, exist_ok=True)
out.write_text(text, encoding="utf-8")
