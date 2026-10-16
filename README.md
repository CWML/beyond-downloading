# Beyond Downloading

Automating data retrieval with APIs and web scraping: a practical guide for biomedical and public health researchers, from the Yale Cushing/Whitney Medical Library.

**Website:** <https://cwml.github.io/beyond-downloading/>

## What's here

| Folder | Contents |
|---|---|
| `index.qmd`, `pages/` | Website pages: home, setup, lessons, resources, archive, instructor guide |
| `APIs/` | Lesson 1 slides (`APIs.qmd`) and live demo (`API_demonstration.qmd`) |
| `web_scraping/` | Lesson 2 slides (`web_scraping.qmd`), live demo (`web_scraping_demonstration.qmd`), and the Playwright script |
| `archive/` | Copies of slides from past offerings |
| `docs/` | The rendered website served by GitHub Pages (generated; don't edit by hand) |

## Building the site

```bash
quarto render    # rebuild everything into docs/
quarto preview   # live preview while editing
```

Commit `docs/` along with your changes. See the [Instructor Guide](https://cwml.github.io/beyond-downloading/pages/instructor/) for how to archive slides at the end of a term.

Created by Max Wegener, Cushing/Whitney Medical Library, Yale School of Medicine.
