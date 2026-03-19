---
name: research-methodology
description: >-
  Systematic Jewish genealogy research methodology — climbing family trees,
  scope rules, source citation, file structure, and tree output formats.
  Use when planning research strategy, deciding which relatives to trace,
  tracking sources, organizing branch files, or generating tree.md/tree.json.
  NOT for database search mechanics (use data-sources skill instead).
metadata:
  author: DeanLa
  version: 1.0.0
---

# Jewish Genealogy Research Methodology

A systematic approach for tracing a specific person's ancestry using JewishGen databases. Start from one person, climb the tree as far back as records allow, with controlled lateral expansion.

## The Algorithm

```
START with target person (name, birth date, birthplace)
  → Initialize tree.md and tree.json with target person
WHILE records exist:
  1. Find target's BIRTH record → extract parents' names
  2. Find target's MARRIAGE record → confirms parents (both sides)
  3. Find target's DEATH/BURIAL record → confirms birth year, birthplace
  → UPDATE tree.md and tree.json with new facts and persons
  4. For EACH parent found:
     a. Search ALL siblings (cross-confirm parents via their marriage records)
     b. Set parent as new target → RECURSE
  5. For target's SPOUSE:
     a. Find spouse's birth record → extract spouse's parents
     b. Set spouse's parents as new targets → RECURSE (lower priority)
  → UPDATE tree files after each person/generation is complete
```

**Key insight:** Marriage records are the richest source — they list both the person's AND their parents' full names. When a direct ancestor's marriage record is missing, search their siblings' marriages instead.

**Stop when:** No more records exist (typically ~1780-1820 for Central European Jewish families, when civil registration began).

## Scope Rules

Research direction is **UP the tree, with siblings at each level:**

| Category | Include? | Details |
|----------|----------|---------|
| Direct ancestors | YES (primary) | Parents, grandparents, great-grandparents — as far as records go |
| Siblings of ancestors | YES (secondary) | ALL siblings: names, birth/death, spouses, fates |
| Spouses' lineages | YES (tertiary) | Parents and grandparents of people who married into the direct line |
| Children of siblings | ONLY IF inter-marriage | Common in small Jewish communities; otherwise skip |
| Cousins' descendants | NO | Unless inter-marriage |
| Extended in-law networks | UP only | Parents/grandparents of spouses, not sideways |

**Why siblings matter:** Their marriage records list shared parents. Their birth records confirm mother's maiden name variants. Their fates (Holocaust, emigration) complete the family picture.

**Priority:** Always go UP before going sideways. A great-grandparent's birth record is more valuable than a cousin's marriage record.

## Source Tracking

**Every fact must cite its source.** These are old records (often 1800s-1940s), frequently incomplete, with inconsistent spelling and conflicting dates.

For each fact, record:
- **Database name + `df` value** — so the search can be re-run
- **Exact search parameters** — for retraceability
- **Confidence level:**
  - `confirmed` — multiple sources agree
  - `probable` — single source, fits context
  - `uncertain` — conflicting data or inference
- **What's MISSING** — explicitly note when a record was NOT found

See `${CLAUDE_PLUGIN_ROOT}/skills/research-methodology/references/record-quality.md` for the realities of 19th-century records.

## Parallelization Strategy

Once both parents are identified, their lines can be researched **simultaneously**:

```
Lead agent (coordinates, tracks gaps, maintains README.md, initializes tree files)
  ├── Worker A: paternal grandparents line → updates tree files after each person
  ├── Worker B: maternal grandparents line → updates tree files after each person
  ├── Worker C: Holocaust/emigration databases → updates tree files with fates
  └── Worker D: burial registries → updates tree files with burial data
```

- **Per-person agents:** Each worker searches ALL databases for one person/branch sequentially
- **Tree updates are continuous:** Each worker updates tree.md and tree.json after completing a person — don't wait for a separate tree-builder pass
- **Team coordination:** Lead reads README.md for gaps, assigns workers to branch files
- **Source access serialization:** See the `data-sources` skill for concurrency constraints
- **Full regeneration:** If tree files get out of sync with branch data, the lead can run `/tree` to rebuild from scratch

## File Structure Convention

```
subjects/<name>/
  README.md                    # Direct line + file index + open questions (< 100 lines)
  search_index.md              # Database IDs + retraceable search queries
  ruled_out.md                 # Investigated leads ruled out — prevents repeating dead ends
  scan_requests.md             # Archive contact log — emails sent, responses, pending requests
  branches/
    direct_line.md             # Direct ancestors only, one per generation
    paternal_siblings.md       # Siblings of paternal-line ancestors
    maternal_siblings.md       # Siblings of maternal-line ancestors
    spouse_<surname>.md        # Each spouse's family
    holocaust_victims.md       # Combined Holocaust fate table
    emigrants.md               # Combined emigration records
  scans/                       # Original document scans (images uploaded by user)
  tree.md                      # Living: human-readable tree (updated during research)
  tree.json                    # Living: machine-readable structured data (updated during research)
```

See `${CLAUDE_PLUGIN_ROOT}/skills/research-methodology/references/file-structure.md` for details on when to split files and how agents use them.

### README.md — The Master Index

Under 100 lines. Contains:
1. **Direct line** — one line per generation (name, birth-death, spouse)
2. **File index** — which branch file has which people
3. **Open questions** — gaps to research next
4. **Key cross-references** — inter-marriages between branches

### Branch Files — The Research Data

Each under 500 lines. Contains:
- Each ancestor as a section: birth, death, marriage, burial — each fact citing source
- All siblings recorded fully: name, dates, spouse, fate — with sources
- Name variant notes for each person
- **Gaps explicitly marked:** "birth record NOT FOUND", "parents unknown"
- **Contradictions noted:** When sources disagree, record BOTH with sources

## Geographic Scope for Newly Discovered Surnames

When a new surname emerges during research (from any source — Yad Vashem, marriage records, Holocaust databases), it must be searched **globally (region `0*`)** in JewishGen, not just in the subject's known geography.

**Rationale:** Central European Jewish families regularly crossed borders — spa town marriages (Marienbad, Karlsbad), wartime displacement, economic migration, and cross-border community ties mean that a surname first seen in one region may have critical records elsewhere. Region-filtering a newly discovered surname is premature narrowing that causes missed records.

**Rule:** Known primary surnames follow the normal region-filtered strategy. Newly discovered surnames get one global search first, then narrow based on what's found.

## Cross-Referencing Methodology

See `${CLAUDE_PLUGIN_ROOT}/skills/research-methodology/references/deduction-techniques.md` for the built-in set, and also check `.discoveries/deduction-techniques.md` in the project root for locally discovered techniques.

Key patterns:
- **Birth → Marriage → Death chain:** Link a person across record types using parent names as anchors
- **Name variants:** Hebrew ↔ Yiddish ↔ German ↔ Hungarian (e.g., Devorah → Dobresch → Leopoldine)
- **Address clustering:** Same address in deportation records = same household
- **Cemetery adjacency:** Adjacent plots suggest family relationship
- **Replacement naming:** Same given name reused = earlier child likely died

## Non-Jewish Ancestry

When a non-Jewish parent or ancestor is identified (e.g., a father who was Catholic):

1. **Flag it in the README** — note which branch is non-Jewish so agents adjust strategy
2. **Adjust search sources:** Prioritize GenTeam civil records (DB 6), Catholic parish records (Matricula Online), Austrian state archives. Don't waste JewishGen searches on the non-Jewish line.
3. **Civil marriages (Notzivilehe):** Mixed-religion couples married at the district court (Bezirksgericht), not at a synagogue or church. These records are at the WStLA (Vienna) or the relevant Bezirksgericht archive.
4. **FamilySearch catalog:** Search for the parish of the non-Jewish parent — church registers are well-microfilmed

## Ruled-Out Leads

When a hypothesis is definitively disproven, move it to `ruled_out.md` — don't delete it. This prevents future research sessions from re-investigating the same dead ends. See `${CLAUDE_PLUGIN_ROOT}/skills/research-methodology/references/file-structure.md` for the ruled_out.md entry format and categories.

Leads that are merely "unresolved" or "uncertain" stay in the README's Open Questions — only definitively disproven hypotheses go to ruled_out.md.

## Multi-Source Research Strategy

When researching a person, search multiple sources — each has records the others lack.

### Source Selection by Research Gap

| Research Gap | Best Sources | Why |
|-------------|-------------|-----|
| Birth/marriage/death records | JewishGen, GenTeam (Austrian) | Largest vital record collections |
| Holocaust victim details (family names) | Yad Vashem, Holocaust.cz | Pages of Testimony have unique family context |
| Czech transport routes, Terezín | Holocaust.cz | Only source with full Czech deportation chains |
| Austrian records not in JewishGen | GenTeam.at | Independent transcription project |
| Newspaper mentions, obituaries | ANNO | Digitized Austrian newspaper archive |
| Holocaust archive pointers | Arolsen Archives | Central Name Index finding aids |

This table tells you WHICH source for WHICH gap. The `data-sources` skill tells you HOW.

### Original Documents & Scans

After finding an indexed record (JewishGen, JRI-Poland, GenTeam), the **original register page** often has MORE information than the index extract — father's exact birthdate, marriage date, witnesses, marginal annotations, and corrections.

#### Where to Find Scans

| Record Type | Where to Look | How |
|---|---|---|
| Vienna IKG births/marriages/deaths | FamilySearch catalog 196164 | Browse online if digitized; request scan if film-only |
| Galician vital records (Nowy Sącz, Kraków, etc.) | FamilySearch, szukajwarchiwach.gov.pl | Search by town name in FamilySearch catalog |
| Austrian civil/parish records | Matricula Online (matricula-online.eu) | Free — browse by parish/district |
| Czech/Moravian records | actapublica.eu, badatelna.eu | Free Czech digitization projects |
| Holocaust documents | Arolsen Archives (collections.arolsen-archives.org) | Search by name, browse scanned originals |
| Terezín records | Holocaust.cz, Terezín memorial | Some documents digitized inline |

#### When Scans Aren't Online

Contact the archive directly. See `${CLAUDE_PLUGIN_ROOT}/skills/research-methodology/references/archives-contact.md` for email templates, contact details by region, and tracking guidance.

#### Agent Guidance for Scans

When a record is found with a scan/film reference, prompt the user:

> "I found [record] which references [register/film]. The original page may have additional details (father's birthdate, witnesses, annotations). You can look for the scan at [specific URL/catalog]. If you find it, save it to `subjects/<name>/scans/` and I can help transcribe it."

When the user uploads a scan to the subject folder:
1. Offer to transcribe German Kurrent, Hebrew, or Polish handwriting
2. Cross-reference transcribed details with existing data in branch files
3. Update branch files with new facts, citing the scan as source
4. Note the scan filename in the relevant person's section

**Scan naming convention:** `<person_name> <document_type>.<ext>` (e.g., `hugo geburtsbuch.jpg`)

Track all archive requests in `scan_requests.md` — see `${CLAUDE_PLUGIN_ROOT}/skills/research-methodology/references/file-structure.md` for format.

### Search Progression Strategy

Applies to any database, not just JewishGen:

1. **Start broad** — phonetic/fuzzy matching to catch spelling variants
2. **Identify key databases** — parse survey results for most matches in target region
3. **Drill down** — search promising databases with exact matching
4. **Widen if sparse** — if exact returns few, try phonetic/soundex/fuzzy
5. **Add given name** — for common surnames, always include given name
6. **Add town** — if still too many results, add town as filter

## File Writing Strategy

See `${CLAUDE_PLUGIN_ROOT}/skills/research-methodology/references/file-writing-strategy.md` for incremental file-building patterns (skeleton → Edit calls). Key rule: **never use a single Write call for files over ~150 lines.**

## Tree Output Formats

Two living outputs, updated continuously as research progresses:

- **tree.md** — Human-readable indented tree. See `${CLAUDE_PLUGIN_ROOT}/skills/research-methodology/references/tree-md-format.md`
- **tree.json** — Machine-readable structured data. See `${CLAUDE_PLUGIN_ROOT}/skills/research-methodology/references/tree-json-schema.md`

### Lifecycle
1. **Initialized early** — the lead agent creates both files with the target person before research begins
2. **Updated continuously** — each worker updates both files after completing a person (add person, sources, claims, update generation sections)
3. **Always trackable** — at any point during research, tree.md and tree.json reflect all discoveries so far
4. **Full rebuild available** — if files get out of sync, `/tree` regenerates from branch files

## Troubleshooting

### No birth record found
- Try marriage records of siblings (parent names listed)
- Search death/burial records (often list birth year/place)
- Check JewishGen Holocaust databases (may list birthdate)

### Too many results (>100 matches)
- Add given name filter
- Narrow by town/region
- Switch from phonetic to exact matching
- Filter by date range

### Conflicting dates between sources
- Record BOTH with source citations
- Use marriage records as tiebreaker (usually most accurate)
- Note discrepancy in branch file, mark confidence as "uncertain"
