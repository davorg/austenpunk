# Austenpunk

> *Classic literature for modern software teams*

**Austenpunk** is a satirical catalogue of fake technical books whose titles parody
nineteenth-century novels — Jane Austen, the Brontës, Dickens, Wilde, and friends —
applied to the everyday anxieties of modern software engineering: CI/CD pipelines,
microservices, observability, and so on.

🌐 **Website:** <https://austenpunk.dev>  
📱 **TikTok:** [@austenpunk](https://www.tiktok.com/@austenpunk)

---

## How it works

The site is a [Jekyll](https://jekyllrb.com/) static site deployed to
[GitHub Pages](https://pages.github.com/). All book data lives in
`_data/books.yml`. A new book is published automatically every day via a
GitHub Actions workflow that flips the `live` flag on any book whose
`published` date has arrived.

## Running locally

```bash
bundle install
bundle exec jekyll serve
```

The site is then available at <http://localhost:4000>.

## Adding a new book

1. Add an entry to `_data/books.yml` with `live: false` and a future
   `published` date.
2. Place a portrait PNG cover image at `assets/images/covers/{slug}.png`.

The daily publish workflow will automatically set `live: true` on the
book's publication date. To publish immediately, set `live: true` and use
today's date.

## Technology stack

| Layer | Technology |
|---|---|
| Site generator | Jekyll (Ruby) |
| Templating | Liquid |
| Book data | YAML (`_data/books.yml`) |
| Styles | Plain CSS |
| Hosting | GitHub Pages |
| Automation scripts | Perl (`bin/`) |

## Licence

Content and code © [Dave Cross](https://davecross.co.uk/). All rights reserved.
