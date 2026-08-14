#!/usr/bin/env bash
# Re-render social preview images from the /og/* pages.
#
# Usage: scripts/render-og.sh          (dev server must be running on :4321)
#        BASE_URL=http://localhost:4322 scripts/render-og.sh
#
# Shoots at 2x and downsamples so the text stays crisp.

set -euo pipefail

# 127.0.0.1, not localhost: the dev server binds IPv4 only.
BASE_URL="${BASE_URL:-http://127.0.0.1:4321}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="$ROOT/public/images/events"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

CHROME="$(ls -d "$HOME"/Library/Caches/ms-playwright/chromium-*/chrome-mac-arm64/"Google Chrome for Testing.app"/Contents/MacOS/"Google Chrome for Testing" 2>/dev/null | tail -1)"
if [[ -z "$CHROME" ]]; then
  echo "Chromium not found. Run: npx playwright install chromium" >&2
  exit 1
fi

# route:output pairs
PAGES=(
  "og/one_more_league_2026:oml2026-og.jpg"
)

for pair in "${PAGES[@]}"; do
  route="${pair%%:*}"
  out="${pair##*:}"

  "$CHROME" \
    --headless \
    --disable-gpu \
    --hide-scrollbars \
    --force-device-scale-factor=2 \
    --window-size=1200,630 \
    --virtual-time-budget=8000 \
    --screenshot="$TMP_DIR/shot.png" \
    "$BASE_URL/$route" >/dev/null 2>&1

  magick "$TMP_DIR/shot.png" \
    -resize 1200x630 \
    -quality 90 -strip \
    "$OUT_DIR/$out"

  echo "$OUT_DIR/$out  ($(magick identify -format '%wx%h' "$OUT_DIR/$out"), $(du -h "$OUT_DIR/$out" | cut -f1))"
done
