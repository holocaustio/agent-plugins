# Arolsen Archives — Holocaust Records

Searches the Arolsen Archives collections for name references. Returns archive catalog entries showing which card file segments contain potential matches.

**No authentication required.** Uses headless browser (Playwright).

## Script

`${CLAUDE_PLUGIN_ROOT}/skills/data-sources/sources/arolsen/scripts/arolsen-search.sh`

```bash
arolsen-search.sh SURNAME [GIVEN_NAME]
```

| Arg | Default | Purpose |
|-----|---------|---------|
| SURNAME | required | Family name |
| GIVEN_NAME | omitted | First name |

**Output:** Tab-separated: `REFERENCE\tRELEVANCE\tSEGMENT\tCOLLECTION`

## Important

Results are finding aid pointers — they tell you WHERE in the archive to look. For actual person details (names, birth dates, camp records), visit the documents on `collections.arolsen-archives.org`.

## Tips

- Higher relevance scores (closer to 1.0) indicate stronger matches
- Use reference numbers to navigate directly to documents on the Arolsen website
- The Central Name Index is the primary index for person searches

## Source citation format

```
[S: database="Arolsen Archives" | source="arolsen" | search="SURNAME GIVEN" | record="REF | relevance: SCORE | segment: SEG | collection: COL"]
```
