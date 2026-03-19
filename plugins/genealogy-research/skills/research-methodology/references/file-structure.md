# File Structure Convention

## Directory Layout

```
subjects/<name>/
  README.md                    # Master index (< 100 lines)
  search_index.md              # Database IDs + retraceable search queries
  ruled_out.md                 # Investigated leads that were ruled out (preserved so future research doesn't repeat them)
  scan_requests.md             # Archive contact log — emails sent, responses, pending requests
  branches/
    direct_line.md             # Direct ancestors only
    paternal_siblings.md       # Siblings of paternal-line ancestors
    maternal_siblings.md       # Siblings of maternal-line ancestors
    spouse_<surname>.md        # Each spouse's family
    holocaust_victims.md       # Combined Holocaust fate table
    emigrants.md               # Combined emigration records
  scans/                       # Original document scans (images uploaded by user)
  tree.md                      # Living: human-readable tree (updated during research)
  tree.json                    # Living: machine-readable data (updated during research)
```

## README.md — The Master Index

Under 100 lines. An agent reads this first to orient itself.

Contents:
1. **Subject info** — target person's name, birth, key facts
2. **Direct line** — one line per generation: name (birth-death) married to spouse
3. **File index** — which branch file covers which people
4. **Open questions** — gaps to research next, listed as bullets
5. **Key cross-references** — inter-marriages and connections between branches

## Branch Files — Research Data

Each file under 500 lines. One branch per file.

### Section Structure Per Person

Sources use structured `[S: ...]` tags for machine extraction by the tree-builder.

```markdown
## Person Name (birth_year–death_year)

**Birth:** date, place
[S: database="DB Name" | df=VALUE | search="params" | record="key fields"]

**Death:** date, place, age
[S: database="DB Name" | df=VALUE | search="params" | record="key fields"]

**Marriage:** date, place, to SPOUSE
[S: database="DB Name" | df=VALUE | search="params" | record="key fields"]

**Burial:** cemetery, plot
[S: database="DB Name" | df=VALUE | search="params" | record="key fields"]

**Occupation:** if known
**Name variants:** LIST, OF, VARIANTS

### Evidence for Parentage
- **Father = NAME**: source [S:...] lists "Father: NAME"; source [S:...] confirms → confidence
- **Mother = NAME**: source [S:...] lists "Mother: NAME" → confidence

### Siblings
1. Sibling Name (birth–death) ∞ Spouse — fate
   [S: database="DB Name" | df=VALUE | search="params" | record="key fields"]
2. ...

### Gaps
- Birth record NOT FOUND
- Mother's maiden name uncertain
- Death date approximate (~1870)

### Contradictions
- Death record says age 79 (implying birth ~1861) but birth record says 1858
  [S: source1] vs [S: source2]
```

**The `[S: ...]` tag** contains: `database` (name), `df` (ID), `search` (URL params to reproduce), `record` (summary of the actual record found). The tree-builder parses these into a source registry and evidence chains in tree.json.

## ruled_out.md — Dead Ends & Ruled Out Leads

This file preserves research hypotheses that were **investigated and definitively ruled out**. It prevents future research sessions from re-investigating the same leads.

### When to Add an Entry

Move a lead to ruled_out.md when:
- A hypothesis was tested and **definitively disproven** by evidence
- A database record was investigated and confirmed to be a **different person/family**
- A date, name, or place was shown to be a **misreading, data swap, or fabrication**
- A source (e.g., a YV Page of Testimony) was proven **incorrect** by stronger evidence

Do NOT add entries that are merely "unresolved" or "uncertain" — those belong in the README's Open Questions.

### Entry Structure

```markdown
## [Short description] — RULED OUT

**Hypothesis:** What was the original theory?

**Evidence against:**
1. Source 1 says X
2. Source 2 says Y
3. Cross-reference proves Z

**Ruled out:** One-sentence summary of why this is definitively wrong.

[S: source citations for the evidence]
```

Each entry should be self-contained — a future researcher reading just that entry should understand what was tried and why it failed, without needing to read the branch files.

### Categories of Ruled-Out Leads

- **Wrong person** — a database record that looked like a match but is a different individual (different parents, birthplace, etc.)
- **Incorrect date/fact** — a date or fact from one source that is contradicted by stronger evidence
- **Data errors** — transcription mistakes, data swaps in digitized records, misreadings of handwriting
- **Misidentifications** — "Novisad" = Nowy Sącz, not Novi Sad; a PoT claiming someone died when they survived
- **Unrelated family** — people with the same surname from a different branch or town
- **No connection found** — a cluster of records that seemed promising but has no verifiable link to the family

## scan_requests.md — Archive Contact Log

Tracks all correspondence with archives for original document requests.

### Format

```markdown
# Scan Requests & Archive Correspondence

## Contacts
| Archive | Email | Contact Person | Notes |
|---------|-------|---------------|-------|

## Requests
### [Date] — [Archive] — [What was requested]
**Status:** Sent / Awaiting response / Received / No response
**Email thread:** [Subject line or reference number]
**What we asked for:** [Description — person name, record type, date, reference numbers]
**What we received:** [Summary of response, or "pending"]
**Files:** [Filenames in scans/ folder, if received]
```

### When to Create

Create scan_requests.md when:
- An indexed record references an original register page with more detail
- A film-only FamilySearch record needs a scan request
- Any archive contact is drafted or sent

See `archives-contact.md` for email templates and archive contact details by region.

## scans/ — Original Document Scans

User-uploaded images of original register pages, certificates, or other documents.

### Naming Convention

`<person_name> <document_type>.<ext>`

Examples:
- `hugo geburtsbuch.jpg` — Hugo's birth register page
- `rosa trauungsbuch.png` — Rosa's marriage register page
- `marek meldezettel.jpg` — Marek family residence card

### Agent Behavior

When a user uploads a scan:
1. Acknowledge the upload and note the filename in the relevant branch file
2. Offer to transcribe (German Kurrent, Hebrew, Polish handwriting)
3. Cross-reference transcribed details with existing data
4. Update the branch file with any new facts, citing the scan as source

## When to Split

- **Start** with a single `family_tree.md` for convenience
- **Split when** it exceeds ~500 lines or agents start struggling with context
- **Keep the original** as an archive; extract branch files from it

## How Agents Use Split Files

| Agent Role | Reads | Writes |
|------------|-------|--------|
| Research lead | README.md | README.md, initializes tree.md + tree.json |
| Branch researcher | README.md + one branch file + tree files | That branch file + tree.md + tree.json |
| Structure planner | README.md + all files | Creates branches/, splits files |

**Tree files are updated continuously.** Each branch researcher updates tree.md and tree.json after completing a person — add the person entry, their sources, and any new claims. Don't defer tree updates to a separate pass. `/tree` can rebuild from scratch if files get out of sync.

**All agents must write incrementally.** No single Write call should exceed ~150 lines. Instead: write a skeleton first, then use Edit calls to fill each section. This applies especially to branch files, tree.md, and tree.json. See the main SKILL.md "File Writing Strategy" section for per-file patterns.

## search_index.md — Search Log & Database Catalog

This file serves two purposes and is critical for **continuation across sessions**:

### Section 1: Database IDs
All `df` values discovered during research:
```markdown
## Key Database IDs (df values)
| Database | df |
|----------|-----|
| Vienna Births Enhanced | 737d56d4-... |
| ...
```

### Section 2: Searches Performed
A log of every search batch, so continuing agents know what NOT to repeat:
```markdown
## Searches Performed
| Date | Surname | Given | Region | Match | Databases Checked | Findings |
|------|---------|-------|--------|-------|-------------------|----------|
| 2026-02-22 | GOLDBERG | Abraham | 00austriaczech | E | 737d56d4, VIENNADEATH | 3 birth, 2 death |
| 2026-02-22 | LEVY | - | 00austriaczech | Q | (unified) | 45 total matches |
```

**Parent-name searches** use a `[parent]` prefix in the Given column
(e.g., `[parent] Marcus`) to distinguish them from person searches.
This prevents continuation agents from re-running the same parent search.

### Section 3: Retrace Queries
Specific queries that found key records, with exact parameters:
```markdown
## Retrace Specific Findings
### Abraham born 1884
df=25c41f2b&srch1=GOLDBERG&srch1v=S&srch1t=E&srch2=ABRAHAM&srch2v=G&srch2t=E
→ Row: "GOLDBERG, Abraham | 1884-03-13 | Marcus / LEVY, Sarah | Vienna"
```

### How Agents Use This File
- **Research lead:** Reads before planning — skips searches already logged
- **Branch researcher:** Appends new searches after each batch
- **Continuing sessions:** The "Searches Performed" table is the primary mechanism for avoiding duplicate work. A search should only be re-run if using a different match type, new name variant, or newly discovered database.
