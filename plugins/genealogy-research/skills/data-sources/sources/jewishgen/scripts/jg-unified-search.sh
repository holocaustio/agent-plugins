#!/usr/bin/env bash
# JewishGen Unified Search — searches ALL databases
# Usage: jg-unified-search.sh SURNAME [GIVEN] [REGION] [MATCH_TYPE]
#   SURNAME    - required
#   GIVEN      - optional given name (default: omitted)
#   REGION     - optional region code (default: 0*)
#   MATCH_TYPE - optional match type for surname (default: Q)
# Outputs raw HTML to stdout. Pipe to jg-parse-unified.sh for structured output.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/jg-throttle.sh"

UA="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36"
COOKIE_JAR="/tmp/jg_cookies.txt"

SURNAME="${1:?Usage: jg-unified-search.sh SURNAME [GIVEN] [REGION] [MATCH_TYPE]}"
GIVEN="${2:-}"
REGION="${3:-0*}"
MATCH_TYPE="${4:-Q}"

if [[ ! -f "$COOKIE_JAR" ]]; then
  echo "ERROR: Cookie jar not found. Run jg-login.sh first." >&2
  exit 1
fi

# Build curl args using --data-urlencode for proper encoding (0* -> 0%2A)
CURL_ARGS=(
  -sS -L
  -c "$COOKIE_JAR" -b "$COOKIE_JAR"
  -H "User-Agent: $UA"
  -H "Content-Type: application/x-www-form-urlencoded"
  -H "Origin: https://www.jewishgen.org"
  -H "Referer: https://www.jewishgen.org/databases/"
  "https://www.jewishgen.org/databases/jgform.php"
  --data-urlencode "srch1=${SURNAME}"
  --data-urlencode "srch1v=S"
  --data-urlencode "srch1t=${MATCH_TYPE}"
  --data-urlencode "SrchBOOL=AND"
  --data-urlencode "GeoRegion=${REGION}"
  --data-urlencode "dates=all"
  --data-urlencode "allcountry=0*"
  --data-urlencode "submitform=submitform"
)

if [[ -n "$GIVEN" ]]; then
  CURL_ARGS+=(
    --data-urlencode "srch2=${GIVEN}"
    --data-urlencode "srch2v=G"
    --data-urlencode "srch2t=D"
  )
fi

throttle_request
curl "${CURL_ARGS[@]}"
