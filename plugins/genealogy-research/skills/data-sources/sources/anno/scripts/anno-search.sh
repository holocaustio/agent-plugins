#!/usr/bin/env bash
# ANNO (Austrian Newspapers Online) search — finds newspaper mentions via headless browser
# Usage: anno-search.sh QUERY [FROM_YEAR] [TO_YEAR]
#   QUERY     - required search term (use German spelling, e.g. "Goldberg")
#   FROM_YEAR - optional start year (default: 1880)
#   TO_YEAR   - optional end year (default: 1940)
# Outputs tab-separated: DATE\tNEWSPAPER\tPAGES\tHITS\tLINK
# Requires: node, playwright (npm install in project root)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BROWSER_FETCH="$SCRIPT_DIR/browser-fetch.js"

QUERY="${1:?Usage: anno-search.sh QUERY [FROM_YEAR] [TO_YEAR]}"
FROM_YEAR="${2:-1880}"
TO_YEAR="${3:-1940}"

if [[ ! -f "$BROWSER_FETCH" ]]; then
  echo "ERROR: browser-fetch.js not found at $BROWSER_FETCH" >&2
  exit 1
fi

# ANNO search URL — hash-based SPA routing
URL="https://anno.onb.ac.at/anno-suche#searchMode=simple&query=${QUERY}&from=${FROM_YEAR}&to=${TO_YEAR}"

# Fetch rendered page — wait for result rows to appear
# ANNO uses .list_row for each result entry
HTML=$(node "$BROWSER_FETCH" "$URL" \
  --wait-for ".list_row" \
  --timeout 25000 \
  --extract ".list_row" 2>/dev/null) || {
  echo "No results found for '${QUERY}' (${FROM_YEAR}-${TO_YEAR})" >&2
  exit 0
}

if [[ -z "$HTML" ]]; then
  echo "No results found for '${QUERY}' (${FROM_YEAR}-${TO_YEAR})" >&2
  exit 0
fi

# Parse result rows — each .list_row contains:
#   .entry_title > a  — "Newspaper Name DD. Month YYYY" + href to ANNO issue
#   .entry_txt        — "Zeitung\nCity - Language - N Seiten\nN Treffer im Text"
echo "$HTML" | LC_ALL=C awk '
BEGIN { OFS="\t" }
{
  # Extract newspaper title + date from entry_title link text
  # Format: " Newspaper Name DD. Month YYYY "
  title_date = ""
  if (match($0, /class="entry_title"[^>]*>[^<]*<a[^>]*> *([^<]+) *<\/a>/)) {
    # Get the link text
    tmp = substr($0, RSTART, RLENGTH)
    if (match(tmp, /> [^<]+ <\/a>/)) {
      title_date = substr(tmp, RSTART+1, RLENGTH-6)
      gsub(/^ +| +$/, "", title_date)
    }
  }

  # Extract ANNO link
  link = ""
  if (match($0, /href="(http[^"]*onb\.ac\.at[^"]*)"/)) {
    link = substr($0, RSTART+6, RLENGTH-7)
  }

  # Extract page count from "N Seiten"
  pages = ""
  if (match($0, /[0-9]+ Seiten/)) {
    pages = substr($0, RSTART, RLENGTH)
  }

  # Extract hit count from "N Treffer im Text"
  hits = ""
  if (match($0, /[0-9]+ Treffer/)) {
    hits = substr($0, RSTART, RLENGTH)
  }

  if (title_date != "") {
    print title_date, pages, hits, link
  }
}'
