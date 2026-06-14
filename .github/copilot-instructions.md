# Copilot Instructions for Austenpunk

## What This Repository Is

**Austenpunk** is a Jekyll static site deployed to GitHub Pages at <https://austenpunk.dev>.
It presents a catalogue of satirical fake technical books whose titles parody 19th-century
novels (Jane Austen, the Brontë sisters, Dickens, Wilde, etc.) applied to software engineering
topics (CI/CD, microservices, observability, and so on). One new book is published daily via
an automated workflow.

---

## Technology Stack

| Layer | Technology |
|---|---|
| Site generator | [Jekyll](https://jekyllrb.com/) (Ruby) |
| Templating | Liquid |
| Data | YAML (`_data/`) |
| Styles | Plain CSS (`assets/css/site.css`) |
| Hosting | GitHub Pages |
| Automation scripts | Perl (`bin/publish_queued_books`, `bin/check_upcoming`, and `bin/mk_video`) |

Build requires Ruby 3.4 and Bundler. Dependencies are declared in `Gemfile`
(`jekyll`, `webrick`, `jekyll-sitemap`).

---

## Repository Structure

```
_config.yml                  Jekyll configuration (site title, URL, plugins)
_data/
  books.yml                  All books, using `live: true` for published entries and future `published` dates for scheduled books
_includes/
  book-card.html             Reusable card component used on the homepage grid
_layouts/
  default.html               Base layout: header, footer, Google Analytics, structured data (JSON-LD)
  book.html                  Individual book page layout
_plugins/
  book_pages.rb              Jekyll generator — creates one page per book from _data/books.yml
assets/
  css/site.css               All site CSS
  images/
    covers/                  PNG cover images, one per book, named {slug}.png
    og_image.png             Shared Open Graph / Twitter card image
bin/
  publish_queued_books       Perl script: flips due books from `live: false` to `live: true`
  check_upcoming             Perl script: lists scheduled books and flags missing cover images
  mk_video                   Perl script: generates TikTok-style MP4 videos per book
index.html                   Homepage: hero (latest book) + 3-book grid + about blurb
books.html                   /books/ listing of all live books (alphabetical by title)
feed.xml                     RSS feed
CNAME                        GitHub Pages custom domain (austenpunk.dev)
```

---

## Book Data Schema

Every book entry uses these fields:

| Field | Type | Notes |
|---|---|---|
| `slug` | string | URL-safe identifier; also the cover image filename (`assets/images/covers/{slug}.png`) |
| `live` | boolean | `true` once published, `false` while still scheduled |
| `title` | string | Full punny title |
| `subtitle` | string | Secondary title line |
| `author` | string | The fictional (classical) author name |
| `topic` | string | Software engineering subject (e.g. "CI/CD", "Observability") |
| `published` | date string | ISO 8601 (`YYYY-MM-DD`); used for both published and scheduled books |
| `teaser` | string | Short 1–2 sentence promo shown on book cards |
| `blurb` | string | Longer paragraph shown on the book detail page |
| `pullquote` | string | Fake review quote, double-quoted, ends with `\n` |
| `contents` | list of strings | Chapter titles (usually 4 entries) |

### YAML style conventions
- `books.yml` is kept in `published` date order.

---

## How to Add a New Book

1. **Write the entry** — add it to `_data/books.yml` with `live: false` and
   the future `published` date when it should go live.
2. **Add the cover image** — place a PNG file at `assets/images/covers/{slug}.png`
   (portrait orientation, consistent with existing covers).
3. The daily publish workflow will automatically flip `live` to `true` on its `published` date.

To publish immediately, add the entry directly to `_data/books.yml` with
`live: true` and `published: YYYY-MM-DD`.

---

## Publishing Workflow (Automation)

### Daily publish cron (`.github/workflows/publish-new-book.yml`)
- Runs at 00:10 UTC every day.
- Executes `perl bin/publish_queued_books` which:
  - Reads `_data/books.yml`.
  - Flips `live` to `true` for books whose `published` date is today or earlier.
  - Writes the updated file back.
- Commits and pushes the updated YAML file.
- Triggers the pages build workflow if any books were published.

### Site deployment (`.github/workflows/pages.yml`)
- Triggers on push to `main` or via `workflow_dispatch`.
- Builds with `bundle exec jekyll build` (Ruby 3.4, `bundler-cache: true`).
- Uploads `_site/` artifact and deploys to GitHub Pages.

---

## How to Build and Run Locally

```bash
bundle install
bundle exec jekyll serve
# Site available at http://localhost:4000
```

There are no automated tests in this repository. Validation is done by building the site
and visually inspecting it.

---

## Video Generation (`bin/mk_video`)

A Perl script that creates TikTok-style promotional MP4 videos. It is **not** part of the
automated CI/CD pipeline — it is run manually by the site owner.

**Dependencies (must be installed locally):**
- Perl with modules: `JSON::PP`, `YAML::XS`, `HTTP::Tiny`, `Path::Tiny`, `DateTime`
- `ffmpeg` and `ffprobe` in PATH
- Environment variables: `OPENAI_API_KEY`, `ELEVENLABS_API_KEY`, `ELEVENLABS_VOICE_ID`

**Usage:**
```bash
perl bin/mk_video <book-slug>
```

**Process:**
1. Looks up the book in `_data/books.yml` by slug.
2. Generates a ~75-word deadpan voiceover script via OpenAI (`gpt-5.5`).
3. Synthesises audio via ElevenLabs TTS (`eleven_multilingual_v2`).
4. Combines the cover image (`assets/images/covers/{slug}.png`) with the audio using
   `ffmpeg` to produce `tmp/{slug}.mp4`.

Intermediate files (`tmp/{slug}.txt`, `tmp/{slug}.mp3`) are cached in `tmp/` to allow
re-running partial steps. The `tmp/` directory is gitignored.

---

## URL Structure

| URL | Content |
|---|---|
| `/` | Homepage: hero card (latest live book) + 3-book grid |
| `/books/` | Alphabetical index of all live books |
| `/books/{slug}/` | Individual book detail page |
| `/feed.xml` | RSS feed |

---

## Important Notes for Agents

- **Cover images are mandatory.** Every book entry must have a corresponding PNG at
  `assets/images/covers/{slug}.png`. The site will render broken image tags otherwise.
- **Only books with `live: true` appear on the public site.** The `BookPageGenerator` plugin
  in `_plugins/book_pages.rb` reads `_data/books.yml` and filters out scheduled books.
- **The `slug` field determines the URL, filename, and cover path** — it must be unique,
  lowercase, hyphen-separated, and URL-safe.
- **No tests exist.** The only validation is a successful `bundle exec jekyll build`.
- **Do not commit secrets.** The `mk_video` script requires API keys that should only ever
  be passed via environment variables, never stored in the repo.
- **`bin/publish_queued_books` is idempotent.** Running it multiple times on the same day
  is safe.
- **The site uses British English** (e.g., `lang="en-GB"`, footer copy uses British idiom).
  New content should follow suit.
