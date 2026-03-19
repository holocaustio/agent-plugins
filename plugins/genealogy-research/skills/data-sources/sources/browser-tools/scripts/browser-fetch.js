#!/usr/bin/env node
// Generic headless browser fetch — renders JavaScript-heavy pages
// Usage: browser-fetch.js URL [--wait-for SELECTOR] [--timeout MS] [--extract SELECTOR] [--click SELECTOR]
//
//   URL         - required, page to load
//   --wait-for  - CSS selector to wait for before extracting (default: none)
//   --timeout   - max wait in ms (default: 15000)
//   --extract   - CSS selector to extract; returns outerHTML of all matches
//                 (default: return full page HTML)
//   --click     - CSS selector to click before waiting (e.g. cookie consent dismiss button)
//                 Silently ignored if element not found. Can be specified multiple times.
//
// Outputs rendered HTML to stdout. Designed for piping to awk/sed/grep.

// Resolve playwright from the plugin's own node_modules, regardless of cwd
const path = require('path');
const pluginRoot = path.resolve(__dirname, '..', '..', '..');
const { chromium } = require(path.join(pluginRoot, 'node_modules', 'playwright'));

function parseArgs(argv) {
  const args = { url: null, waitFor: null, timeout: 15000, extract: null, click: [] };
  const rest = argv.slice(2);
  const positional = [];

  for (let i = 0; i < rest.length; i++) {
    switch (rest[i]) {
      case '--wait-for':
        args.waitFor = rest[++i];
        break;
      case '--timeout':
        args.timeout = parseInt(rest[++i], 10);
        break;
      case '--extract':
        args.extract = rest[++i];
        break;
      case '--click':
        args.click.push(rest[++i]);
        break;
      case '--help':
        console.error('Usage: browser-fetch.js URL [--wait-for SELECTOR] [--timeout MS] [--extract SELECTOR] [--click SELECTOR]');
        process.exit(0);
        break;
      default:
        positional.push(rest[i]);
    }
  }

  args.url = positional[0];
  if (!args.url) {
    console.error('ERROR: URL is required.');
    console.error('Usage: browser-fetch.js URL [--wait-for SELECTOR] [--timeout MS] [--extract SELECTOR]');
    process.exit(1);
  }

  return args;
}

async function main() {
  const args = parseArgs(process.argv);
  let browser;

  try {
    browser = await chromium.launch({ headless: true });
    const context = await browser.newContext({
      userAgent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36',
    });
    const page = await context.newPage();

    await page.goto(args.url, {
      waitUntil: 'domcontentloaded',
      timeout: args.timeout,
    });

    // Click elements if requested (e.g. dismiss cookie consent banners)
    for (const selector of args.click) {
      try {
        await page.waitForSelector(selector, { timeout: 3000 });
        await page.click(selector);
        await page.waitForTimeout(500); // brief pause after click
      } catch {
        // Silently ignore — element may not exist on this page
      }
    }

    // Wait for specific element if requested
    if (args.waitFor) {
      await page.waitForSelector(args.waitFor, { timeout: args.timeout });
    }

    let html;
    if (args.extract) {
      // Return outerHTML of all matching elements
      const elements = await page.$$eval(args.extract, els =>
        els.map(el => el.outerHTML)
      );
      html = elements.join('\n');
    } else {
      html = await page.content();
    }

    process.stdout.write(html);
  } catch (err) {
    console.error(`ERROR: ${err.message}`);
    process.exit(1);
  } finally {
    if (browser) {
      await browser.close();
    }
  }
}

main();
