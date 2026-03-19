#!/usr/bin/env bash
# Arolsen Archives search — finds Nazi-era persecution records via headless browser
# Usage: arolsen-search.sh SURNAME [GIVEN_NAME]
#   SURNAME    - required
#   GIVEN_NAME - optional
# Outputs tab-separated: REFERENCE\tRELEVANCE\tSEGMENT\tCOLLECTION
# Requires: node, playwright (npm install in project root)
#
# NOTE: Arolsen search returns archive catalog entries (which card file segments
# contain matches), not person-level records. Follow up by visiting the actual
# documents at collections.arolsen-archives.org for names, dates, and details.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BROWSER_FETCH="$SCRIPT_DIR/browser-fetch.js"

SURNAME="${1:?Usage: arolsen-search.sh SURNAME [GIVEN_NAME]}"
GIVEN_NAME="${2:-}"

if [[ ! -f "$BROWSER_FETCH" ]]; then
  echo "ERROR: browser-fetch.js not found at $BROWSER_FETCH" >&2
  exit 1
fi

# Build Arolsen search URL
SEARCH_TERM="${SURNAME}"
if [[ -n "$GIVEN_NAME" ]]; then
  SEARCH_TERM="${GIVEN_NAME}+${SURNAME}"
fi

URL="https://collections.arolsen-archives.org/en/search/people?s=${SEARCH_TERM}"

# Fetch rendered page — dismiss cookie consent, then wait for result table rows
# Arolsen uses Angular Material; results render in <tr> inside yv-its-topic-grid
HTML=$(node "$BROWSER_FETCH" "$URL" \
  --click ".ccm--save-settings" \
  --wait-for "yv-its-topic-grid tr" \
  --timeout 30000 \
  --extract "yv-its-topic-grid tr" 2>/dev/null) || {
  echo "No results found for '${SEARCH_TERM}'" >&2
  exit 0
}

if [[ -z "$HTML" ]]; then
  echo "No results found for '${SEARCH_TERM}'" >&2
  exit 0
fi

# Parse table rows — each <tr> has 4 <td> cells:
#   1. Archive reference (e.g., "0001 1 288.259")
#   2. Relevance score (e.g., "0.1")
#   3. Segment name (e.g., "Card file segment 100709")
#   4. Collection path (e.g., "Global Finding Aids / Central Name Index / ...")
echo "$HTML" | LC_ALL=C awk '
BEGIN { OFS="\t" }
{
  # Extract all <td> contents
  n = 0
  tmp = $0
  while (match(tmp, /<td[^>]*>([^<]*)<\/td>/)) {
    cell = substr(tmp, RSTART, RLENGTH)
    gsub(/<[^>]+>/, "", cell)
    gsub(/^ +| +$/, "", cell)
    n++
    cells[n] = cell
    tmp = substr(tmp, RSTART + RLENGTH)
  }

  if (n >= 4) {
    # Truncate long collection paths
    coll = cells[4]
    if (length(coll) > 120) {
      coll = substr(coll, 1, 120) "..."
    }
    print cells[1], cells[2], cells[3], coll
  }
}'
