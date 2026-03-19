#!/usr/bin/env bash
# Parse JewishGen Unified Search HTML
# Reads HTML from stdin, outputs tab-separated: df_value\tdatabase_name\trecord_count
# Usage: cat response.html | jg-parse-unified.sh
#    or: jg-unified-search.sh SURNAME | jg-parse-unified.sh
# Compatible with macOS default grep/awk (no GNU extensions required).

set -euo pipefail

# Read all input, force text mode for any binary-like bytes
HTML=$(LC_ALL=C cat)

# Print total count
TOTAL=$(echo "$HTML" | LC_ALL=C grep -aoE '[0-9][0-9,]+ total matches found' | head -1 || true)
if [[ -n "$TOTAL" ]]; then
  echo "# $TOTAL" >&2
fi

# Extract Yad Vashem external link count (separate format from JG databases)
YV_COUNT=$(echo "$HTML" | LC_ALL=C grep -aoE 'List [0-9,]+  ?records from the YadVashem' | LC_ALL=C grep -aoE '[0-9,]+' | head -1 || true)
if [[ -n "$YV_COUNT" ]]; then
  echo "YADVASHEM	Yad Vashem Central Database of Shoah Victims' Names	${YV_COUNT//,/}"
fi

# Extract FTJP (Family Trees) count — uses a different form format (query1FTJP)
FTJP_COUNT=$(echo "$HTML" | LC_ALL=C grep -aoE "query1FTJP" >/dev/null 2>&1 && \
  echo "$HTML" | LC_ALL=C grep -aoE "List [0-9,]+ records" | head -1 | LC_ALL=C grep -aoE '[0-9,]+' | head -1 || true)
if [[ -n "$FTJP_COUNT" ]]; then
  echo "FTJP	Family Tree of the Jewish People	${FTJP_COUNT//,/}"
fi

# Extract standard JG database entries
# Strategy: split HTML on <TR boundaries, find rows with df input fields,
# extract database name from <a> link, df value, and record count from submit button
echo "$HTML" | LC_ALL=C awk '
BEGIN { RS = "<TR|<tr" }
{
  # Skip rows without df field
  if (index($0, "name=\047df\047") == 0) next

  # Extract df value: name='\''df'\'' value='\''XXX'\''
  df = ""
  s = $0
  idx = index(s, "name=\047df\047 value=\047")
  if (idx > 0) {
    s = substr(s, idx + 17)
    end = index(s, "\047")
    if (end > 0) df = substr(s, 1, end - 1)
  }
  if (df == "") next

  # Extract record count from submit button: value='\''List N record(s)'\''
  count = ""
  s = $0
  idx = index(s, "value=\047List ")
  if (idx > 0) {
    s = substr(s, idx + 12)
    end = index(s, " record")
    if (end > 0) {
      count = substr(s, 1, end - 1)
      gsub(/,/, "", count)
    }
  }
  if (count == "" || count + 0 == 0) next

  # Extract database name from <a> link text
  name = ""
  s = $0
  # Find the <a href=...> tag (database name link comes before the form)
  while (1) {
    idx = index(s, "<a href=")
    if (idx == 0) {
      idx = index(s, "<A HREF=")
    }
    if (idx == 0) break
    s = substr(s, idx + 1)
    # Find closing >
    gt = index(s, ">")
    if (gt == 0) break
    rest = substr(s, gt + 1)
    # Find </a> or </A>
    endtag = index(rest, "</a>")
    if (endtag == 0) endtag = index(rest, "</A>")
    if (endtag > 0 && endtag < 200) {
      candidate = substr(rest, 1, endtag - 1)
      # Remove any nested HTML tags
      gsub(/<[^>]*>/, "", candidate)
      # Remove leading/trailing whitespace
      gsub(/^[ \t\n]+/, "", candidate)
      gsub(/[ \t\n]+$/, "", candidate)
      if (candidate != "" && length(candidate) > 3) {
        name = candidate
      }
    }
    s = rest
  }
  if (name == "") name = "Unknown"

  print df "\t" name "\t" count
}
'
