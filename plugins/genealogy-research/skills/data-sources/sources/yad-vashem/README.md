# Yad Vashem Names Database

**No authentication required.** JSON API, no cookies needed.

## Base URL
`https://yv360.yadvashem.org/api`

## Search: POST /Search/GetDataResultsWithBuildQuery

Query params: `?lang=en&cardType=namesCard&pageNumber=1&pageSize=25`

### Search by last name
```bash
curl -s -X POST "https://yv360.yadvashem.org/api/Search/GetDataResultsWithBuildQuery?lang=en&cardType=namesCard&pageNumber=1&pageSize=25" \
  -H "Content-Type: application/json" \
  -d '{"dataToQuery":[{"fieldsNames":["last_name_search_en","maiden_name_search_en"],"valueToSearch":"SURNAME","searchType":"yvSynonym","useLang":true,"queryOperator":1}],"filters":{"filters":[],"logicOperator":0},"queryOperator":0}'
```

### Search by name + birthplace + birth year
```bash
curl -s -X POST "https://yv360.yadvashem.org/api/Search/GetDataResultsWithBuildQuery?lang=en&cardType=namesCard&pageNumber=1&pageSize=50" \
  -H "Content-Type: application/json" \
  -d '{"dataToQuery":[{"fieldsNames":["last_name_search_en","maiden_name_search_en"],"valueToSearch":"SURNAME","searchType":"yvSynonym","useLang":true,"queryOperator":1},{"fieldsNames":["place_birth_search_en","place_permanent_search_en"],"valueToSearch":"PLACE","searchType":"yvSynonym","useLang":true,"queryOperator":1},{"fieldsNames":["year_birth_search"],"valueToSearch":"YEAR","searchType":"rangeFive","useLang":false,"queryOperator":0}],"filters":{"filters":[],"logicOperator":0},"queryOperator":0}'
```

### Searchable fields
| Field | useLang | Notes |
|-------|---------|-------|
| `last_name_search_en` | true | Surname |
| `first_name_search_en` | true | Given name |
| `maiden_name_search_en` | true | Maiden name |
| `year_birth_search` | false | Birth year |
| `year_death_search` | false | Death year |
| `place_birth_search_en` | true | Birthplace |
| `place_permanent_search_en` | true | Permanent residence |
| `place_war_search_en` | true | Place during war |
| `place_death_search_en` | true | Place of death |
| `father_first_name_search_en` | true | Father's first name |
| `mother_first_name_search_en` | true | Mother's first name |
| `mother_maiden_name_search_en` | true | Mother's maiden name |
| `spouse_first_name_search_en` | true | Spouse's first name |

### Search types
| Type | Use for |
|------|---------|
| `yvSynonym` | Default — handles name variants (Berta/Bertha) |
| `exactly` | Exact match (years) |
| `rangeFive` | ±5 year range (birth/death years) |
| `dmSoundex` | Phonetic matching |
| `beginsWith` | Prefix match |
| `literal` | Exact string |

### queryOperator
- `0` = AND (between search fields)
- `1` = OR (within fieldsNames array — search surname OR maiden name)

## Detail endpoints
```bash
# All linked records for one person (cluster)
curl -s "https://yv360.yadvashem.org/api/Names/GetClusterDetails?lang=en&id=RECORD_ID"

# Single full record
curl -s "https://yv360.yadvashem.org/api/Names/GetSingleFullDetails?lang=en&id=RECORD_ID&source=SOURCE_TYPE"

# Auto-generated narrative summary
curl -s "https://yv360.yadvashem.org/api/Names/GetSummary?id=RECORD_ID&lang=en"
```

Source types for GetSingleFullDetails: `pot` (Page of Testimony), historical records use their own codes.

## Response format
```json
{
  "cards": [
    {
      "id": "14303561",
      "title": "Rachel Goldberg Klein nee Goldberg",
      "firstName": "Rachel",
      "lastName": "Goldberg Klein",
      "fate": "murdered",
      "birthYear": "06/08/1863",
      "clusterNumber": 2,
      "relatedList": [{"value": "Page of Testimony"}, {"value": "List of Theresienstadt camp inmates"}]
    }
  ],
  "count": 58
}
```

## Filter by source type
Add to the filters object:
```json
{"filters":[{"fieldName":"source_en","filterType":0,"filterOperator":0,"values":["Page of Testimony"]}],"logicOperator":0}
```

## Source citation format
```
[S: database="Yad Vashem Names Database" | source="yad-vashem" | search="last_name=SURNAME&place_birth=PLACE&year_birth=YEAR" | record="SURNAME, Given | b.YEAR | PLACE | fate: murdered"]
```

## Rate limiting
No limits observed. Add 1-2 second delays between requests to be respectful.

## What you get that JewishGen doesn't have
- **Pages of Testimony** — family details submitted by survivors (parent names, siblings, addresses)
- **Cluster linking** — multiple records for same person already linked
- **Narrative summaries** — auto-generated text combining all sources
- **Father/mother/spouse searchable** — can search by parent name directly
