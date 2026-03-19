# Non-JewishGen Source Scripts

These scripts search archive sites that use JavaScript SPAs (where `curl` gets an empty shell). They use a headless browser (Playwright/Chromium) to render the page first, then extract results.

## Setup

From the plugin directory (`genealogy-research/`):
```bash
cd genealogy-research
npm install
npx playwright install chromium
```

## Scripts

### browser-fetch.js — Generic Headless Fetch

Renders any JavaScript-heavy page and outputs HTML to stdout. Use this when you need to scrape a new SPA site that isn't covered by a wrapper script.

```bash
# Full page HTML
node scripts/browser-fetch.js "https://example.com/search?q=test"

# Wait for a specific element, then extract only matching elements
node scripts/browser-fetch.js "https://example.com/search?q=test" \
  --wait-for ".results" \
  --extract ".result-item" \
  --timeout 20000
```

**Arguments:**
| Arg | Required | Default | Description |
|-----|----------|---------|-------------|
| URL | Yes | — | Page to load |
| `--wait-for` | No | none | CSS selector to wait for before extracting |
| `--timeout` | No | 15000 | Max wait in milliseconds |
| `--extract` | No | full page | CSS selector — returns outerHTML of all matches |
| `--click` | No | none | CSS selector to click before waiting (e.g. cookie dismiss). Can repeat. |

**Output:** Raw HTML to stdout. Pipe to `awk`/`grep`/`sed` as needed.

---

### anno-search.sh — ANNO Austrian Newspapers

Searches digitized Austrian newspapers (1700s–1940s) from the Austrian National Library. Good for finding birth/death/marriage announcements, obituaries, business notices, and legal mentions.

```bash
# Basic search
anno-search.sh Goldberg

# With year range
anno-search.sh Goldberg 1880 1930

# Quoted multi-word query
anno-search.sh "Abraham Goldberg" 1900 1940
```

**Arguments:**
| Arg | Required | Default | Description |
|-----|----------|---------|-------------|
| QUERY | Yes | — | Search term (use German spelling) |
| FROM_YEAR | No | 1880 | Start year |
| TO_YEAR | No | 1940 | End year |

**Output:** Tab-separated: `NEWSPAPER_AND_DATE\tPAGES\tHITS\tLINK`

**Tips:**
- Search in German — use period spelling ("Goldberg" not "Golberg")
- For common names, include a town or occupation in the query
- Best coverage: 1880s–1930s
- Most useful papers: Wiener Zeitung, Neue Freie Presse, Die Neuzeit (Jewish)

---

### arolsen-search.sh — Arolsen Archives (Holocaust Records)

Searches the Arolsen Archives collections for references to a name. Returns archive catalog entries showing which card file segments and collections contain potential matches. These are pointers into the archive — follow up by visiting the actual documents on `collections.arolsen-archives.org` for scanned originals with names, dates, and details.

```bash
# Surname only
arolsen-search.sh Goldberg

# Surname + given name
arolsen-search.sh Goldberg Abraham
```

**Arguments:**
| Arg | Required | Default | Description |
|-----|----------|---------|-------------|
| SURNAME | Yes | — | Family name |
| GIVEN_NAME | No | omitted | First name |

**Output:** Tab-separated: `REFERENCE\tRELEVANCE\tSEGMENT\tCOLLECTION`

**Tips:**
- Results are archive finding aid entries — they tell you WHERE to look, not person details
- Higher relevance scores (closer to 1.0) indicate stronger matches
- Use reference numbers to navigate directly to documents on the Arolsen website
- The Central Name Index is the primary index for person searches
- For person-level details (names, birth dates, camp records), visit the actual documents

---

## When to Use Which Script

| What You're Looking For | Script | Notes |
|------------------------|--------|-------|
| Existing family trees, connected relatives | `geni-search.sh` + `geni-family.sh` | JSON API, OAuth2 required |
| Newspaper mentions, obituaries, business ads | `anno-search.sh` | German-language Austrian papers |
| Holocaust persecution details beyond JewishGen | `arolsen-search.sh` | Camp docs, DP files, transport lists |
| Any other JavaScript SPA site | `browser-fetch.js` directly | Build your own extraction with awk/grep |
| JewishGen databases | Use existing `jg-*.sh` scripts | curl-based, no browser needed |

## Troubleshooting

- **"Cannot find module 'playwright'"** — Run `npm install` in project root
- **"Executable doesn't exist"** — Run `npx playwright install chromium`
- **Timeout errors** — The site may be slow or the wait selector may be wrong. Try increasing `--timeout` or adjusting the selector.
- **Empty results** — The site's DOM structure may have changed. Use `browser-fetch.js` without `--extract` to see the full page HTML, then update the wrapper script's selectors.
