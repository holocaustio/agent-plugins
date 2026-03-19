# JewishGen Database Access

The primary source for Jewish genealogy research — 80+ sub-databases covering births, marriages, deaths, Holocaust records, burial registries, and emigration records.

## Authentication (Auth0 Flow)

JewishGen uses Auth0 for authentication. Requires `$JG_USER` and `$JG_PASS` environment variables.

**Login script:** `${CLAUDE_PLUGIN_ROOT}/skills/data-sources/sources/jewishgen/scripts/jg-login.sh`

The script performs a 4-step Auth0 flow:
1. Clear old cookies, fetch Auth0 login page
2. Extract `state` token from HTML form
3. POST credentials to `login.jewishgen.org/u/login`
4. Follow redirect chain to complete session

**Cookie file:** `/tmp/jg_cookies.txt` — used by all subsequent requests. Sessions last a few hours.

**Verification:** `grep jgcure /tmp/jg_cookies.txt` — must return a line with user info.

**If session expires:** Re-run the login script. Signs: HTTP redirects to login page, or empty/error responses.

## Two Search Levels

### 1. Unified Search — Survey all databases

**Endpoint:** POST `https://www.jewishgen.org/databases/jgform.php`

Searches ALL JewishGen databases at once. Returns an HTML page listing which sub-databases have matches and how many records each contains.

**Script:** `${CLAUDE_PLUGIN_ROOT}/skills/data-sources/sources/jewishgen/scripts/jg-unified-search.sh SURNAME [GIVEN] [REGION] [MATCH_TYPE]`

**Parse results with:** `${CLAUDE_PLUGIN_ROOT}/skills/data-sources/sources/jewishgen/scripts/jg-parse-unified.sh < response.html`

Output: tab-separated lines of `df_value\tdatabase_name\trecord_count`

### 2. Detail Search — Drill into one database

**Endpoint:** POST `https://www.jewishgen.org/databases/jgdetail_2.php`

Searches within a single sub-database identified by its `df` value. Returns actual records as HTML tables.

**Script:** `${CLAUDE_PLUGIN_ROOT}/skills/data-sources/sources/jewishgen/scripts/jg-detail-search.sh DF SURNAME [GIVEN] [MATCH_TYPE] [RECSTART]`

### 3. Parent-Name Search — Find all children of a parent

**Script:** `${CLAUDE_PLUGIN_ROOT}/skills/data-sources/sources/jewishgen/scripts/jg-parent-search.sh SURNAME FATHER_GIVEN [REGION] [MATCH_TYPE]`

Searches `surname + father's given name` to find ALL children registered under that parent in one query. This is the key tool for climbing the tree recursively.

### Search Field Quick Reference

Up to 4 search terms (`srch1`–`srch4`), each with three sub-parameters:

| Sub-param | Purpose | Common values |
|-----------|---------|---------------|
| `srchNv` | Field type | `S`=Surname, `G`=Given, `T`=Town, `X`=Any |
| `srchNt` | Match type | `E`=Exact, `Q`=Phonetic, `D`=Soundex, `S`=StartsWith, `F1`/`F2`/`FM`=Fuzzy |

**Default match types:** Surname→`Q`, Given→`D`, Town→`Q`

See `${CLAUDE_PLUGIN_ROOT}/skills/data-sources/sources/jewishgen/references/url-parameters.md` for complete tables.

## Rate Limiting & Session Safety

**Built-in throttle:** Both search scripts automatically enforce delays via `jg-throttle.sh`. You do NOT need to add manual `sleep` calls — the scripts handle it.

- **Default pace:** 3-6 second randomized delay between requests (looks more human)
- **Session limit:** Warning after 60 requests per session (configurable via `JG_MAX_REQUESTS`)
- **Never** run parallel curls sharing `/tmp/jg_cookies.txt` — corrupts sessions
- Run searches **sequentially** — the throttle handles timing, but calls must still be serial
- **Always** include User-Agent header or get HTTP 411 errors
- **Always** use `LC_ALL=C` when grepping/sed-ing HTML responses (non-UTF8 bytes)
- **If you get a "Technical Problem" page** (bot detection), STOP immediately — do not retry. The IP has been flagged. Wait at least 30 minutes or use the JewishGen website manually to unblock.

**Tuning (env vars):**
- `JG_MIN_DELAY=3` — minimum seconds between requests
- `JG_MAX_DELAY=6` — maximum seconds between requests
- `JG_MAX_REQUESTS=60` — warning threshold per session

## HTML Parsing Patterns

See `${CLAUDE_PLUGIN_ROOT}/skills/data-sources/sources/jewishgen/references/html-parsing.md` for regex patterns.

**Unified results key patterns:**
- Total count: `<H2>N total matches found</H2>`
- Each database: `<input name='df' value='DB_ID' type='hidden'>` with `value='List N records'`

**Detail results key patterns:**
- Match count: `N matching records found`
- Records in `<TABLE>` with `BGCOLOR=#E8E1D1`
- Column headers vary per database type (births vs deaths vs marriages)

## Database Catalog

See `${CLAUDE_PLUGIN_ROOT}/skills/data-sources/sources/jewishgen/references/database-catalog.md` for a complete list of databases by region with their `df` values.

Database IDs (`df`) come in two formats:
- **UUID:** `25c41f2b-6ad9-4063-912b-db4a81061009`
- **Short code:** `VIENNADEATH`, `J_AUSTRIA`, `USCINTERV`

New database IDs are discovered by running a unified search and parsing `df` values from the result HTML.

## Gotchas

1. **User-Agent required** — server returns HTTP 411 or "Technical Problem" without it
2. **Cookie file corruption** — parallel curls on same file = broken session
3. **Non-UTF8 HTML** — always `LC_ALL=C` for text processing
4. **Session expiry** — re-authenticate every few hours
5. **Pagination** — detail results show ~20 records; use `recstart=N` for more
6. **External databases** — some results (Yad Vashem, IGRA) link to external sites with different APIs
