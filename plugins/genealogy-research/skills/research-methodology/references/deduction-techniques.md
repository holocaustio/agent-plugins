# Deduction Techniques for Cross-Referencing Records

## Core Technique: Birth → Marriage → Death Chain

Find a person in births, confirm in marriage (parents listed), verify in deaths. Parent names serve as the anchor linking records across databases.

## Key Patterns

### Children Born Before Marriage Date
- If a couple's marriage record date is AFTER a child's birth date → proves a previous spouse existed
- Search for an earlier marriage or the death of a first spouse

### Replacement Naming
- Same given name reused for a later child → the earlier child with that name likely died
- Common Jewish practice: naming after deceased relatives
- If you see "Moshe" born 1850 and "Moshe" born 1855 to the same parents, search for the first Moshe's death record

### Widower/Widow Indicators
- Marriage record lists "Witwer" (widower) or "Witwe" (widow) → previous spouse died
- Search for that spouse's death record and any children from the first marriage

### Address Clustering
- Holocaust deportation records include home addresses
- People at the same address = same household (likely family unit)
- Cross-reference addresses across deportation lists, property declarations, and census records

### Cemetery Adjacency
- Adjacent burial plots suggest family relationships
- Father-son-wife in consecutive plot numbers is common
- Check plot numbers in cemetery databases when other records are sparse

### Age Discrepancies (Normal)
- ±2-3 years across records is expected for this era
- Don't assume a different person based solely on age differences
- Cross-reference with parent names and town to confirm identity

### "Ledig" (Single) Status
- "ledig" in death or deportation records → person never married
- No need to search for marriage records or spouse's family

### Convalidation Marriages
- Religious marriages later registered civilly may show an earlier ritual date
- Look for two dates in the same marriage record

## Name Variant Detection

### Hebrew → Yiddish → Secular Mapping
- One person may have 3+ names across different records
- Hebrew name used in synagogue records
- Yiddish diminutive in community records
- German/Hungarian secular name in civil records

### Common Patterns
- Devorah → Dobresch → Leopoldine
- Israel → Izsak (Hungarian)
- Moshe → Moritz → Max
- Rivka → Rebecca → Regina
- Yehuda → Löb → Leopold
- Sara → Szali → Charlotte
- Abraham → Adolf (pre-Holocaust German adoption)

### Surname Variants
- Clerk-dependent spelling: GOLDBERG / GOLBERG / GOLDBERGER / GOLTBERG
- Language-dependent: German vs Czech vs Hungarian forms
- Phonetic grouping: Use Beider-Morse (`Q`) to catch these automatically

## Parent-Name Reverse Lookup

### How It Works
Search `surname=FAMILY + given=FATHER_NAME` with **exact match** (`srch2t=E`) in JewishGen. Vital record indexes (JRI-Poland, Austrian births, etc.) store the father's given name as a searchable field. This returns ALL children registered under that parent in one search.

### Execution
To execute this search, use the parent-name search tool from the `data-sources` skill (see `sources/jewishgen/README.md`).

### Why This Is Powerful
- Discovers **all siblings** in a single query — no need to guess individual names
- Every discovered parent triggers the same search for the **generation above** (recursive)
- Builds the family tree upward automatically until records run out

### Recursive Application
```
discover_family(person):
  1. Find person's birth record → extract PARENT NAMES
  2. Parent-name search: SURNAME + FATHER_GIVEN → find ALL children (siblings)
  3. Record all siblings (names, birth years, spouses if found)
  4. For EACH newly discovered parent → discover_family(parent)  // RECURSE
```

Each generation's parent-name search reveals siblings at that level AND parent names for the next level up.

### Practical Tips
- **Compound names** (e.g., "Israel Juda"): search the full name AND each component separately
- **Mother's maiden name**: also try `maiden_surname + father_given` — catches maternal registration variants
- **Twin detection**: consecutive Akt (record) numbers with the same year = likely twins
- **Sibling rule**: record ALL siblings found (1 level per generation) — names, birth years, gender, spouses if known
- **Confirmation**: match on both father AND mother names to distinguish true siblings from unrelated families with the same father's name

### Logging in search_index.md
See `file-structure.md` for the search_index.md logging convention, including how to mark parent-name searches.

## Mourner List Analysis (Israeli Newspapers)

Israeli newspaper death notices (e.g., Yedioth Ahronoth, Haaretz, Ma'ariv) list ONLY **living mourners** at the time of publication.

### How to Use

- **Presence** on a mourner list confirms the person was **alive** on the publication date
- **Absence** from a mourner list implies the person had **already died** before the notice date
- Children listed confirm surviving descendants and their current names (married names for women)
- Spouse listed confirms they outlived the deceased

### Narrowing Death Date Ranges

If a family member appears on a 1975 mourner list but NOT on a 1982 mourner list for another relative, their death likely occurred between 1975 and 1982.

### Caveats

- Estranged family members may be deliberately omitted
- Mourner lists may use Hebrew names rather than birth names
- Not all deaths get newspaper notices — mainly for families with Israeli connections
- Survivors abroad may be listed with their country (e.g., "from the USA")

## Cross-Database Strategies

### When Direct Records Are Missing
1. Search siblings' marriages — they list the same parents
2. Search spouse's birth record — confirms marriage link
3. Check deportation/emigration records — may list birthplace and parents
4. Check newspaper notices (Aufbau, Neue Freie Presse, Pester Lloyd) — obituaries often list family

### Confirming Identity Across Databases
Two records are likely the same person when:
- Name matches (allowing for variants)
- Birth year within ±3 years
- Town matches (allowing for language variants)
- Parent name(s) match
- Spouse name matches

Two matching criteria = probable. Three or more = confirmed.

### Disambiguation
Two records are likely DIFFERENT people when:
- Same name but different parents
- Same name but significantly different birth years (>5 years)
- Same name and town but different spouses and overlapping lifetimes
