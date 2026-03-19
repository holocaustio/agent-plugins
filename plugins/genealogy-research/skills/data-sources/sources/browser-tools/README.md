# Browser Tools — Headless Browser for SPA Sites

Generic headless browser tool for searching archive websites that are JavaScript SPAs — sites where `curl` returns an empty shell because content is rendered client-side.

## Setup

Requires Node.js and Playwright. From the plugin directory:

```bash
cd ${CLAUDE_PLUGIN_ROOT}
npm install
npx playwright install chromium
```

## Script

`${CLAUDE_PLUGIN_ROOT}/skills/data-sources/sources/browser-tools/scripts/browser-fetch.js`

Renders any JavaScript-heavy page and outputs HTML to stdout.

```bash
node browser-fetch.js URL [--wait-for SELECTOR] [--timeout MS] [--extract SELECTOR] [--click SELECTOR]
```

| Flag | Default | Purpose |
|------|---------|---------|
| `--wait-for` | none | CSS selector to wait for before extracting |
| `--timeout` | 15000 | Max wait in ms |
| `--extract` | full page | CSS selector — returns outerHTML of all matches |
| `--click` | none | Click a selector before waiting (e.g. cookie consent). Repeatable. |

Uses `domcontentloaded` for page load (not `networkidle` — SPAs often never reach idle). The `--wait-for` flag is the primary mechanism for knowing when content is ready.

## Examples

```bash
# Full page HTML
node browser-fetch.js "https://example.com/search?q=test"

# Wait for results, then extract only matching elements
node browser-fetch.js "https://example.com/search?q=test" \
  --wait-for ".results" \
  --extract ".result-item" \
  --timeout 20000
```

## Troubleshooting

- **"Cannot find module 'playwright'"** — Run `npm install` in `${CLAUDE_PLUGIN_ROOT}`
- **"Executable doesn't exist"** — Run `npx playwright install chromium`
- **Timeout errors** — Site may be slow; increase `--timeout` or adjust the wait selector
- **Empty results** — Site DOM may have changed. Run `browser-fetch.js` without `--extract` to inspect the full rendered HTML, then update the wrapper script's selectors
