# JewishGen URL Parameter Reference

## Endpoints

| Endpoint | Purpose |
|----------|---------|
| `https://www.jewishgen.org/databases/jgform.php` | Unified search (POST) |
| `https://www.jewishgen.org/databases/jgdetail_2.php` | Sub-database detail (POST or GET) |

## Search Fields (srch1–srch4)

Up to 4 search terms can be combined. Each term has three sub-parameters:

| Parameter | Description | Values |
|-----------|-------------|--------|
| `srch1`–`srch4` | Search term text | Any string (e.g., `GOLDBERG`) |
| `srch1v`–`srch4v` | Field type (what to search) | `S` = Surname, `G` = Given Name, `T` = Town, `X` = Any Field |
| `srch1t`–`srch4t` | Match type (how to match) | See Match Types table |

## Match Types

| Code | Name | Description | Best for |
|------|------|-------------|----------|
| `Q` | Phonetically Like | Beider-Morse Phonetic Matching | Surnames (default) |
| `D` | Sounds Like | Daitch-Mokotoff Soundex | Given names (default) |
| `S` | Starts with | Prefix match | Partial name fragments |
| `E` | is Exactly | Exact match | Confirmation searches |
| `F1` | Fuzzy Match | Slight fuzzy matching | Minor OCR errors |
| `F2` | Fuzzier Match | More fuzzy matching | Moderate variations |
| `FM` | Fuzziest Match | Maximum fuzzy matching | Desperate searches |

**Default match types by field:**
- Surname → `Q` (Phonetically Like)
- Given Name → `D` (Sounds Like)
- Town → `Q` (Phonetically Like)

**Strategy:** Start with `Q` for discovery, narrow with `E` for confirmation.

## Boolean & Filters

| Parameter | Description | Values |
|-----------|-------------|--------|
| `SrchBOOL` / `srchbool` | Combine search terms | `AND`, `OR` |
| `GeoRegion` / `georegion` | Geographic region filter | See region codes |
| `dates` | Date filter | `all` = all entries, `some` = filter by date added |
| `allcountry` | Country filter (unified only) | `0*` = all countries |
| `submitform` | Required for unified POST | `submitform` |

## Database ID (`df`)

Identifies a specific sub-database for detail searches. Two formats:
- **UUID:** `25c41f2b-6ad9-4063-912b-db4a81061009`
- **Short code:** `VIENNADEATH`, `J_AUSTRIA`, `USCINTERV`

Discovered by running a unified search and parsing the `df` values from result forms.

## Pagination

| Parameter | Description |
|-----------|-------------|
| `recstart` | Starting record index (0-based) |
| `recjump` | Jump to record index |

Default page size is ~20 records. Use `recstart=20`, `recstart=40`, etc. to page through.

## Geographic Region Codes

### Major Regions

| Code | Region |
|------|--------|
| `0*` | All Regions (worldwide) |
| `00austriaczech` | Austria-Czech |
| `00germany` | Germany |
| `00hungary` | Hungary |
| `00poland` | Poland |
| `00romania` | Romania |
| `00lithuania` | Lithuania |
| `00ukraine` | Ukraine |
| `00belarus` | Belarus |
| `00latvia` | Latvia |
| `00israel` | Israel |
| `00uk` | United Kingdom |
| `00usa` | United States |
| `00canada` | Canada |
| `00france` | France |
| `00scandinavia` | Scandinavia |
| `00LatinAmerica` | Latin America |

### Special Categories

| Code | Category |
|------|----------|
| `01holocaust` | Holocaust databases |
| `01jowbr` | Burial Registry |
| `01memorial` | Memorial Plaques |
| `01necrology` | Necrology |

### Sub-regions

Sub-regions use underscore suffix:
- `00romania_01banat` — Banat region of Romania
- `00usa_01NY` — New York, USA
- `00poland_01galicia` — Galicia region

## Search Text Tricks

- **Comma-separated = OR:** `COHEN,GOLDBERG` searches for either surname
- **Space-separated = AND:** `COHEN GOLDBERG` requires both terms in the record
- **Uppercase recommended:** JewishGen normalizes, but uppercase is conventional

## Parent-Name Search Parameters

Uses the given name field for the **parent's** given name. Critical difference:
`srch2t=E` (exact) rather than `srch2t=D` (soundex).

```
srch1=SURNAME       srch1v=S  srch1t=Q    (family surname)
srch2=PARENT_GIVEN  srch2v=G  srch2t=E    (parent's given name, EXACT)
```

**Script:** `jg-parent-search.sh SURNAME PARENT_GIVEN [REGION] [MATCH_TYPE]`

For when to use parent-name search vs person search, see
`research-methodology/references/deduction-techniques.md` ("Parent-Name Reverse Lookup").
