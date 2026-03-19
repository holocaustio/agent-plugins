#!/usr/bin/env bash
# Search Geni.com profiles by name.
# Outputs JSON results to stdout.
#
# Usage: geni-search.sh SURNAME [GIVEN_NAME] [--page N]
#
# Examples:
#   geni-search.sh Plaschkes
#   geni-search.sh Plaschkes Leopold
#   geni-search.sh "Plaschkes" "Leopold" --page 2

set -euo pipefail

TOKEN_FILE="/tmp/geni_token.txt"

if [[ -z "${GENI_TOKEN:-}" ]]; then
    if [[ -f "$TOKEN_FILE" ]]; then
        GENI_TOKEN=$(cat "$TOKEN_FILE")
    else
        echo "ERROR: No Geni token. Run: source geni-login.sh" >&2
        exit 1
    fi
fi

SURNAME="${1:?Usage: geni-search.sh SURNAME [GIVEN_NAME] [--page N]}"
GIVEN="${2:-}"
PAGE=""

# Parse optional --page flag
shift; shift 2>/dev/null || true
while [[ $# -gt 0 ]]; do
    case "$1" in
        --page) PAGE="$2"; shift 2 ;;
        *) shift ;;
    esac
done

# Build names query
if [[ -n "$GIVEN" && "$GIVEN" != --* ]]; then
    NAMES=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$GIVEN $SURNAME'))")
else
    NAMES=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$SURNAME'))")
fi

URL="https://www.geni.com/api/profile/search?names=${NAMES}&access_token=${GENI_TOKEN}"
if [[ -n "$PAGE" ]]; then
    URL="${URL}&page=${PAGE}"
fi

echo "Searching Geni for: ${GIVEN:+$GIVEN }${SURNAME}${PAGE:+ (page $PAGE)}" >&2

RESPONSE=$(curl -sS -w '\n---HEADERS---\n%{header_json}' "$URL")

# Split response body and headers
BODY=$(echo "$RESPONSE" | sed '/^---HEADERS---$/,$d')
HEADERS=$(echo "$RESPONSE" | sed -n '/^---HEADERS---$/,$p' | tail -n +2)

# Check rate limit
REMAINING=$(echo "$HEADERS" | python3 -c "
import sys, json
try:
    h = json.load(sys.stdin)
    print(h.get('x-api-rate-remaining', ['?'])[0])
except: print('?')
" 2>/dev/null || echo "?")

if [[ "$REMAINING" != "?" ]] && (( REMAINING < 5 )); then
    WINDOW=$(echo "$HEADERS" | python3 -c "
import sys, json
try:
    h = json.load(sys.stdin)
    print(h.get('x-api-rate-window', ['60'])[0])
except: print('60')
" 2>/dev/null || echo "60")
    echo "WARNING: Rate limit low (${REMAINING} remaining). Sleeping ${WINDOW}s..." >&2
    sleep "$WINDOW"
fi

# Check for error response
if echo "$BODY" | python3 -c "import sys,json; d=json.load(sys.stdin); sys.exit(0 if 'error' in d else 1)" 2>/dev/null; then
    ERROR=$(echo "$BODY" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('error',{}).get('message', d.get('error','unknown')))")
    echo "ERROR: Geni API error: $ERROR" >&2
    exit 1
fi

# Output results
echo "$BODY"

# Summary to stderr
COUNT=$(echo "$BODY" | python3 -c "
import sys, json
d = json.load(sys.stdin)
results = d.get('results', [])
print(len(results))
" 2>/dev/null || echo "?")

HAS_NEXT=$(echo "$BODY" | python3 -c "
import sys, json
d = json.load(sys.stdin)
print('yes' if d.get('next_page') else 'no')
" 2>/dev/null || echo "?")

echo "Results on this page: ${COUNT}. More pages: ${HAS_NEXT}. Rate remaining: ${REMAINING}" >&2
