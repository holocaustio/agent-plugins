---
name: data-sources
description: >-
  Database access for genealogy research — JewishGen, Yad Vashem, Holocaust.cz,
  GenTeam, ANNO, Arolsen Archives, Geni.com, JRI-Poland, FamilySearch.
  Use when running searches, authenticating, parsing results, or using helper scripts.
  Covers APIs, URL construction, rate limiting, concurrency rules, and headless browser tools.
  NOT for research strategy or file organization (use research-methodology skill instead).
metadata:
  author: DeanLa
  version: 1.0.0
---

# Genealogy Data Sources

This skill covers all database access for genealogy research: authentication, search APIs, URL construction, result parsing, rate limiting, and helper scripts. Each source has its own subdirectory with a README and any scripts.

## Source Routing Table

| Source | What It Provides | Auth | Subdirectory |
|--------|-----------------|------|-------------|
| **JewishGen** | 80+ databases: births, marriages, deaths, Holocaust, burial, emigration | Auth0 (`$JG_USER`/`$JG_PASS`) | `sources/jewishgen/` |
| **Yad Vashem** | Pages of Testimony, transport lists, camp records (JSON API) | None | `sources/yad-vashem/` |
| **Holocaust.cz** | Czech transport details, Terezín records, deportation chains | None | `sources/holocaust-cz/` |
| **GenTeam.at** | Austrian Jewish vital records, gravestones, obituaries | Login (`$GT_USERNAME`/`$GT_PASSWORD`) | `sources/genteam/` |
| **ANNO** | Digitized Austrian newspapers (1700s–1940s) | None | `sources/anno/` |
| **Arolsen Archives** | Holocaust archive finding aid pointers | None | `sources/arolsen/` |
| **JRI-Poland** | Polish vital records: births, marriages, deaths, divorces, Holocaust | JewishGen auth (`$JG_USER`/`$JG_PASS`) | `sources/jri-poland/` |
| **FamilySearch** | Microfilmed original registers: Vienna IKG, Galician civil, Czech matriky. Catalog-based (browse, not search by name) | Free account (no API) | `sources/familysearch/` |
| **Geni.com** | World Family Tree: existing trees, family connections, ancestor chains | OAuth2 (`$GENI_CLIENT_ID`/`$GENI_CLIENT_SECRET`) | `sources/geni/` |
| **Browser Tools** | Generic headless browser for JavaScript SPA sites | None | `sources/browser-tools/` |

## Concurrency Rules

- **JewishGen + JRI-Poland: SERIAL only.** All JewishGen and JRI-Poland scripts share `/tmp/jg_cookies.txt`. Never run parallel curls — corrupts the session. Run searches one at a time; the scripts auto-throttle (3-6s randomized delays).
- **GenTeam: SERIAL only.** Shared cookie file `/tmp/genteam_cookies.txt`. Use 5-10 second delays between requests.
- **All other sources: PARALLEL OK.** Yad Vashem, Holocaust.cz, ANNO, Arolsen, and Geni.com use independent sessions with no cookie conflicts. They can run in parallel with each other and with JewishGen/GenTeam.
- **Maximize parallelism:** When dispatching research for a person, spawn one researcher for JewishGen and another for non-JewishGen sources simultaneously.

## Playwright Setup (for browser-based sources)

Some archive sites (ANNO, Arolsen) are JavaScript SPAs that need a headless browser. From the plugin directory:

```bash
cd ${CLAUDE_PLUGIN_ROOT}
npm install
npx playwright install chromium
```

The generic browser tool is at `${CLAUDE_PLUGIN_ROOT}/skills/data-sources/sources/browser-tools/scripts/browser-fetch.js`.

## Learning & Discovery (Two-Tier Pattern)

This skill learns from every research session. New databases, parsing patterns, and techniques are accumulated **locally per project** — the plugin's own files stay read-only (safe for global/shared installs).

### How it works

```
READ from both:
  ${CLAUDE_PLUGIN_ROOT}/skills/data-sources/sources/jewishgen/references/  ← built-in (read-only)
  .discoveries/                                                            ← local (writable, per-project)

WRITE only to:
  .discoveries/                                                            ← local
```

### Local discoveries directory

Agents create `.discoveries/` in the project root on first use:

```
.discoveries/
  database-catalog.md       # New df values found during research
  html-patterns.md          # New column layouts and parsing quirks
  url-parameters.md         # New region codes, params, endpoints
  deduction-techniques.md   # New cross-referencing patterns that worked
  gotchas.md                # New failure modes and workarounds
```

### What agents discover and record

| Discovery | Write to | How |
|-----------|----------|-----|
| New database `df` value from unified search | `.discoveries/database-catalog.md` | Append table row |
| New column layout in a database's HTML | `.discoveries/html-patterns.md` | Append section |
| New region code seen in results | `.discoveries/url-parameters.md` | Append to list |
| New URL parameter or endpoint behavior | `.discoveries/url-parameters.md` | Append to list |
| New gotcha or workaround | `.discoveries/gotchas.md` | Append entry |
| New cross-referencing technique | `.discoveries/deduction-techniques.md` | Append entry |

### Rules for discoveries

1. **Always check both locations** before searching — read the built-in catalog AND `.discoveries/database-catalog.md`
2. **Write only to `.discoveries/`** — never modify files under `${CLAUDE_PLUGIN_ROOT}/`
3. **Include provenance** — note which subject and date discovered the entry
4. **Verify before writing** — only add a `df` value if it returned actual results
5. **De-duplicate across both tiers** — grep both the built-in file and the local file before appending
6. **Keep format consistent** — match the built-in file's format so promotion is easy

### Promoting discoveries (maintainer workflow)

Run `/promote-discoveries` to merge local findings into the plugin's built-in references. This is for the plugin maintainer — it reads `.discoveries/`, merges into the skill files, and clears the local files.

## Troubleshooting

### JewishGen auth fails
- Check `$JG_USER`/`$JG_PASS` env vars are set
- Delete stale cookie: `rm /tmp/jg_cookies.txt`
- Re-run `/login`

### Rate limiting / 429 errors
- JewishGen: scripts auto-throttle 3-6s; if still hit, increase delay in jg-throttle.sh
- GenTeam: increase delay to 10-15s between requests

### HTML parsing returns empty results
- Check `.discoveries/html-patterns.md` for known layout changes
- If new layout found, record it in `.discoveries/html-patterns.md`
- Verify the database `df` value is correct in the catalog

### Headless browser fails to load
- Run `cd ${CLAUDE_PLUGIN_ROOT} && npx playwright install chromium`
- Check if site is behind Cloudflare/CAPTCHA (manual intervention needed)
