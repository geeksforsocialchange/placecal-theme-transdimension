#!/bin/bash
set -euo pipefail

# TransDimension golden screenshot capture script
# Captures all routes at 4 viewports and creates a manifest

export LC_ALL=en_US.UTF-8

CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
OUTPUT_DIR="${1:-.}"
TODAY=$(date -u +%Y-%m-%d)
OUTPUT_DIR="${OUTPUT_DIR%/}/goldens/$TODAY"
MANIFEST="$OUTPUT_DIR/manifest.json"

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Viewports: width in px
declare -a VIEWPORTS=("450" "650" "950" "1250")
declare -a VIEWPORT_NAMES=("mobile" "tablet" "desktop" "wide")

# Routes to capture (url, slug for filename)
declare -a ROUTES=(
  "/" "home"
  "/about" "about"
  "/events" "events"
  "/events/416614" "events_416614"
  "/events/417493" "events_417493"
  "/events/485844" "events_485844"
  "/events?region=london" "events_region_london"
  "/events?region=manchester" "events_region_manchester"
  "/join-us" "join_us"
  "/news" "news"
  "/news/greater-manchester-trans-organisers-fund" "news_greater_manchester_trans_organisers_fund"
  "/news/can-you-help-out-with-the-trans-dimension" "news_can_you_help_out_with_the_trans_dimension"
  "/news/the-trans-dimension-is-now-in-manchester" "news_the_trans_dimension_is_now_in_manchester"
  "/partners" "partners"
  "/partners/150" "partners_150"
  "/partners/427" "partners_427"
  "/partners/445" "partners_445"
  "/partners?region=london" "partners_region_london"
  "/partners?region=manchester" "partners_region_manchester"
  "/privacy" "privacy"
)

# Build manifest array
MANIFEST_ENTRIES="["

CAPTURED=0

# Iterate routes
for ((i=0; i<${#ROUTES[@]}; i+=2)); do
  URL="${ROUTES[$i]}"
  SLUG="${ROUTES[$((i+1))]}"
  FULL_URL="https://transdimension.uk$URL"

  # Iterate viewports
  for ((j=0; j<${#VIEWPORTS[@]}; j++)); do
    WIDTH="${VIEWPORTS[$j]}"
    VNAME="${VIEWPORT_NAMES[$j]}"
    OUTFILE="$OUTPUT_DIR/${SLUG}__${VNAME}.png"

    echo "Capturing $FULL_URL at ${WIDTH}px (${VNAME})..."

    # Capture with Chrome
    "$CHROME" \
      --headless=new \
      --disable-gpu \
      --hide-scrollbars \
      --window-size="${WIDTH},4000" \
      --virtual-time-budget=8000 \
      --screenshot="$OUTFILE" \
      "$FULL_URL" \
      > /dev/null 2>&1 || true

    # Verify PNG signature and size
    if [ ! -f "$OUTFILE" ]; then
      echo "ERROR: Failed to capture $FULL_URL at ${WIDTH}px"
      exit 1
    fi

    PNG_SIG=$(head -c 4 "$OUTFILE" | od -An -tx1 | tr -d ' ')
    FILE_SIZE=$(/usr/bin/stat -f%z "$OUTFILE" 2>/dev/null || echo 0)

    if [ "$PNG_SIG" != "89504e47" ]; then
      echo "ERROR: Invalid PNG signature for $OUTFILE: $PNG_SIG"
      echo "File contents:"
      head -c 100 "$OUTFILE"
      exit 1
    fi

    if [ "$FILE_SIZE" -lt 20000 ]; then
      echo "ERROR: PNG too small ($FILE_SIZE bytes) for $OUTFILE"
      exit 1
    fi

    # Calculate SHA256
    SHA256=$(shasum -a 256 "$OUTFILE" | awk '{print $1}')

    # Add to manifest
    if [ "$CAPTURED" -gt 0 ]; then
      MANIFEST_ENTRIES+=","
    fi

    CAPTURED=$((CAPTURED + 1))
    TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

    MANIFEST_ENTRIES+=$(cat <<JSON
{
  "url": "$FULL_URL",
  "path": "$URL",
  "viewport": "$VNAME",
  "width": $WIDTH,
  "file": "${SLUG}__${VNAME}.png",
  "captured_at": "$TIMESTAMP",
  "bytes": $FILE_SIZE,
  "sha256": "$SHA256"
}
JSON
)
  done
done

MANIFEST_ENTRIES+="]"

# Write manifest
echo "$MANIFEST_ENTRIES" | python3 -m json.tool > "$MANIFEST"

echo ""
echo "=== Capture Complete ==="
echo "Output directory: $OUTPUT_DIR"
echo "Captured: $CAPTURED screenshots"
echo "Manifest: $MANIFEST"

# Verify manifest is valid JSON
python3 -c "import json; json.load(open('$MANIFEST'))" || exit 1
echo "Manifest is valid JSON"
