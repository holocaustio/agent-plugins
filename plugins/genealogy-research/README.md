# genealogy-research

A Claude Code plugin for systematic Jewish genealogy research using [JewishGen](https://www.jewishgen.org) databases. Start from one person, climb the family tree as far as records allow, with full source tracking and academic-grade evidence chains.

## What It Does

- Searches 80+ JewishGen sub-databases (births, marriages, deaths, Holocaust records, burial registries, emigration records)
- Traces ancestry upward — parents, grandparents, great-grandparents — as deep as records go
- Records all siblings of each direct ancestor with their names, dates, spouses, and fates
- Tracks every fact to its source with retraceable search parameters
- Builds evidence chains proving each relationship (e.g., "X is father of Y because records A, B, C say so")
- Produces both human-readable (`tree.md`) and machine-readable (`tree.json`) family tree outputs
- Runs autonomously overnight — gathers all your input upfront, then researches without interruptions

## Install

```bash
claude --plugin-dir /path/to/genealogy-research
```

## Setup

You need a [JewishGen](https://www.jewishgen.org) account (free registration). Set your credentials:

```bash
export JG_USER="your@email.com"
export JG_PASS="yourpassword"
```

### Headless Browser (for non-JewishGen sources)

Some archive sites (ANNO, Arolsen Archives) are JavaScript SPAs that need a headless browser. From the plugin directory:

```bash
cd genealogy-research
npm install
npx playwright install chromium
```

## Commands

### `/login`

Authenticate to JewishGen. Run this first, or let `/research` handle it automatically.

### `/research [name] [birth-year] [birthplace] [parent-name]`

Full research workflow. Two phases:

1. **Intake** (interactive) — asks you questions, does quick reconnaissance searches, gathers all context needed. For common surnames, it will ask for disambiguating details (parents, towns, dates). Ends with: *"I have no more questions."*

2. **Execution** (autonomous) — launches a research-lead agent that coordinates a team of workers searching databases in parallel. Writes findings to structured branch files, builds evidence chains, and generates tree outputs. You can walk away.

```
/research abraham-goldberg 1885 "Vienna" Marcus
```

### `/search [surname] [given-name] [region] [match-type]`

Quick ad-hoc search across all JewishGen databases. Returns a table of which databases have matches and how many records each contains.

```
/search GOLDBERG Abraham 00austriaczech E
```

Match types: `E` (exact), `Q` (phonetic), `D` (soundex), `S` (starts-with), `F1`/`F2`/`FM` (fuzzy).

Region codes: `0*` (all), `00austriaczech`, `00germany`, `00hungary`, `00poland`, `00romania`, `01holocaust`, and [more](skills/data-sources/sources/jewishgen/references/url-parameters.md).

### `/tree [subject-name]`

Regenerate `tree.md` and `tree.json` from existing research data.

```
/tree abraham-goldberg
```

### `/promote-discoveries`

Maintainer command. Merges locally discovered databases and patterns into the plugin's built-in references.

## How Research Data Is Organized

```
subjects/<name>/
  README.md              # Master index: direct line, file index, open questions
  search_index.md        # Database IDs + search log (tracks what was already searched)
  branches/
    direct_line.md       # Direct ancestors, one per generation
    paternal_siblings.md # Siblings of paternal-line ancestors
    maternal_siblings.md # Siblings of maternal-line ancestors
    spouse_<name>.md     # Each spouse's family
    holocaust_victims.md # Combined Holocaust fate records
    emigrants.md         # Combined emigration records
  tree.md                # Generated: human-readable family tree
  tree.json              # Generated: structured data with sources + evidence chains
```

### Source Tracking

Every fact in branch files includes a structured source tag:

```
**Birth:** 1885-06-15, Vienna
[S: database="Vienna Births Enhanced" | df=737d56d4 | search="srch1=GOLDBERG&..." | record="GOLDBERG, Abraham | 1885-06-15 | Father: Marcus | Mother: LEVY, Sarah"]
```

These tags enable:
- **Source registry** in `tree.json` — every record consulted gets an ID
- **Evidence chains** — every relationship claim links to specific sources
- **Retraceability** — the exact search parameters to re-find any record

### Evidence Chains (tree.json)

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

Ask questions like:
- *"Prove that Marcus is Abraham's father"* — shows the specific records
- *"Show me all sources for Abraham"* — complete bibliography
- *"What relationships are uncertain?"* — highlights gaps needing more research

## Architecture

### Agents

| Agent | Role | Model |
|-------|------|-------|
| **research-lead** | Coordinates team, tracks gaps, dispatches workers | opus |
| **branch-researcher** | Searches JewishGen for one person/branch | inherit |
| **tree-builder** | Reads branches, writes tree.md + tree.json | inherit |
| **structure-planner** | Splits large files, sets up folders | inherit |

### Skills

| Skill | Domain |
|-------|--------|
| **research-methodology** | Algorithm, scope rules, file conventions, tree formats |
| **data-sources** | All database access: JewishGen, Yad Vashem, Holocaust.cz, GenTeam, ANNO, Arolsen |

### Self-Learning

The plugin learns from every research session. New databases, parsing patterns, and techniques are saved to `.discoveries/` in your project root. The plugin's built-in references stay read-only (safe for shared installs). Run `/promote-discoveries` to merge local findings into the plugin.

## Tips

- **Start with what you know** — even approximate dates and places help enormously
- **Common surnames** need more context — the intake phase will ask targeted questions
- **Phonetic matching** (`Q`) catches spelling variants — Jewish surnames were recorded in German, Czech, Hungarian, and Hebrew
- **Marriage records are gold** — they list both the person's and their parents' full names
- **Siblings matter** — their records often reveal parent details not found in direct ancestors' records
- **Records stop around 1780-1820** for Central European Jewish families (when civil registration began)
