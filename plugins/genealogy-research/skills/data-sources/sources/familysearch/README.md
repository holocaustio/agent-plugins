# FamilySearch

The world's largest genealogy platform, operated by The Church of Jesus Christ of Latter-day Saints. Contains microfilmed original registers from archives worldwide, including many Jewish vital records not indexed elsewhere.

## Key Concepts

### Catalog vs Collections

| Concept | What It Is | Searchable? | Access |
|---------|-----------|-------------|--------|
| **Collections** | Indexed, searchable databases (like JewishGen) | Yes — search by name | Free account required |
| **Catalog** | Inventory of microfilmed records organized by place | Browse only — no name search | Varies (see below) |

The **catalog** is where the real value lies for genealogy research. It lists original register microfilms that may contain far more detail than any index extract.

### Access Levels

| Level | What It Means | How to Access |
|-------|--------------|---------------|
| **Full images online** | Digitized and freely browsable | Free account at familysearch.org |
| **Limited images online** | Digitized but restricted by agreement with the archive | Free account; may require affiliate library access |
| **Film only** | Microfilm exists but not yet digitized | Visit a FamilySearch Center, or request a scan |

## Key Collections for Central European Jewish Research

### Vienna IKG Records (Catalog 196164)

The Vienna Israelitische Kultusgemeinde (Jewish Community) vital registers:
- **Geburtsbücher** (birth registers) — 1826–1943
- **Trauungsbücher** (marriage registers) — 1826–1943
- **Sterbebücher** (death registers) — 1826–1943

These are the ORIGINAL registers that JewishGen indexes. The originals often contain:
- Father's exact age/birthdate (not just name)
- Mother's maiden name with birthplace
- Witnesses and their relationships
- Marginal annotations (later marriages, deaths, corrections)
- Registration numbers cross-referencing other entries

**How to access:** Search the catalog for "Wien" or catalog number 196164. Some films are digitized (browse online); others are film-only (need FamilySearch Center or scan request).

### Galician Civil Records

Many Polish civil registrations from the former Galicia region have been microfilmed:
- Search the catalog by town name (e.g., "Nowy Sącz", "Kraków", "Tarnów")
- Records in Polish, German, or Latin depending on era
- Some indexed in JRI-Poland, but the original images have more detail

### Czech/Moravian Records

- Some Jewish matriky (registers) microfilmed by FamilySearch
- Also available via actapublica.eu and badatelna.eu (Czech digitization projects)
- Search catalog by town name in Czech or German

## Agent Workflow

**FamilySearch cannot be searched programmatically.** There is no API for browsing catalog images. The workflow is:

1. **Identify the catalog entry** — search familysearch.org/search/catalog by place name
2. **Check digitization status** — is it browsable online, limited, or film-only?
3. **If browsable online:** Tell the user the catalog URL and what to look for (e.g., "Birth register 1884, look for entry around March")
4. **If film-only:** Draft a scan request (see archives-contact.md) or suggest visiting a FamilySearch Center
5. **If user finds and uploads a scan:** Offer to transcribe (German Kurrent, Hebrew, Polish) and cross-reference with existing data

### Standard Agent Prompt

When a record is found in JewishGen/JRI-Poland that references an original register:

> "The original register page may have additional details beyond what's in the index (father's birthdate, witnesses, annotations). You can look for the scan at FamilySearch catalog [specific URL]. If you find it, save it to `subjects/<name>/scans/` and I can help transcribe it."

## When to Use FamilySearch

| Situation | Action |
|-----------|--------|
| Found an indexed record in JewishGen → want original page | Check FamilySearch catalog for that town's registers |
| JewishGen has no records for a town | Check if FamilySearch has un-indexed microfilms for that town |
| Need details not in index (witnesses, annotations, exact ages) | Original register on FamilySearch likely has them |
| Record is film-only | Suggest FamilySearch Center visit or draft scan request |
| Looking for non-Jewish records (civil marriage, parish) | FamilySearch has many non-Jewish registers too |

## Catalog Search Tips

- Search by **place name** (town), not person name — the catalog is organized geographically
- Try both German and local-language town names (e.g., "Wien" and "Vienna", "Brünn" and "Brno")
- Filter by "Jewish" or "Israelitische" in the catalog title to find specifically Jewish registers
- Note the **film number** — this is needed for scan requests
- Check the **date range** of each film to find the right volume

## Limitations

- No programmatic access to images — cannot curl or scrape
- Some records restricted by archive agreements (limited access)
- Film-only records require physical access or a scan request (can take weeks)
- Catalog organization can be confusing — same town may appear under multiple jurisdictions
- Image quality varies (some microfilms are faded or damaged)

## Contact for Scan Requests

FamilySearch Support: support@familysearch.org

For film-only records, you can request digitization. Include:
- Catalog number and film number
- Specific date range you need
- Type of record (birth/marriage/death)
- Reason for request (family history research)

Turnaround varies; popular collections may be prioritized.
