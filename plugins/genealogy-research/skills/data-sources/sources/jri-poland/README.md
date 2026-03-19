# JRI-Poland (Jewish Records Indexing - Poland)

Indexed vital records from Polish archives: births, marriages, deaths, divorces, and Holocaust-era records. Covers hundreds of towns across historical Poland (including areas now in Ukraine, Belarus, Lithuania).

## Authentication

Uses JewishGen cookies — run `jg-login.sh` first. The shared cookie jar at `/tmp/jg_cookies.txt` works for JRI-Poland too.

## Scripts

### jri-search.sh — Two-Step Search

Performs the full search workflow: summary query + detail record fetch.

```bash
# Surname only (exact match, all record types)
jri-search.sh PLASCHKES

# Surname + town
jri-search.sh PLASCHKES Krakow

# Surname + town + given name
jri-search.sh PLASCHKES "" Abraham

# Birth records only, DM soundex match
jri-search.sh PLASCHKES "" "" B D

# Full pipeline: search and parse
jri-search.sh PLASCHKES | jri-parse.sh
```

**Arguments:**
| Arg | Required | Default | Description |
|-----|----------|---------|-------------|
| SURNAME | Yes | — | Family name to search |
| TOWN | No | empty (all) | Town name filter |
| GIVEN_NAME | No | empty | Given/first name filter |
| RECORD_TYPE | No | "" (All) | B=Births, M=Marriages, D=Deaths, V=Divorces, H=Holocaust |
| MATCH_TYPE | No | E (exact) | E=exact, D=DM soundex, Q=phonetic, S=starts with |

**Output:** Raw HTML to stdout. Status messages to stderr.

### jri-parse.sh — Parse Detail Records

Parses JRI-Poland detail HTML into clean TSV format.

```bash
jri-search.sh PLASCHKES | jri-parse.sh
```

**Output columns (TSV):**
```
Surname  GivenName  Year  Type  Akt  Page  Sex  DOB  Father  FatherSurname  Mother  MotherSurname  Comments
```

## Concurrency

**SERIAL only** — shares JewishGen's cookie jar. Never run parallel searches. The script auto-throttles via `jg-throttle.sh` (3-6s randomized delays between requests).

## Tips

- JRI-Poland covers historical Poland which extends well beyond modern borders
- Record coverage varies greatly by town — some have records from 1808, others start much later
- DM soundex (`D`) is useful for Polish surname spelling variations
- Birth records (`B`) are the most common type indexed
- The `Akt` number is the official record number in the civil register — use it for ordering copies
- `Sygnatura` is the archive signature — identifies the specific register volume
