# Core slots the Trans Dimension theme needs

Everything The Trans Dimension design does that CSS over core's existing markup
cannot reach. The theme is CSS only: no forked views, no core changes, and no
copy invented with `content:`. Where a piece of TD is missing from a page, it is
missing on purpose and recorded here.

Each item names the core file, the element, what TD needs and the smallest
generic slot that would give it to every theme rather than to this one.

## Page templates (WP 2.4)

### 1. Intro panel on the listing pages

- **Core**: `app/views/events/index.rb`, `app/views/partners/index.rb`,
  `app/views/news/index.rb`, via `app/components/hero.rb`.
- **Element**: none. `Components::Hero` renders a kicker (`h4.allcaps`) and the
  page title, and nothing else.
- **TD**: `src/Theme/PageTemplate.elm` puts a pink panel (`textBoxPinkStyle`) at
  the top of the content box on every listing, holding a heading in intro type
  ("Upcoming events & activities for you.", "The Trans Dimension is a
  partnership of grassroots groups...", "Updates & articles from our partners.")
  and, on `/partners`, a second paragraph of standfirst copy under it.
- **Slot**: an optional lede region on the index views, rendered inside the
  listing container when a site supplies it, for example a `lede` slot on
  `Components::Hero` (`Hero(title, kicker:) { lede }`) filled from site or page
  content. Themes that pass nothing keep today's output.
- **Consequence today**: the panel is absent from `/events`, `/partners` and
  `/news`; the page title stays on the starfield above the box.

### 2. Section name above the item title on the show pages

- **Core**: `app/views/events/show.rb`, `app/views/partners/show.rb`,
  `app/views/news/show.rb`, via `app/components/hero.rb`.
- **Element**: the hero renders the site strapline as its kicker and the item
  name as `h1`.
- **TD**: the section name ("Events", "Partners", "News") sits on the starfield
  above the box, with the item name inside the box below it.
- **Slot**: let the show views pass their section name as the hero kicker (a
  `kicker:` argument the view sets, defaulting to the strapline as now), so a
  theme can style "the small line above the title" as a section label.
- **Consequence today**: the strapline is hidden inside the panel and no section
  name is shown on show pages.

### 3. Day and month as separate elements on an event date

- **Core**: `app/components/event.rb`, `.event__detail.event__date`.
- **Element**: one text node, "3 Sep".
- **TD**: `src/Theme/Page/Events.elm` `eventDayStyle` / `eventMonthStyle` set the
  day number at 3.1rem in white over the month in 1.2rem pink allcaps.
- **Slot**: wrap the two parts, e.g.
  `<span class="event__date-day">3</span><span class="event__date-month">Sep</span>`,
  which changes nothing visually for existing themes.
- **Consequence today**: the theme narrows the date column until the month wraps
  and styles the first line with `::first-line`. It matches, but it depends on
  the wrap point rather than on the markup.

### 4. Heading above the partners list

- **Core**: `app/views/partners/index.rb`.
- **Element**: none; the list follows the filters directly.
- **TD**: `src/Theme/Page/Partners.elm` `partnersListTitleStyle` prints "ALL
  PARTNERS" (or the filtered region's name) above the list.
- **Slot**: render the list's own heading in the view (visually hidden by
  default if core does not want it), so themes can show it.
- **Consequence today**: no heading is drawn.

### 5. News meta as one line

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

### 6. Footer social links

- **Core**: `app/components/footer.rb`.
- **Element**: none. The footer has navigation, enquiries, supporters and
  impressum blocks and no social accounts.
- **TD**: `src/Theme/PageFooter.elm` shows an "FOLLOW US OUT THERE" band with
  Instagram, Twitter and Facebook icon links.
- **Slot**: a social links block rendered from the site's own social fields.
- **Consequence today**: the band is absent.

### 7. "Created by" logos

- **Core**: `app/components/footer.rb`, `.footer__supporters`.
- **Element**: a supporters list of logos, empty for this site.
- **TD**: the "CREATED BY" band shows the Geeks for Social Change and Gendered
  Intelligence logos with a "+" between them.
- **Slot**: the supporters list already fits; it needs the site's own logo
  entries rather than a markup change, plus an optional separator. Recorded here
  because the band is empty until the data exists.
- **Consequence today**: the heading renders over an empty list.

### 8. "Powered by PlaceCal" as an image element

- **Core**: `app/components/footer.rb`, `.footer__impressum`.
- **Element**: none; the credit is text in the build line.
- **TD**: `poweredByPlaceCalStyle` draws the PlaceCal lockup as an image.
- **Slot**: render the credit as an `<img>` (or an element with a class) inside
  the impressum block.
- **Consequence today**: the theme hangs the artwork off `.footer__impressum`
  with an empty `::after`, which is decoration with no accessible name.

### 9. "Menu" label on the mobile header toggle

- **Core**: `app/components/header.rb`, `.header__toggle`.
- **Element**: an icon-only button.
- **TD**: `src/Theme/PageHeader.elm` labels the button "Menu" next to the icon.
- **Slot**: render the label text in the button (visually hidden by default).
- **Consequence today**: the mobile header shows the icon alone. The theme will
  not fake the word with `content:`.

### 10. Alt text for a themed header wordmark

- **Core**: `app/components/header.rb`, `.header__branding`.
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

### 11. A route or page identifier on the page

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
- **Consequence today**: `/about` takes the same generic header band as the rest
  of the inner pages, and none of the About page's own section artwork is drawn.

## Laptop pass (WP 3.8)

Found while measuring the theme against transdimension.uk at 1440 and 1728.

### News card byline: one line, no full stop

- **Core**: `app/views/news/index.rb`, `render_article_card`.
- **Element**: `p.articles__partners` renders `article_partner_links(article)`
  followed by a bare `plain '.'` text node, and `p.articles__published` is a
  separate element inside a different wrapper (`.articles__aside`).
- **TD**: News.elm prints one meta line, "Geeks for Social Change • 14th January
  2025", with no full stop.
- **What the theme can do**: the card grid now places the two paragraphs in
  their own pair of columns so they sit on one line, and adds the bullet with a
  `::before`. It cannot remove the full stop: a bare text node is not
  selectable.
- **Smallest core change**: drop `plain '.'` from `render_article_card` in
  `app/views/news/index.rb` (the trailing stop is a core style choice, not data),
  or move it into a locale key so a theme can blank it.

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
