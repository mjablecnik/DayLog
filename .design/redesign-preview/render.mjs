// Renders every mockup phone of the redesign preview to PNG, in the light and the
// dark theme, into renders/<theme>/<name>.png. The PNGs are the visual reference
// of specs 004-006; regenerate them after editing a preview page.
//
// Set CHROMIUM_PATH when the pre-installed Chromium lives elsewhere.
// Run from the DayLog project root (Playwright comes from a sibling project,
// Chromium is pre-installed in the sandbox; never run `playwright install`):
//   NODE_PATH=../WorkLog/node_modules node .design/redesign-preview/render.mjs
import { createRequire } from 'node:module';
import { mkdirSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';

const require = createRequire(import.meta.url);
const { chromium } = require('playwright');

const here = dirname(fileURLToPath(import.meta.url));
const pages = ['round2.html', 'index.html'];
const themes = ['light', 'dark'];

/** Name of one mockup, from the data attributes the preview pages set. */
function nameScript() {
  const out = [];
  document.querySelectorAll('.pf').forEach((pf) => {
    if (pf.id === 'proto1' || pf.id === 'proto2') return;
    const scr = pf.querySelector(':scope > .scr');
    if (!scr) return;
    let name = null;
    const d = scr.dataset;
    if (d.m) name = `r3-${d.m}`;
    else if (d.screen) {
      name = 'r2-' + (d.variant ? `nav${d.variant}-` : '') + d.screen + (d.sheet ? '-sheet' : '') + (d.overlay ? `-${d.overlay}` : '');
    } else if (pf.closest('#tloustka')) {
      const label = pf.parentElement.querySelector('b')?.textContent ?? '';
      name = `r2-title-weight-${label.split(' ')[0]}`;
    }
    if (name) {
      pf.setAttribute('data-render', name);
      out.push(name);
    }
  });
  return out;
}

const executablePath = process.env.CHROMIUM_PATH ?? '/opt/playwright-browsers/chromium-1255/chrome-linux64/chrome';
const browser = await chromium.launch({ executablePath });
const context = await browser.newContext({ viewport: { width: 1400, height: 900 }, deviceScaleFactor: 2.7 });
const page = await context.newPage();
for (const file of pages) {
  await page.goto(pathToFileURL(join(here, file)).href);
  await page.waitForLoadState('load');
  await page.waitForTimeout(1500);
  const names = await page.evaluate(nameScript);
  for (const theme of themes) {
    await page.evaluate((t) => { document.getElementById('mocks').dataset.app = t; }, theme);
    const dir = join(here, 'renders', theme);
    mkdirSync(dir, { recursive: true });
    for (const name of names) {
      await page.locator(`[data-render="${name}"]`).screenshot({ path: join(dir, `${name}.png`) });
    }
  }
  console.log(`${file}: ${names.length} mockups x ${themes.length} themes`);
}
await browser.close();
