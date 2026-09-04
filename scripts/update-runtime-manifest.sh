#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
RUNTIME="$ROOT/IsoDock/runtime-template"
(
  cd "$RUNTIME"
  {
    sha256sum boot/boot.img
    sha256sum boot/core.img.xz
    sha256sum ventoy/ventoy.disk.img.xz
    sha256sum Ventoy2Disk.sh
    sha256sum VentoyGUI.x86_64
  } > SOURCE-DERIVED-SHA256SUMS.txt
  find . -type f ! -name 'RUNTIME-SHA256SUMS.txt' -print0 | LC_ALL=C sort -z | xargs -0 sha256sum > RUNTIME-SHA256SUMS.txt
)
echo "Updated runtime manifests."
