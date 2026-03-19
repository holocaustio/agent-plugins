#!/usr/bin/env bash
# JewishGen Detail Search — searches ONE specific database
# Usage: jg-detail-search.sh DF SURNAME [GIVEN] [MATCH_TYPE] [RECSTART]
#   DF         - required database ID (UUID or short code)
#   SURNAME    - required
#   GIVEN      - optional given name
#   MATCH_TYPE - optional match type for surname (default: E)
#   RECSTART   - optional pagination offset (default: 0)
# Outputs raw HTML to stdout.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/jg-throttle.sh"

UA="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36"
COOKIE_JAR="/tmp/jg_cookies.txt"

DF="${1:?Usage: jg-detail-search.sh DF SURNAME [GIVEN] [MATCH_TYPE] [RECSTART]}"
SURNAME="${2:?Usage: jg-detail-search.sh DF SURNAME [GIVEN] [MATCH_TYPE] [RECSTART]}"
GIVEN="${3:-}"
MATCH_TYPE="${4:-E}"
RECSTART="${5:-0}"

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
  "https://www.jewishgen.org/databases/jgdetail_2.php"
  --data-urlencode "df=${DF}"
  --data-urlencode "georegion=0*"
  --data-urlencode "srch1=${SURNAME}"
  --data-urlencode "srch1v=S"
  --data-urlencode "srch1t=${MATCH_TYPE}"
  --data-urlencode "srchbool=AND"
  --data-urlencode "dates=all"
  --data-urlencode "newwindow=0"
  --data-urlencode "recstart=${RECSTART}"
  --data-urlencode "recjump=0"
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
