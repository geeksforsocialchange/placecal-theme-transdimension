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

## Final designs (2026-09-08)

### 6. A region segmented control in the nav bar

- **Core**: `app/components/navigation.rb`, `render_menu` / `menu_nav_classes`.
  The component takes only `navigation` (an array of `[label, path]` tuples)
  and `site`; it has no concept of a site region at all, and no extra slot
  next to the menu or the theme CTA (`Current.theme.nav_cta`, rendered by
  `render_theme_cta`) for a theme to hang an unrelated control on.
- **Element**: `reference/components/navigation/NavBar.jsx.txt` and
  `screens/02-events-index.png` show a pink-bar segmented control (Everywhere
  / London / Manchester) sitting in the nav itself, to the left of Donate, on
  every listing page.
- **TD**: `README.md` "Grid & spacing" and the events/partners screens draw the
  region choice as chrome, not page content: it belongs in the bar with the
  other nav links, and should persist across a nav from one route to another.
- **Slot**: a named region in `Components::Navigation` (for example a
  `region_control` render override, the same shape as `nav_cta`) that a theme
  can populate, or at minimum an unstyled `<li>` slot next to the CTA that a
  theme's own component can render into.
- **Consequence today**: there is no way to reach the nav bar's own markup
  from theme CSS or a theme component, so the region choice is instead
  rendered as `Components::RegionFilter` inside the page body (the pink
  intro-panel / event-box `.region-filter` in `app/tailwind/pages.css`,
  `app/tailwind/home.css`, wired up from `app/views/transdimension/home.rb`)
  rather than in the nav. It is fully functional: it filters events, persists
  the choice in the URL, and Turbo-swaps in place, it just is not where the
  Final designs draw it.

### 7. A "Pick a date" toggle alongside the events day strip

- **Core**: `app/components/event_filter.rb` `view_template`; it renders
  either the day strip or the date picker, chosen once by
  `Current.theme.event_filter_style == :day_strip`, never both.
- **Element**: `screens/02-events-index.png` shows two centred allcaps
  toggles side by side, "FILTER EVENTS +" and "PICK A DATE +", either of
  which can be open (only one at a time).
- **TD**: `reference/ui_kit/Final.jsx.txt` `EventsF`; the day strip and the
  date picker are both reachable from the same page.
- **Slot**: an `EventFilter` mode that renders the day strip and a
  same-styled toggle for the date picker together, rather than the two being
  mutually exclusive on `event_filter_style`.
- **Consequence today**: TD is configured for `:day_strip` (matching D22's
  day-by-day browsing) and has no way to add a "Pick a date" toggle next to
  it; the date picker path is simply unreachable while the day strip is
  active.

### 8. Select-style controls for the events filters

- **Core**: `app/components/event_filter.rb` `render_neighbourhood_filter` /
  `render_sort_filter`, and `app/components/filter.rb`; both render
  `Components::Filter` (a toggle button plus a Stimulus dropdown of radio
  buttons) for neighbourhood and for sort/period/repeating. There is no
  category filter for events at all, and nothing here renders a native
  `<select>`.
- **Element**: `screens/02-events-index.png` shows a 4-up row of
  select-looking controls, Neighbourhood, Category, Repeating, Sort, opened
  by "FILTER EVENTS +".
- **TD**: `reference/ui_kit/Final.jsx.txt` `EventsF` `FilterRow`.
- **Slot**: a `<select>` rendering mode for `Components::Filter`, and an
  events-side category facet to match the partner-side one that already
  exists.
- **Consequence today**: the theme keeps core's toggle-and-radio-group
  filters, styled to look as close to the select design as CSS allows, and
  has no category filter to offer at all.

### 9. A CSV export link on the events index

- **Core**: `app/components/meta.rb`; `Components::Meta` renders a permalink
  link and whatever is passed to `with_link`, nothing else. Only the partner
  page's meta section adds a CSV export link today.
- **Element**: `screens/02-events-index.png` shows "Subscribe with iCal" and
  "Download as CSV" as a pair of small dark buttons below the box on the
  events index.
- **TD**: `reference/ui_kit/Final.jsx.txt` `EventsF`.
- **Slot**: a CSV export path passed to `Components::Meta` on the events
  index, the same way the partner page already supplies one.
- **Consequence today**: the events index shows only the iCal subscribe
  link; there is no CSV link to style or point at.

### 10. A region-aware events standfirst

- **Core**: `config/locales/en.yml` `events.index.standfirst`; the key takes
  no interpolation token for a selected region.
- **Element**: `README.md` "Screens" §2: "Events & activities upcoming in
  {your area|region}."
- **TD**: `screens/02-events-index.png`.
- **Slot**: a `%{region}` token on `events.index.standfirst`, defaulting to
  "your area" when no region is selected.
- **Consequence today**: `theme_overrides.transdimension.events.index.standfirst`
  is a single fixed string, "Events & activities upcoming in your area.",
  regardless of the region a visitor has picked.

### 11. A search field on the partners index filter row

- **Core**: `app/components/partner_filter.rb`; the component has no search
  input at all, only the existing dropdown filters.
- **Element**: `screens/04-partners-index.png` shows a mauve-filled search
  field, 220px wide, at the end of the filter row.
- **TD**: `README.md` "Screens" §4.
- **Slot**: a search input in `Components::PartnerFilter`, wired to the
  existing partner query.
- **Consequence today**: the partners filter row has no search field to
  style; the theme cannot add one without a forked view.

### 12. A separate label and value in the Filter toggle button

- **Core**: `app/components/filter.rb` `render_toggle`; the single
  `span.filters__link` node carries `button_text`, which already combines
  the filter's label and its selected value ("Sort: Time" as one string).
- **Element**: `screens/02-events-index.png` and `04-partners-index.png` show
  an allcaps grey label ("SORT") and a separate pink value ("TIME") as two
  visually distinct pieces of the same toggle.
- **TD**: `reference/components/*` Select/Filter component styles.
- **Slot**: two child nodes inside the toggle span, one for the label and
  one for the value, so a theme can colour and case them independently.
- **Consequence today**: the theme can style the toggle text as a whole but
  cannot split label from value; both render in the same colour and case.

### 13. A back-to-index kicker on the event and partner show pages

- **Core**: `app/components/hero.rb`; the component takes `title`, `subtitle`,
  `schema`, `standfirst`, `standfirst_detail` and `section`, with no slot for a
  link back to the listing page.
- **Element**: `reference/ui_kit/Final.jsx.txt` `EventF` (and `PartnerF`) open
  the pink title panel with a small caps "← All events" / "← All partners"
  link above the `h1`, reusing `ShellF`'s `back` prop.
- **TD**: `screens/03-event-show-full.png` and `05-partner-show-full.png`; the
  design replaces the starfield section name with this kicker on both show
  pages. The news article show page needs the same "← All news" kicker.
- **Slot**: an optional `back` prop on `Components::Hero` (label + path)
  rendered as a link above the title, the same shape as the React prototype's
  `ShellF back={{ label, href }}`.
- **Consequence today**: `.event--full .hero__section` is hidden
  (`app/tailwind/event-show.css`) with nothing put in its place, the panel
  opens straight on the `h1`, one row shorter than the design. The article
  page's `Breadcrumb` trail stands in for the kicker instead.

### 14. A Directions link under the partner address

- **Core**: `app/components/address.rb`; `Components::Address` renders one
  `<p>` of formatted address lines and nothing else.
- **Element**: `screens/05-partner-show-full.png` shows a "Directions" link
  under the address block on the partner show page.
- **TD**: `README.md` "Screens" §5.
- **Slot**: an optional directions link (a maps URL built from the address)
  rendered after the address lines.
- **Consequence today**: there is no Directions link on the page for the
  theme to style.

### 15. Visit website / Email / Call as buttons

- **Core**: `app/components/contact_details.rb`; `Components::ContactDetails`
  renders a row of icon links with no per-link class to distinguish website
  from email from phone.
- **Element**: `screens/05-partner-show-full.png` shows "Visit website"
  styled as a pink button and "Email" / "Call" as dark buttons.
- **TD**: `README.md` "Grid & spacing", button styles.
- **Slot**: a class per contact type (`contact-details__website`,
  `contact-details__email`, `contact-details__phone`) on
  `Components::ContactDetails`' links.
- **Consequence today**: the theme cannot select one contact link from
  another with CSS, so all three render identically instead of as
  differently-styled buttons.

### 16. An "Upcoming partner events" heading and count on partner show

- **Core**: `app/views/partners/show.rb` `render_local_layout`; the events
  browser frame is rendered with no heading and no count above it.
- **Element**: `screens/05-partner-show-full.png` shows "UPCOMING PARTNER
  EVENTS" with an "N events across M days" count on the same row.
- **TD**: `README.md` "Screens" §5.
- **Slot**: a heading and an event/day count passed into the partner events
  browser partial, alongside the existing `events` and `paginator` props.
- **Consequence today**: the partner page's events browser opens directly on
  the filter row, with no heading or count for the theme to style.

### 17. A "Show" select for All / Regular / One-off on partner show

- **Core**: `app/components/event_filter.rb` `render_repeating_group`; the
  repeating choice lives inside the combined "Filter and sort" dropdown
  (item 12), not as its own control.
- **Element**: `screens/05-partner-show-full.png` shows a standalone "Show"
  select (All / Regular / One-off) next to the "Pick a date" toggle on the
  partner page.
- **TD**: `README.md` "Screens" §5.
- **Slot**: the repeating filter exposed as its own facet, separate from the
  sort/period group, the same way neighbourhood already has its own filter.
- **Consequence today**: the repeating choice is reachable only through the
  combined filter dropdown, not as the standalone "Show" select the design
  draws.

### 18. A "Show 4 more days" append button on partner show

- **Core**: `app/components/event_filter.rb` day strip, and the partner
  events browser frame; both page by day tabs / a paginator link, not by
  appending more days to an existing list in place.
- **Element**: `screens/05-partner-show-full.png` shows a "Show 4 more days"
  button that grows the visible list without navigating away.
- **TD**: `README.md` "Interactions": "'Show more' appends."
- **Slot**: an append-mode pagination option for the partner events browser
  frame, returning additional days' events to insert rather than replace the
  frame.
- **Consequence today**: the partner page's Older-style paginator replaces
  the frame instead of appending to it; there is no "Show 4 more days"
  button to render.

### 19. Ordinal days in the news byline and article date

- **Core**: `config/locales/en.yml` `news.index.date_format` /
  `news.show.date_format`, passed straight to `strftime`; Ruby's `strftime`
  has no ordinal-day token (`%o` is not standard), so a locale override
  cannot produce "14th".
- **Element**: `README.md` "Screens" §6 shows a byline date like "14th
  January 2025".
- **TD**: `doc/core-slots-needed.md` item 2 already flagged the one-line
  byline; this is the ordinal suffix specifically. Core's `Components::Event`
  card supports an `%o` token for exactly this (see `event.rb`'s date
  formatting); the news views do not call through the same helper.
- **Slot**: route `news.index.date_format` / `news.show.date_format` through
  the same ordinal-aware formatter `Components::Event` uses, instead of a
  raw `strftime`.
- **Consequence today**: news and article dates render as "14 January 2025",
  without the ordinal suffix the design shows.

### 20. An image credit line on the article

- **Core**: `db/schema.rb` `articles`; there is no credit/caption column on
  `Article`, and `app/views/news/show.rb` `render_article_body` renders the
  image with no caption slot.
- **Element**: `screens/07-article-show-full.png` shows an italic credit
  line under the article's 16:9 image.
- **TD**: `README.md` "Screens" §7.
- **Slot**: an optional credit/caption field on `Article`, rendered under
  `article.article_image`.
- **Consequence today**: the article image renders with no credit line; the
  theme has no data to show one.

### 21. A pull quote on the article

- **Core**: `app/components/pull_quote.rb` exists as a standalone
  component, but `app/views/news/show.rb` never renders it, and `Article`
  has no field to hold pull-quote text or a paragraph index to pull it from.
- **Element**: `screens/07-article-show-full.png` shows an italic pull quote
  between pink quote marks after the third paragraph.
- **TD**: `README.md` "Screens" §7.
- **Slot**: a pull-quote field on `Article` (or a convention for marking one
  paragraph as the quote) and a call to `Components::PullQuote` from
  `Views::News::Show`.
- **Consequence today**: no pull quote renders; `Components::PullQuote`
  stays unused by the news view.

### 22. Previous / Next article links

- **Core**: `app/views/news/show.rb` `render_article_body`; the only
  navigation rendered is a single "Go back" link to the news index.
- **Element**: `screens/07-article-show-full.png` shows Previous / Go back /
  Next as a three-button row.
- **TD**: `README.md` "Screens" §7.
- **Slot**: `previous_article` / `next_article` props on
  `Views::News::Show`, ordered by `published_at`.
- **Consequence today**: only the "Go back" link exists; there is no
  adjacent-article data to link Previous or Next from.

### 23. "View more news" and "Recent news" buttons on the news index

- **Core**: `app/views/news/index.rb` `view_template`; the pagination
  paragraph renders only a single "Older" link when a further page exists.
- **Element**: `screens/06-news-index-full.png` shows three buttons: "Older
  news", "View more news" and "Recent news".
- **TD**: `README.md` "Screens" §6.
- **Slot**: additional named pagination actions ("view more" as a
  same-page append, "recent" as a jump back to the newest page) alongside
  the existing offset-based Older link.
- **Consequence today**: the news index renders only the Older link; the
  theme has no second or third pagination action to draw as separate
  buttons.

## Global (owner decision)

The newsletter sign-up column shown in the Final footer designs is
deliberately not built and not recorded as a slot gap. It is a content and
consent decision for the site owner, not something core's markup is missing.
