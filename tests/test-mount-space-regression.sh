#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
LIB="$ROOT/IsoDock/runtime-template/tool/ventoy_lib.sh"
# Regression for the Zorin-style mountpoint that originally failed:
# /media/user/ZORIN\040OS\04018 must never be passed as the primary unmount key.
grep -F 'umount --all-targets -- "$srcdev"' "$LIB" >/dev/null
grep -F 'findmnt -rn -S "$srcdev"' "$LIB" >/dev/null
if grep -n 'awk.*print.*\$2.*umount' "$LIB" >/dev/null; then
  echo "FAIL: mountpoint-based unmount logic detected" >&2
  exit 1
fi
echo "PASS: unmount logic is keyed by block-device source"
