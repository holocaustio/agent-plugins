---
name: search
description: Quick ad-hoc JewishGen search
arguments:
  - name: surname
    description: "Surname to search"
    required: true
  - name: given-name
    description: "Given name (optional)"
    required: false
  - name: region
    description: "Region code (e.g., 00austriaczech, 00poland, 0* for all)"
    required: false
  - name: match-type
    description: "Match type: E=exact, Q=phonetic, D=soundex, S=starts-with"
    required: false
---

# /search — Quick JewishGen Search

Run a quick unified search across all JewishGen databases and display results.

## Step 1: Check Authentication

```bash
grep jgcure /tmp/jg_cookies.txt 2>/dev/null
```

If not authenticated, run login first:
```bash
${CLAUDE_PLUGIN_ROOT}/skills/data-sources/sources/jewishgen/scripts/jg-login.sh
```

## Step 2: Run Unified Search

Use the provided arguments:
- `$ARGUMENTS.surname` — required
- `$ARGUMENTS.given-name` — optional (default: omitted)
- `$ARGUMENTS.region` — optional (default: `0*` for all regions)
- `$ARGUMENTS.match-type` — optional (default: `Q` for phonetic)

```bash
${CLAUDE_PLUGIN_ROOT}/skills/data-sources/sources/jewishgen/scripts/jg-unified-search.sh \
  "$ARGUMENTS.surname" \
  "${ARGUMENTS.given-name:-}" \
  "${ARGUMENTS.region:-0*}" \
  "${ARGUMENTS.match-type:-Q}" \
  > /tmp/jg_search_result.html
```

## Step 3: Parse Results

```bash
${CLAUDE_PLUGIN_ROOT}/skills/data-sources/sources/jewishgen/scripts/jg-parse-unified.sh < /tmp/jg_search_result.html
```

## Step 4: Display Results

Format the parsed output as a markdown table:

| Database | Records | df value |
|----------|---------|----------|
| ... | ... | ... |

Show:
- Total match count
- Top databases by record count
- The search parameters used (so user can refine)

Suggest next steps:
- "To drill into a specific database, I can search it with the detail script"
- "To narrow results, try adding a given name or region filter"
- "To try different matching, use E (exact), D (soundex), or S (starts-with)"
