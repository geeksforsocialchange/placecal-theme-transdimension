# Visual diff: where the theme still differs from transdimension.uk

Two measuring passes have been run against the live Elm site. This file keeps what is
still useful from both: the deviations that remain open, with their category and the
reason. Everything the passes recorded as `fixed` or `matches` is in git history.

## Method

- **1250px band pass** (coordinator, 2026-09-03): headless Chrome captures of the theme
  at 1250px (4000px tall) and at a true 390px in an iframe harness, cut into 400px bands
  and stacked over the `goldens/2026-09-02/*.png` captures of the live site; geometry
  measured in px with ImageMagick column scans and computed styles read with a temporary
  in-page script.
- **Laptop pass** (WP 3.8): numbers measured with a DevTools-protocol script against
  `https://transdimension.uk` (golden) and the theme (ours) at 1440px, re-checked at 1250
  and 1728. Anything over 4px, or any font difference, was flagged. Part of the pass
  renders our pages with `rails runner` through an `ActionDispatch::Integration::Session`
  and measures the written HTML with the same script; landmarks measured both ways agree
  exactly, so the numbers are comparable with the live site's.

Categories: **core slot** (needs a change in core, recorded in `doc/core-slots-needed.md`),
**4a deviation** (PlaceCal functionality the brief keeps), **decision** (a deliberate
choice), **data** (dev fixtures differ from live content), **content** (our seeded copy
wraps differently), **capture** (an artefact of how the screenshot was taken).

## Home

| What | Ours | Golden | Category | Reason |
|---|---|---|---|---|
| Event card link | the title only | the whole card | decision | the homepage draws core's `Components::Event`, the card the listing page draws, and core puts the link on the title |
| Event card venue line | the place, or the street | postcode | decision | same card as the listing page, which prints the partner at the location or the first address line; the postcode option is the core slot recorded under Events |
| Event card time on the hour | "11pm" | "11:00pm" | decision | core's `fmt_time` drops a zero minute, as on the listing page |
| Event card organiser name | truncated at 25 characters | full | decision | core truncates the organiser link, as on the listing page |
| "View all events" button y | 2400 | 2430 | data | box height follows card count and title wrapping; 30px |
| News excerpt | markdown syntax visible ("##", "**") | plain text | core slot | core's `Article` summary does not strip markdown; PlaceCal's own news index shows the same |
| Footer dark band | 218px, two centred columns | 224px, three columns | decision | the "Register for updates" form was dropped; the two remaining columns are centred |
| Footer "Log in" link | small link under Powered by | absent | decision | kept so site admins can reach admin; easy to remove |

## Events

| What | Ours | Golden | Category | Reason |
|---|---|---|---|---|
| Nav current-page rule on an event page | no rule | rule under Events | core slot | `active_link_to` marks exact matches only; a section-aware `aria-current` on `/events/:id` needs core |
| "Filter and sort" toggle and the rule above the list | present | absent | 4a deviation | "Event filters: PlaceCal's period, neighbourhood, repeating and sort filters plus the region selector" |
| iCal and permalink links under the list | present | absent | 4a deviation | "PlaceCal layouts ... iCal, CSV" |
| Event card time range | start only | start to end | data | dev fixtures have no end time |
| Event card location line | street address | postcode | core slot | `Components::Event#render_place` prints the first address line; a postcode option is a core slot |
| Contact and address blocks on an event page | three columns, no icons, body type | two columns plus "By organiser" link | 4a deviation | "Partner and event pages: PlaceCal layouts (map, opening times, iCal, CSV, accessibility info) styled to TD" |
| "All events by X" / "All events" buttons under the box | absent | present | core slot | back links on the event page |
| Map on an event page | no tiles in the headless capture | tiles | capture | tiles need JS and network |
| Content box first child y | 638 | 622 | content | our filter block carries a 16px gutter the live site does not; chasing it moves the shared box inset every listing uses |
| Day strip width | 1084 | 1022 | content | ours runs the full inner width of the box; the button rows land in the same place |
| Region filter button height | 39 | 41 | content | 2px, under the threshold |
| Event card height | 160 | 182 | content | our seeded events carry one detail line fewer |
| "All events" heading | hidden | absent | decision | Events.elm has no heading here, and core's sat outside the content box; the `events.index.list_heading` override still reaches the DOM for screen readers. A visible heading would have to be inside the box, which is a core markup question |

## Partners

| What | Ours | Golden | Category | Reason |
|---|---|---|---|---|
| Category and neighbourhood filters and the rule | present | absent | 4a deviation | "PlaceCal's category and neighbourhood filters" |
| Partner badge | neighbourhood name, purple pill | postcode district, navy pill | core slot | badge text is the neighbourhood in core |
| Partner page body layout | PlaceCal two-column (text, image, map, opening times) | centred summary, contact and address columns | 4a deviation | "PlaceCal layouts (map, opening times ...) styled to TD" |
| "ALL PARTNERS" x at 1728 | 338 | 330 | content | the box inset changes at the 1500px breakpoint on both sites, by different amounts; under the threshold |
| Partner card heights | vary | fixed | content | seeded names and summaries |

## News

| What | Ours | Golden | Category | Reason |
|---|---|---|---|---|
| Card byline | partner line then date line | "Partner • 14th January 2025" on one line | core slot | core renders the partners and the date as separate elements, and prints a bare full stop a theme cannot select |
| Byline on the article page | two lines | one line | core slot | same slot as the card byline |
| Card excerpt | three clamped lines | three lines (about 130 characters) | core slot | core's `ArticlesHelper#article_summary_text` truncates at 200, so the clamped text ends mid-sentence rather than at a word boundary |
| "Read the rest" x | 638 | 654 | decision | on the live site the button's wrapper overflows the card and lands 16px right of centre; ours is centred, because reproducing the artefact would look like a mistake |
| Card height | varies with the title | 300 | content | every live title fits two lines; our seeded titles run to three |
| Article title panel height | 131 | 98 | content | title line counts differ; padding, measure and type match line for line |

## About, Get in touch and the show-page shell

| What | Ours | Golden | Category | Reason |
|---|---|---|---|---|
| About section headings | 636px measure, centred | 1116px, the box's full width | decision | the headings keep the measure and the sizes every static page uses; only the body copy moved to the wider two-column measure |
| About header art | generic band | About artwork, character bottom left | core slot | the `.page--about` band override is wired; the About header image still needs its own placement |
| Get in touch page title | "Get in touch" | "Join us" | decision | the get in touch page is used for now; the partner join form is #3456 |
| Get in touch form fields, placeholders, optional tags, boxed checkboxes | PlaceCal's | TD's | 4a deviation | "Join Us form: PlaceCal's Join fields" |
| Get in touch intro panel height | 261 | 238 | content | core gives the theme one key, so ours is a longer sentence that wraps to three lines in the same measure |
| Event title panel height | 114 | 163 | content | the live event title runs to two lines and ours to one |
| Footer middle band | two centred columns | three (social, credits, newsletter form) | decision | core's footer slot has no newsletter form (WP 2.9) |
| Footer total height | 746 | 730 | decision | our bottom band carries an admin-login line the live site has no equivalent for (about 33px) |
