#!/usr/bin/env bash
# JewishGen Parent-Name Search — find all children of a known parent
# Usage: jg-parent-search.sh SURNAME PARENT_GIVEN [REGION] [MATCH_TYPE]
#   SURNAME      - required (family surname)
#   PARENT_GIVEN - required (parent's given name — searches as exact match by default)
#   REGION       - optional region code (default: 0*)
#   MATCH_TYPE   - optional match type for surname (default: Q)
#
# Key difference from jg-unified-search.sh:
#   Given name uses srch2t=E (exact) not D (soundex), because vital record
#   indexes store father's given name as an exact entry. Soundex would return
#   too many false matches for parent-name searches.
#
# Outputs raw HTML to stdout. Pipe to jg-parse-unified.sh for structured output.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/jg-throttle.sh"

UA="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36"
COOKIE_JAR="/tmp/jg_cookies.txt"

SURNAME="${1:?Usage: jg-parent-search.sh SURNAME PARENT_GIVEN [REGION] [MATCH_TYPE]}"
PARENT_GIVEN="${2:?Usage: jg-parent-search.sh SURNAME PARENT_GIVEN [REGION] [MATCH_TYPE]}"
REGION="${3:-0*}"
MATCH_TYPE="${4:-Q}"

if [[ ! -f "$COOKIE_JAR" ]]; then
  echo "ERROR: Cookie jar not found. Run jg-login.sh first." >&2
  exit 1
fi

# Build curl args — note srch2t=E (exact) for parent given name
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
  --data-urlencode "srch2=${PARENT_GIVEN}"
  --data-urlencode "srch2v=G"
  --data-urlencode "srch2t=E"
  --data-urlencode "SrchBOOL=AND"
  --data-urlencode "GeoRegion=${REGION}"
  --data-urlencode "dates=all"
  --data-urlencode "allcountry=0*"
  --data-urlencode "submitform=submitform"
)

throttle_request
curl "${CURL_ARGS[@]}"
