#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
RUNTIME="$ROOT/runtime-template"
TMP="$(mktemp)"
trap 'rm -f "$TMP"' EXIT
(
  cd "$RUNTIME"
  find . -type f ! -name 'RUNTIME-SHA256SUMS.txt' -print0 \
    | sort -z \
    | xargs -0 sha256sum
) > "$TMP"
mv "$TMP" "$RUNTIME/RUNTIME-SHA256SUMS.txt"
echo "Updated runtime manifest."
