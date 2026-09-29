#!/usr/bin/env bash
set -euo pipefail

OUT=shogroo.png
base64 -d shogroo.png.base64 > "$OUT"
echo "Wrote $OUT"
