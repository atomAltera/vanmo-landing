#!/usr/bin/env bash
# Re-render social preview images and tournament covers from the /og/* pages.
#
# Usage: scripts/render-og.sh          (dev server must be running on :4321)
#        BASE_URL=http://127.0.0.1:4322 scripts/render-og.sh
#
# Each page is shot at its own canvas size, then downsampled to the delivered
# size. The covers are laid out to read at 274×153 but shipped at 3× that
# (822×459) so they stay sharp on retina displays. The YouTube covers ship
# at their native 1920×1080, no downsampling, no top border.

set -euo pipefail

# 127.0.0.1, not localhost: the dev server binds IPv4 only.
BASE_URL="${BASE_URL:-http://127.0.0.1:4321}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LEAGUE_REPO="${LEAGUE_REPO:-$ROOT/../onemore-league-2026}"
COVER_DIR="$LEAGUE_REPO/assets/covers"
YOUTUBE_DIR="$COVER_DIR/youtube"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

CHROME="$(ls -d "$HOME"/Library/Caches/ms-playwright/chromium-*/chrome-mac-arm64/"Google Chrome for Testing.app"/Contents/MacOS/"Google Chrome for Testing" 2>/dev/null | tail -1)"
if [[ -z "$CHROME" ]]; then
  echo "Chromium not found. Run: npx playwright install chromium" >&2
  exit 1
fi

# Keep this list in sync with getStaticPaths in src/pages/og/cover/[slug].astro
# and src/pages/og/youtube/[slug].astro
STAGES=(series-1 series-2 series-3 series-4 series-5 final)

# the youtube/ subdir isn't tracked in this repo — provision it, but only if
# the league repo itself is actually checked out where we expect it
[[ -d "$COVER_DIR" ]] && mkdir -p "$YOUTUBE_DIR"

# route | canvas WxH | delivered WxH | output path
TARGETS=(
  "og/one_more_league_2026|1200x630|1200x630|$ROOT/public/images/events/oml2026-og.jpg"
)
for stage in "${STAGES[@]}"; do
  TARGETS+=("og/cover/$stage|1096x612|822x459|$COVER_DIR/$stage.jpg")
done
for stage in "${STAGES[@]}"; do
  TARGETS+=("og/youtube/$stage|1920x1080|1920x1080|$YOUTUBE_DIR/$stage.jpg")
done

shoot() {
  local route="$1" canvas="$2" delivered="$3" out="$4"

  "$CHROME" \
    --headless \
    --disable-gpu \
    --hide-scrollbars \
    --force-device-scale-factor=2 \
    --window-size="${canvas/x/,}" \
    --virtual-time-budget=15000 \
    --screenshot="$TMP_DIR/shot.png" \
    "$BASE_URL/$route" >/dev/null 2>&1

  magick "$TMP_DIR/shot.png" \
    -resize "$delivered!" \
    -quality 92 -strip \
    "$out"
}

# Exact hash of a crop of the title band, which every cover in a set shares —
# they differ only in the stage label below it.
title_hash() {
  magick "$1" -crop "$2" +repage -format '%#' info:
}

for target in "${TARGETS[@]}"; do
  IFS='|' read -r route canvas delivered out <<<"$target"

  if [[ ! -d "$(dirname "$out")" ]]; then
    echo "skip $route — missing $(dirname "$out")" >&2
    continue
  fi

  shoot "$route" "$canvas" "$delivered" "$out"
  echo "$out  ($(magick identify -format '%wx%h' "$out"), $(du -h "$out" | cut -f1))"
done

# The webfonts come off the network, so a shot can occasionally land before
# Cormorant is ready and fall back to a system serif. That is invisible in a
# file listing, so verify it instead of trusting it.
verify_stage_set() {
  local dir="$1" route_prefix="$2" canvas="$3" delivered="$4" crop="$5"
  [[ -d "$dir" ]] || return 0

  for pass in 1 2 3; do
    declare -A counts=()
    declare -A hashes=()
    for stage in "${STAGES[@]}"; do
      h="$(title_hash "$dir/$stage.jpg" "$crop")"
      hashes["$stage"]="$h"
      counts["$h"]=$(( ${counts["$h"]:-0} + 1 ))
    done

    # the hash most covers agree on is the correctly-rendered one
    local ref='' best=0
    for h in "${!counts[@]}"; do
      if (( counts["$h"] > best )); then best=${counts["$h"]}; ref="$h"; fi
    done
    (( best == ${#STAGES[@]} )) && return 0

    for stage in "${STAGES[@]}"; do
      [[ "${hashes[$stage]}" == "$ref" ]] && continue
      echo "re-render $stage ($route_prefix) — title band differs (webfont likely missed the shot)" >&2
      shoot "$route_prefix/$stage" "$canvas" "$delivered" "$dir/$stage.jpg"
    done

    if (( pass == 3 )); then
      echo "$route_prefix covers still inconsistent after 3 passes" >&2
      exit 1
    fi
  done
}

verify_stage_set "$COVER_DIR" "og/cover" "1096x612" "822x459" "822x300+0+0"
verify_stage_set "$YOUTUBE_DIR" "og/youtube" "1920x1080" "1920x1080" "1920x700+0+0"
