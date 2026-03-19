# tree.json — Machine-Readable Schema

## Purpose

Structured data for programmatic access to the family tree. Three layers:
1. **Persons** — every individual with their facts and linked IDs
2. **Sources** — a bibliography of every record consulted, with retraceable search parameters
3. **Claims** — every relationship claim backed by explicit evidence chains

This enables queries like "prove X is father of Y" and "show me all sources for person X".

## Schema

```json
{
  "meta": {
    "target_person": "P001",
    "title": "SURNAME Family Tree",
    "origin": "Primary origin town/region",
    "last_updated": "YYYY-MM-DD"
  },

  "sources": {
    "S001": {
      "id": "S001",
      "database": "Vienna Births Enhanced",
      "df": "737d56d4-7872-4aba-aac3-39f3abf1dfd1",
      "search": "srch1=GOLDBERG&srch1v=S&srch1t=E&srch2=ABRAHAM&srch2v=G&srch2t=E",
      "record": "GOLDBERG, Abraham | 1884-03-13 | Father: Marcus | Mother: LEVY, Sarah | Vienna",
      "accessed": "2026-02-22",
      "persons_mentioned": ["P001", "P010", "P011"]
    },
    "S002": {
      "id": "S002",
      "database": "Vienna Marriages Enhanced",
      "df": "97e526a9-56ef-4c1f-94b3-1dc770983ee9",
      "search": "srch1=GOLDBERG&srch1v=S&srch1t=E&srch2=MARCUS&srch2v=G&srch2t=E",
      "record": "GOLDBERG, Marcus ∞ LEVY, Sarah | 1880-06-15 | Father of groom: Jakob | Mother of groom: WEISS, Fanny",
      "accessed": "2026-02-22",
      "persons_mentioned": ["P010", "P011", "P020", "P021"]
    }
  },

  "persons": {
    "P001": {
      "id": "P001",
      "given_name": "Abraham",
      "surname": "GOLDBERG",
      "name_variants": ["GOLBERG", "GOLTBERG"],
      "sex": "M",
      "birth": {
        "date": "1884-03-13",
        "place": "Vienna, Lower Austria",
        "source_ids": ["S001"]
      },
      "death": {
        "date": "1943-09-29",
        "place": "Auschwitz",
        "source_ids": ["S015", "S016"]
      },
      "burial": null,
      "spouses": [
        {
          "person_id": "P002",
          "marriage_date": "1919-06-22",
          "marriage_place": "Vienna",
          "order": 1,
          "source_ids": ["S008"]
        }
      ],
      "children": ["P003", "P004"],
      "father_id": "P010",
      "mother_id": "P011",
      "occupation": "merchant",
      "is_direct_ancestor": true,
      "generation": 0,
      "holocaust_fate": {
        "deported_date": "1943-09-28",
        "transport": "Transport 63",
        "destination": "Auschwitz",
        "died_date": "1943-09-29",
        "died_place": "Auschwitz",
        "source_ids": ["S015", "S016"]
      },
      "emigration": null,
      "notes": "Merchant in Vienna, deported with wife",
      "gaps": ["burial record NOT FOUND"]
    }
  },

  "claims": {
    "C001": {
      "id": "C001",
      "type": "parent_child",
      "parent_id": "P010",
      "child_id": "P001",
      "evidence": [
        {
          "source_id": "S001",
          "detail": "Father column lists 'Marcus'",
          "type": "direct"
        },
        {
          "source_id": "S008",
          "detail": "Marriage record lists father as 'Marcus GOLDBERG'",
          "type": "corroborating"
        }
      ],
      "confidence": "confirmed",
      "note": "Two independent records agree — birth record and marriage record both name Marcus as father"
    },
    "C002": {
      "id": "C002",
      "type": "parent_child",
      "parent_id": "P011",
      "child_id": "P001",
      "evidence": [
        {
          "source_id": "S001",
          "detail": "Mother column lists 'LEVY, Sarah'",
          "type": "direct"
        }
      ],
      "confidence": "confirmed",
      "note": "Birth record directly names mother"
    },
    "C003": {
      "id": "C003",
      "type": "marriage",
      "person_a": "P010",
      "person_b": "P011",
      "evidence": [
        {
          "source_id": "S002",
          "detail": "Marriage record: Marcus GOLDBERG ∞ Sarah LEVY, 1880",
          "type": "direct"
        },
        {
          "source_id": "S001",
          "detail": "Abraham's birth record lists both as parents (1884, 4 years after marriage)",
          "type": "corroborating"
        }
      ],
      "confidence": "confirmed",
      "note": "Direct marriage record plus children's birth records confirm union"
    }
  },

  "direct_line": ["P001", "P010", "P020", "P030"],
  "holocaust_victims": ["P001", "P002", "P004"],
  "emigrants": {
    "israel": ["P003"],
    "usa": ["P005"]
  }
}
```

## Field Reference

### meta

| Field | Type | Description |
|-------|------|-------------|
| `target_person` | string | Person ID of the research subject |
| `title` | string | Display title for the tree |
| `origin` | string | Primary geographic origin |
| `last_updated` | string | ISO date of last update |

### sources[id] — The Bibliography

Every record consulted during research gets an entry. This is the canonical source registry.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | string | yes | Unique ID (S001, S002, ...) |
| `database` | string | yes | Human-readable database name |
| `df` | string | yes | Database ID for JewishGen API |
| `search` | string | yes | URL query parameters to reproduce the search |
| `record` | string | yes | Summary of the actual record found (key fields) |
| `accessed` | string | yes | Date the record was accessed (YYYY-MM-DD) |
| `persons_mentioned` | string[] | yes | Person IDs of everyone referenced in this record |

**Key conventions:**
- `search` contains only the query params (not the full URL) — combine with the endpoint to retrace
- `record` is a human-readable summary, not raw HTML — include the key columns separated by `|`
- `persons_mentioned` links the source to all persons it provides evidence about
- Source IDs are sequential (S001, S002, ...) in the order they were first consulted

### persons[id]

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | string | yes | Unique ID (P001, P002, ...) |
| `given_name` | string | yes | First name(s) |
| `surname` | string | yes | Family name (maiden name for women) |
| `name_variants` | string[] | no | Alternative spellings found |
| `sex` | string | yes | "M" or "F" |
| `birth` | object | no | Birth info with `source_ids` array |
| `death` | object | no | Death info with `source_ids` array |
| `burial` | object | no | Burial info with `source_ids` array |
| `spouses` | array | no | Spouse references with `source_ids` array |
| `children` | string[] | no | Person IDs of children |
| `father_id` | string | no | Person ID of father |
| `mother_id` | string | no | Person ID of mother |
| `occupation` | string | no | Known occupation |
| `is_direct_ancestor` | boolean | yes | True only for direct line persons |
| `generation` | integer | yes | 0=target, -1=parents, -2=grandparents |
| `holocaust_fate` | object | no | Holocaust details with `source_ids` array |
| `emigration` | object | no | Emigration details with `source_ids` array |
| `notes` | string | no | Free text context |
| `gaps` | string[] | no | Explicitly missing information |

**Changed from previous version:** All `source` string fields are now `source_ids` arrays — linking to entries in the `sources` registry. Multiple sources can support the same fact.

### claims[id] — The Evidence Chains

Every relationship between persons is a claim backed by evidence.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | string | yes | Unique ID (C001, C002, ...) |
| `type` | string | yes | Claim type (see below) |
| `evidence` | array | yes | Array of evidence entries |
| `confidence` | string | yes | `confirmed` / `probable` / `uncertain` |
| `note` | string | no | Explanation of why this confidence level |

**Claim types and their fields:**

| Type | Fields | Description |
|------|--------|-------------|
| `parent_child` | `parent_id`, `child_id` | Parentage claim |
| `marriage` | `person_a`, `person_b` | Marriage/union claim |
| `sibling` | `person_a`, `person_b` | Shared parents claim |
| `identity` | `person_id`, `name_variant` | "This record refers to this person" |

**Evidence entry fields:**

| Field | Type | Description |
|-------|------|-------------|
| `source_id` | string | Reference to a source entry (S001, S002, ...) |
| `detail` | string | What specifically in this source supports the claim |
| `type` | string | `direct` (source explicitly states it), `corroborating` (consistent with claim), `inferred` (deduced from context) |

**Confidence levels:**
- `confirmed` — 2+ independent sources with direct evidence agree
- `probable` — 1 source with direct evidence, or 2+ corroborating sources
- `uncertain` — inference only, or single corroborating source, or contradictory evidence exists

### Querying the Schema

**"Prove X is father of Y":**
1. Find the claim where `type=parent_child`, `parent_id=X`, `child_id=Y`
2. Read its `evidence` array — each entry points to a source and explains what it says
3. Look up each `source_id` in `sources` for the full record and retraceable search

**"Show me all sources for person X":**
1. Collect all `source_ids` from person X's fact objects (birth, death, marriage, etc.)
2. Find all sources where `persons_mentioned` includes X
3. Find all claims involving X and collect their evidence source_ids
4. Union of all above = complete source bibliography for X

**"What's confirmed vs uncertain?":**
1. Filter `claims` by `confidence` field
2. Group persons by whether their parent_child claims are confirmed/probable/uncertain

**"What did we learn from database Y?":**
1. Filter `sources` by `database` or `df` field
2. Collect all `persons_mentioned` from matching sources

## Lifecycle

tree.json is a **living document** updated throughout research, not a final output.

### ID Assignment
Person IDs (P001, P002, ...), source IDs (S001, S002, ...), and claim IDs (C001, C002, ...) are assigned sequentially. Before adding a new entry, read tree.json to find the next available ID.

### Initialization (by lead agent, before research begins)
Write the skeleton with the target person only:
```json
{ "meta": {...}, "sources": {}, "persons": { "P001": {...} }, "claims": {}, "direct_line": ["P001"], "holocaust_victims": [], "emigrants": {} }
```
This should be under 50 lines.

### Continuous Updates (by each branch researcher, after completing a person)
1. Read the current tree.json
2. Edit to add new source entries for records found
3. Edit to add the new person entry
4. Edit to add claims (parent_child, marriage, sibling) linking to existing persons
5. Edit to update `direct_line`, `holocaust_victims`, `emigrants` arrays if applicable
6. Edit to update existing persons (e.g., add `children` IDs, fill in previously-null fields)

Each Edit should add a small batch — a few sources, one person, a few claims. Never rewrite the whole file.

### Full Rebuild (via `/tree` command, if files get out of sync)
1. Read README.md + all branch files
2. Assign all IDs fresh
3. Build source registry from all `[S: ...]` citations
4. Write skeleton (< 50 lines), then fill via Edit calls:
   - Sources in batches of 5-10
   - Persons in batches of 3-5
   - Claims in batches
   - Summary arrays last

**Never write the entire tree.json in a single Write call** — it will exceed tool limits and cause loops.
