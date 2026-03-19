# genealogy-research

A Claude Code plugin for systematic Jewish genealogy research. Give it one person — a name, approximate birth year, birthplace — and it climbs the family tree as far as records allow, searching 10+ databases autonomously while tracking every fact to its source.

It is designed to run overnight without interaction after a short intake phase.

## What It Does

- Searches 80+ JewishGen sub-databases plus Yad Vashem, Holocaust.cz, GenTeam.at, Geni.com, JRI-Poland, ANNO newspapers, Arolsen Archives, and FamilySearch catalog
- Traces ancestry **upward** — parents, grandparents, great-grandparents — as deep as civil records go (typically 1780-1820 for Central European Jews)
- Records all siblings of each direct ancestor with their names, dates, spouses, and fates
- Tracks every fact to its source with retraceable search parameters
- Builds evidence chains proving each relationship (e.g., "X is father of Y because records A, B, C say so")
- Produces both human-readable (`tree.md`) and machine-readable (`tree.json`) family tree outputs
- Learns from each session — newly discovered database IDs and patterns are saved locally and can be promoted into the plugin

## Installation

```bash
# From the holocaustio marketplace (if already added)
/plugin install genealogy-research@holocaustio

# Or add the marketplace first
/plugin marketplace add holocaustio/agent-plugins
/plugin install genealogy-research@holocaustio
```

## Prerequisites

### JewishGen Account (required)

You need a free [JewishGen](https://www.jewishgen.org) account. Set your credentials as environment variables:

```bash
export JG_USER="your@email.com"
export JG_PASS="yourpassword"
```

You can add these to your shell profile, or set them in Claude Code's settings so they're always available.

### GenTeam.at Account (optional)

For Austrian Jewish records (Vienna, Lower Austria, Moravia/Bohemia). Free registration at [GenTeam.at](https://www.genteam.at). Set credentials:

```bash
export GENTEAM_USER="your@email.com"
export GENTEAM_PASS="yourpassword"
```

### Geni.com Token (optional)

For accessing the World Family Tree (200M+ profiles). Requires an OAuth2 token:

```bash
export GENI_TOKEN="your_access_token"
```

### Headless Browser (optional)

Some archive sites (ANNO newspapers, Arolsen Archives) are JavaScript SPAs that need a headless browser. From the plugin's install directory:

```bash
npm install
npx playwright install chromium
```

> Yad Vashem, Holocaust.cz, and JRI-Poland work without a browser — they use direct HTTP requests.

## Quick Start

The simplest way to start:

```
/research Goldberg 1885 Vienna Marcus
```

This tells the plugin: *"Research a person named Goldberg, born around 1885 in Vienna, whose father's name was Marcus."*

The plugin will ask you a few clarifying questions, run quick reconnaissance searches, present a research brief, and then — once you confirm — run autonomously until all researchable gaps are exhausted.

## Commands

### `/research [name] [birth-year] [birthplace] [parent-name]`

The main entry point. All arguments are optional — the intake phase will ask for anything missing.

**Phase 1 — Intake (interactive):**
- Parses your arguments and checks for existing research on this person
- Asks clarifying questions (for common surnames, it needs extra context to disambiguate)
- Runs quick recon searches on JewishGen to see what's available
- Presents a research brief summarizing what it found and its plan
- Waits for your confirmation before proceeding

**Phase 2 — Execution (autonomous):**
- Launches a research-lead agent that coordinates a team of workers
- Researchers search JewishGen first (unified survey, parent-name searches to discover siblings, detail drill-downs), then non-JewishGen sources
- Concurrency: one JewishGen researcher at a time (shared session cookies), but other sources run in parallel
- The recursive algorithm: find a birth record to get parent names, search those parents to discover all siblings, then recurse upward on each parent
- When new surnames appear (maiden names, in-laws from testimonies), they trigger fresh global searches
- Tree files are rebuilt periodically as new data comes in
- Stops when all researchable gaps are exhausted

You can walk away after confirming the research brief. Come back to find a populated family tree.

### `/continue-research [subject-name]`

Resumes existing research in a new session. No intake phase — it reads your existing files, presents a quick status summary (persons researched, generations reached, top unresolved gaps, candidates needing review), confirms direction with you, and re-enters the autonomous execution loop. Critically, it checks `search_index.md` before planning any search to avoid duplicate work.

### `/search [surname] [given-name] [region] [match-type]`

Quick ad-hoc search across all JewishGen databases. Returns a table showing which databases have matches and how many records each contains.

```
/search GOLDBERG Abraham 00austriaczech E
```

| Argument | Description | Examples |
|----------|-------------|----------|
| surname | Required | `GOLDBERG` |
| given-name | Optional | `Abraham` |
| region | Optional — region code | `0*` (all), `00austriaczech`, `00germany`, `00hungary`, `00poland`, `01holocaust` |
| match-type | Optional — how to match | `E` (exact), `Q` (phonetic), `D` (soundex), `S` (starts-with), `F1`/`F2`/`FM` (fuzzy) |

Phonetic matching (`Q`) is especially useful for Jewish surnames, which were recorded across German, Czech, Hungarian, and Hebrew transliterations.

### `/login`

Authenticate to JewishGen manually. Useful for verifying your credentials work. Not normally needed — `/research` and `/search` handle authentication automatically.

### `/tree [subject-name]`

Regenerate `tree.md` and `tree.json` from existing branch files. Use this if you've manually edited research data and want to rebuild the tree outputs.

### `/promote-discoveries`

Maintainer command. During research, the plugin saves newly discovered database IDs, parsing patterns, and techniques to `.discoveries/` in your project root. This command reviews each discovery and merges approved ones into the plugin's built-in reference files.

## Data Sources

| Source | What It Provides | Auth Required |
|--------|-----------------|---------------|
| **JewishGen** (80+ databases) | Birth, marriage, death, burial, Holocaust, emigration records | Yes — free account |
| **Yad Vashem** | Pages of Testimony, transport lists, camp records, family details from survivor submissions | No |
| **Holocaust.cz** | Czech transport details, Terezin records, deportation chains, last addresses | No |
| **GenTeam.at** | Austrian Jewish vital records (Vienna, Lower Austria), Moravian/Bohemian indices, cemetery records, obituaries | Yes — free account |
| **Geni.com** | World Family Tree (200M+ profiles), pre-built trees from other researchers | Yes — OAuth2 token |
| **JRI-Poland** | Polish vital records (births, marriages, deaths, divorces, Holocaust) | Uses JewishGen session |
| **ANNO** | Digitized Austrian newspapers 1700s-1940s — birth/death/marriage announcements, obituaries | No (needs headless browser) |
| **Arolsen Archives** | Holocaust archive catalog — finding aid pointers to card file segments | No (needs headless browser) |
| **FamilySearch** | Microfilmed original registers — more detail than any index (witnesses, marginal annotations) | Manual browsing only |

The plugin searches JewishGen first (broadest coverage), then checks each additional source for records that JewishGen doesn't index. FamilySearch can't be searched programmatically — the agent identifies relevant catalog entries and either directs you to browse them or drafts an archive request on your behalf.

## Research Output

All research data is written to a `subjects/<name>/` folder in your working directory:

```
subjects/<name>/
  README.md              Master index — direct line summary, file index, open questions
  search_index.md        What was already searched (database IDs + search log + retrace queries)
  ruled_out.md           Dead ends and why they were ruled out
  scan_requests.md       Archive correspondence drafts and status
  branches/
    direct_line.md       Direct ancestors, one per generation
    paternal_siblings.md Siblings along the paternal line
    maternal_siblings.md Siblings along the maternal line
    spouse_<name>.md     Each spouse's family (upward only)
    holocaust_victims.md Combined Holocaust fate records
    emigrants.md         Combined emigration records
  scans/                 Uploaded document images
  tree.md                Human-readable family tree (generated)
  tree.json              Machine-readable tree with sources + evidence chains (generated)
```

### Source Tracking

Every fact in branch files includes a structured source tag:

```
**Birth:** 1885-06-15, Vienna
[S: database="Vienna Births Enhanced" | df=737d56d4 | search="srch1=GOLDBERG&..." | record="GOLDBERG, Abraham | 1885-06-15 | Father: Marcus | Mother: LEVY, Sarah"]
```

These tags make every fact retraceable — you can re-run the exact search parameters to find the original record. They also feed into `tree.json`'s source registry and evidence chains.

### Evidence Chains (tree.json)

The generated `tree.json` has three sections:

- **sources** — bibliography of every record consulted, with retraceable search parameters
- **persons** — every individual discovered, with facts linked to source IDs
- **claims** — every relationship (parent-child, spouse) backed by evidence chains with confidence levels

```json
{
  "claims": {
    "C001": {
      "type": "parent_child",
      "parent_id": "P010",
      "child_id": "P001",
      "evidence": [
        {"source_id": "S001", "detail": "Father column: 'Marcus'", "type": "direct"},
        {"source_id": "S008", "detail": "Marriage record lists father as 'Marcus GOLDBERG'", "type": "corroborating"}
      ],
      "confidence": "confirmed"
    }
  }
}
```

You can query the tree naturally:
- *"Prove that Marcus is Abraham's father"* — shows the specific records and evidence chain
- *"Show me all sources for Abraham"* — complete bibliography for one person
- *"What relationships are uncertain?"* — highlights gaps needing more research

## Architecture

### Agents

| Agent | Role | Description |
|-------|------|-------------|
| **research-lead** | Coordinator | Plans research targets, dispatches workers, enforces concurrency rules, manages the "new surname protocol" (global search when a new family name appears), tracks progress |
| **branch-researcher** | Worker | Searches databases for one specific person or family branch. Filters results using all known context. For ambiguous matches, writes candidates for human review rather than guessing |
| **tree-builder** | Assembler | Reads all branch files and generates `tree.md` + `tree.json`. Performs quality checks (every person accounted for, every source tag registered, all links bidirectional) |
| **structure-planner** | Organizer | Sets up new subject folders, splits files that grow too large, updates the master index |

### Skills

| Skill | What It Teaches |
|-------|----------------|
| **research-methodology** | The recursive algorithm (birth → parents → recurse), scope rules, source tracking discipline, file structure conventions, tree output formats, deduction techniques, archive contact templates |
| **data-sources** | How to access each database — authentication flows, URL construction, rate limiting, concurrency rules, shell script usage, and a source routing table for which database to try for which research gap |

### Self-Learning

The plugin's built-in reference files are read-only during research. When agents discover something new — a database ID not in the catalog, an unusual URL parameter, a parsing gotcha — they write it to `.discoveries/` in your project root. This keeps your installed plugin clean while capturing institutional knowledge. Run `/promote-discoveries` to merge approved findings into the plugin.

## Tips

- **Start with whatever you know** — even a surname and approximate decade is enough. The intake phase will help narrow things down.
- **Common surnames** (Goldberg, Schwartz, Kohn) need extra context. Have a parent name, specific town, or date range ready if possible.
- **Marriage records are the richest source** — they list both the person's and their parents' full names, often with ages and birthplaces.
- **Siblings matter** — their birth/marriage/death records often reveal parent details not found in the direct ancestor's own records.
- **Use phonetic matching** (`Q`) — Jewish surnames were transliterated across German, Czech, Hungarian, Hebrew, and Yiddish. "Goldberger" might appear as "Golberger", "Goldberg", or "Goltberg".
- **Records typically stop around 1780-1820** for Central European Jewish families, when civil registration began. Earlier records may exist in community pinkas books but are rarely indexed.
- **Non-Jewish ancestry** — if a non-Jewish parent is found (intermarriage was common in Vienna after ~1870), the plugin adjusts to use civil and parish records instead of JewishGen.
- **FamilySearch originals** contain more detail than any index — father's exact birthdate, witness names, marginal annotations about later marriages or deaths. The plugin will identify relevant microfilm entries and help you browse or request scans.

## License

MIT
