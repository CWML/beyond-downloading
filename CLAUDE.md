# Beyond Downloading

Course website for "Beyond Downloading: Automating Data Retrieval with APIs and Web Scraping" (Cushing/Whitney Medical Library, Yale). Live at <https://cwml.github.io/beyond-downloading/>, served by GitHub Pages from `docs/` on `main`. It matches the CWML R Hands-on Workshop and All of Us sites.

## Where things live

- `index.qmd`, `pages/`: the website pages (setup, lessons, resources, archive, instructor guide)
- `APIs/`: Lesson 1 slides (`APIs.qmd`) and live demo (`API_demonstration.qmd`)
- `web_scraping/`: Lesson 2 slides (`web_scraping.qmd`), live demo (`web_scraping_demonstration.qmd`), and `scraping_using_playwright.py`
- `styles.css` (website) and `slides.css` (both decks): accessibility CSS
- `_quarto.yml`: navigation, sidebars, theme, and the explicit `render:` list

APIs is Lesson 1 and web scraping is Lesson 2 (the slides say to prefer APIs over scraping).

## Building

1. Stop `quarto preview` if it is running (running it alongside `quarto render` breaks the render).
2. `quarto render`
3. Commit `docs/` with the source changes. `docs/` is generated: never edit it by hand.

The site **shows the demo code without running it** (`execute: eval: false` in `_quarto.yml`), because the demos call live websites and the Census API needs a key. To test a demo, extract the code with `knitr::purl()` and run it in a scratch folder, so the `covid_*` snapshots and CSVs it writes don't land in the repo.

The slide decks use `embed-resources: true`, so each renders to one downloadable HTML file.

## Accessibility rules

- Alt text on every image (`{fig-alt="..."}`). QR codes also need a clickable text link.
- Email addresses are `mailto:` links, never plain text or code.
- Keep the contrast CSS in `styles.css` and `slides.css`.
- Before publishing, check text contrast (at least 4.5:1) in light mode, dark mode, and on every slide.

## Private: never commit

`OLD/`, the `notes/` folders, `web_scraping/downloads/`, the `covid_*` output files, and API keys (`.Renviron`).

## Keep in sync

- **Wikipedia XPaths**: the demo snippets, the Case Study 1 slide, the Clarity prompt at the end of the demo, and the Session 2 instructor notes. Teach Chrome's **Copy XPath** (short, ID-based, works with `read_html()`), not **Copy full XPath** (matches the browser's DOM after JavaScript, finds nothing in R). The heading-based XPath in Snippet 1 is the fallback if the IDs change.
- **Survey link** (`yalesurvey.ca1.qualtrics.com/jfe/form/SV_cZOk3RQmTrQLhYy`): last slide of both decks and both lesson pages.
- **Feedback email** (`maximilian.wegener@yale.edu`): navbar and footer in `_quarto.yml`, last slide of both decks.
- **Sessions** (both about 120 minutes): Instructor Guide overview table and the session pages.
- **Archive**: at the end of a term, follow the steps in `pages/instructor/index.qmd` and update `pages/archive.qmd`.
- The Python script appears on the demo page automatically (read at render time), so edit only the `.py` file.
