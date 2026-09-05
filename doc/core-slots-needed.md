# Core slots the Trans Dimension theme needs

Everything The Trans Dimension design does that CSS over core's existing markup
cannot reach. The theme is CSS only: no forked views, no core changes, and no
copy invented with `content:`. Where a piece of TD is missing from a page, it is
missing on purpose and recorded here.

Each item names the core file, the element, what TD needs and the smallest
generic slot that would give it to every theme rather than to this one.

## Page templates (WP 2.4)

### 1. Day and month as separate elements on an event date

- **Core**: `app/components/event.rb`, `.event__detail.event__date`.
- **Element**: an inline calendar icon followed by one text node, " 3 Sep".
- **TD**: `src/Theme/Page/Events.elm` `eventDayStyle` / `eventMonthStyle` set the
  day number at 3.1rem in white over the month in 1.2rem pink allcaps.
- **Slot**: wrap the two parts, e.g.
  `<span class="event__date-day">3</span><span class="event__date-month">Sep</span>`,
  which changes nothing visually for existing themes.
- **Consequence today**: the theme narrows the date column until the month wraps
  and styles the first line with `::first-line`. It matches, but it depends on
  the wrap point rather than on the markup.

### 2. News meta as one line

- **Core**: `app/views/news/index.rb`, `.articles__aside` /
  `.articles__partners`.
- **Element**: the publication date sits in a fifth-width column before the
  body, and the partner name is a separate paragraph after the title.
- **TD**: `src/Theme/Page/News.elm` `newsItemMetaStyle` prints one line,
  "Partner name · 14th January 2025", under the title.
- **Slot**: render the byline as a single meta element containing both parts.
- **Consequence today**: the theme flattens the columns with `display: contents`
  and stacks partner and date as two lines instead of one.

## Page chrome (raised by WP 2.2)

### 3. Alt text for a themed header wordmark

- **Core**: `app/components/navigation.rb`, `render_branding`, `.header__branding`.
- **Element**: core inlines the PlaceCal SVG or the site's uploaded logo.
- **TD**: the wordmark is the site's identity and needs its own alt text.
- **Slot**: an alt/`aria-label` on the branding link that a site or theme can
  set.
- **Consequence today**: the theme hides the inlined mark and paints the TD
  wordmark as a background image, so it carries no accessible name. The same
  applies to the large wordmark above the page title, which the theme draws with
  `main::before` because `PageTemplate.elm`'s header lockup has no core element
  at all.

## Illustrations (WP 2.10)

### 4. A route or page identifier on the page

- **Core**: `app/views/layouts/application.rb`; `<body>` and
  `<main>` carry no class, id or data attribute naming the route or the static
  page being rendered.
- **Element**: none.
- **TD**: `src/Theme/PageTemplate.elm` gives `/about` its own header artwork
  (`about_1_header.png`, the generic band plus a character cut-out) and a set of
  section illustrations keyed to that page; `pageHeadingAboutStyle` is a
  separate style from `pageHeadingGenericStyle` for exactly this reason.
- **Slot**: a class or data attribute on `<body>` or `<main>` naming the
  controller and action, and the slug for the static pages, e.g.
  `<body class="route-pages-show" data-page="about">`. Every theme could then
  style one route without a forked view.
- **Status**: partly filled. Core's page slot renders the wrapper
  `page page--<slug>` with `data-page-slug`, and the theme's own page views
  (WP 3.12) emit the same wrapper, so `body main:has(.page--about)` can select
  the About band. The remaining gap is the other routes, which still carry no
  identifier.
- **Consequence today**: `/about` has its own header band, but none of the About
  page's own section artwork is drawn, and no other route can be styled singly.

## Laptop pass (WP 3.8)

Found while measuring the theme against transdimension.uk at 1440 and 1728.

### News card excerpt length

- **Core**: `app/helpers/articles_helper.rb`, `article_summary_text`, the
  `length: 200` argument to `truncate`.
- **TD**: the live summaries run to about 130 characters, which is exactly three
  lines in the card; 200 characters is four lines and makes the card 30px taller
  than the design.
- **What the theme can do**: clamp `.articles__body p` to three lines, which
  fixes the height but cuts mid-word instead of at a word boundary.
- **Smallest core change**: make the truncation length a constant on the helper
  (or read it from a locale key) so a theme can ask for 130.

## Head (WP 3.17)

### 5. Skip core's font preloads when the theme sets `font_stylesheet`

- **Core**: `app/views/layouts/application.rb`, the four unconditional
  `preload_font` calls for `rawline-500`, `rawline-700`, `rawline-800` and
  `Trocchi-Regular`.
- **Element**: four `<link rel="preload" as="font">` tags in every page head.
- **TD**: `theme.css` sets both `--font-sans` and `--font-serif` to
  `covik-sans`, loaded from the Typekit stylesheet core renders a few lines
  later from the theme's `font_stylesheet` setting. Neither rawline nor Trocchi
  renders anywhere on the site.
- **Slot**: skip the built-in preloads when a theme has set `font_stylesheet`,
  which is the point at which core knows the default faces have been replaced.
- **Consequence today**: every Trans Dimension page issues four high priority
  woff2 requests for faces nothing draws, competing with the Typekit request
  the theme does need. A theme cannot suppress them.
