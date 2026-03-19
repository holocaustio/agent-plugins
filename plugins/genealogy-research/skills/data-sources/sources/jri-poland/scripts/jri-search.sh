#!/usr/bin/env bash
# JRI-Poland Two-Step Search — searches JRI-Poland vital records databases
# Usage: jri-search.sh SURNAME [TOWN] [GIVEN_NAME] [RECORD_TYPE] [MATCH_TYPE]
#   SURNAME     - required
#   TOWN        - optional town name (default: empty = all towns)
#   GIVEN_NAME  - optional given name (default: empty)
#   RECORD_TYPE - optional: ""=All, B=Births, M=Marriages, D=Deaths,
#                 V=Divorces, H=Holocaust (default: "" for All)
#   MATCH_TYPE  - optional surname match: E=exact, D=DM soundex,
#                 Q=phonetic, S=starts with (default: E)
#
# Two-step process:
#   1. POST to jriplform.php — gets summary with hidden form fields
#   2. POST to jridetail_2.php — gets actual detail records
#
# Outputs raw HTML (detail page) to stdout.
# Pipe to jri-parse.sh for structured output.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
JG_SCRIPTS="$(cd "$SCRIPT_DIR/../../jewishgen/scripts" && pwd)"
source "$JG_SCRIPTS/jg-throttle.sh"

UA="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36"
COOKIE_JAR="/tmp/jg_cookies.txt"

SURNAME="${1:?Usage: jri-search.sh SURNAME [TOWN] [GIVEN_NAME] [RECORD_TYPE] [MATCH_TYPE]}"
TOWN="${2:-}"
GIVEN_NAME="${3:-}"
RECORD_TYPE="${4:-}"
MATCH_TYPE="${5:-E}"

if [[ ! -f "$COOKIE_JAR" ]]; then
  echo "ERROR: Cookie jar not found. Run jg-login.sh first." >&2
  exit 1
fi

# --- Step 1: Summary search ---
echo "  [jri] Step 1: searching JRI-Poland for '${SURNAME}'..." >&2

STEP1_ARGS=(
  -sS -L
  -c "$COOKIE_JAR" -b "$COOKIE_JAR"
  -H "User-Agent: $UA"
  -H "Content-Type: application/x-www-form-urlencoded"
  -H "Origin: https://legacy.jri-poland.org"
  -H "Referer: https://legacy.jri-poland.org/databases/"
  "https://legacy.jri-poland.org/databases/jriplform.php"
  --data-urlencode "srch1=${SURNAME}"
  --data-urlencode "srch1v=S"
  --data-urlencode "srch1t=${MATCH_TYPE}"
  --data-urlencode "srch4="
  --data-urlencode "srch4v="
  --data-urlencode "srch4t="
  --data-urlencode "SrchBOOL=AND"
  --data-urlencode "rectype=${RECORD_TYPE}"
  --data-urlencode "dates=all"
  --data-urlencode "new_wind=N"
  --data-urlencode "singleline=Y"
  --data-urlencode "APICALL=!!JG!!YV!!AGD!!"
)

if [[ -n "$TOWN" ]]; then
  STEP1_ARGS+=(
    --data-urlencode "srch2=${TOWN}"
    --data-urlencode "srch2v=T"
    --data-urlencode "srch2t=E"
  )
else
  STEP1_ARGS+=(
    --data-urlencode "srch2="
    --data-urlencode "srch2v=T"
    --data-urlencode "srch2t=E"
  )
fi

if [[ -n "$GIVEN_NAME" ]]; then
  STEP1_ARGS+=(
    --data-urlencode "srch3=${GIVEN_NAME}"
    --data-urlencode "srch3v=G"
    --data-urlencode "srch3t=E"
  )
else
  STEP1_ARGS+=(
    --data-urlencode "srch3="
    --data-urlencode "srch3v=G"
    --data-urlencode "srch3t=E"
  )
fi

throttle_request
STEP1_HTML=$(curl "${STEP1_ARGS[@]}")

# Check for "no records" or error
if echo "$STEP1_HTML" | LC_ALL=C grep -qi "no records found\|0 records found\|No matches"; then
  echo "  [jri] No records found for '${SURNAME}'." >&2
  echo "$STEP1_HTML"
  exit 0
fi

# --- Extract hidden form fields from step 1 response ---
# The summary page contains a form (id=fm1) that posts to jridetail_2.php.
# Extract ALL name/value pairs from input tags inside that form.
# Attribute order varies (name before value, or vice versa), and type
# can appear anywhere in the tag. We use awk for robust extraction.

ALL_FIELDS=$(echo "$STEP1_HTML" | tr '>' '\n' | grep -i 'type=.hidden' | \
  LC_ALL=C sed -E "s/.*name=['\"]([^'\"]+)['\"].*value=['\"]([^'\"]*)['\"].*/\1=\2/" | \
  grep -v '<' | sort -u | grep -v '^$' || true)

# Also try reversed attribute order (value before name)
ALL_FIELDS2=$(echo "$STEP1_HTML" | tr '>' '\n' | grep -i 'type=.hidden' | \
  LC_ALL=C sed -E "s/.*value=['\"]([^'\"]*)['\"].*name=['\"]([^'\"]+)['\"].*/\2=\1/" | \
  grep -v '<' | sort -u | grep -v '^$' || true)

ALL_FIELDS=$(printf '%s\n%s' "$ALL_FIELDS" "$ALL_FIELDS2" | sort -u | grep -v '^$' || true)

if [[ -z "$ALL_FIELDS" ]]; then
  echo "  [jri] WARNING: Could not extract hidden form fields from step 1. Outputting summary page." >&2
  echo "$STEP1_HTML"
  exit 0
fi

# Check if gub field is present (key indicator of valid results)
GUB=$(echo "$ALL_FIELDS" | grep '^gub=' | head -1 | cut -d= -f2- || true)
if [[ -n "$GUB" ]]; then
  echo "  [jri] Found gubernia code: ${GUB}" >&2
fi

# --- Step 2: Detail records ---
echo "  [jri] Step 2: fetching detail records..." >&2

STEP2_ARGS=(
  -sS -L
  -c "$COOKIE_JAR" -b "$COOKIE_JAR"
  -H "User-Agent: $UA"
  -H "Content-Type: application/x-www-form-urlencoded"
  -H "Origin: https://legacy.jri-poland.org"
  -H "Referer: https://legacy.jri-poland.org/databases/jriplform.php"
  "https://legacy.jri-poland.org/databases/jridetail_2.php"
)

# Add all extracted hidden fields as POST data
while IFS='=' read -r fname fval; do
  [[ -z "$fname" ]] && continue
  STEP2_ARGS+=(--data-urlencode "${fname}=${fval}")
done <<< "$ALL_FIELDS"

throttle_request
curl "${STEP2_ARGS[@]}"
