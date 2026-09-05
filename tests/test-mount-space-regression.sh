#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LIB="$ROOT/runtime-template/tool/ventoy_lib.sh"

# Regression for mountpoints such as /media/user/ZORIN\040OS\04018.
# Unmount by source block device instead of the escaped mountpoint path.
grep -F 'umount --all-targets -- "$srcdev"' "$LIB" >/dev/null
grep -F 'findmnt -rn -S "$srcdev"' "$LIB" >/dev/null
if grep -n 'awk.*print.*\$2.*umount' "$LIB" >/dev/null; then
  echo "FAIL: mountpoint-based unmount logic detected" >&2
  exit 1
fi
echo "PASS: unmount logic is keyed by block-device source"
