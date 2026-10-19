# The Trans Dimension — Design System

**The Trans Dimension** (transdimension.uk) is an online community hub connecting trans communities in London and Manchester: news, events and services *by and for* trans people. It is a partnership of grassroots groups and charities, run by **Geeks for Social Change** (GFSC) with **Gendered Intelligence** (GI), originally funded by Comic Relief Tech for Good. Illustrations by Harry Woodgate, original site design by Squid, build by GFSC.

The product is moving from a standalone Elm site to a **native PlaceCal theme** (`placecal-theme-transdimension`, a Rails engine). This design system captures the TD visual language as it lands on PlaceCal, so new PlaceCal surfaces (partner pages, richer event pages, forms, more buttons, a rethought nav) can be designed in the same voice.

## Sources

- GitHub: https://github.com/geeksforsocialchange/placecal-theme-transdimension (main) — the theme's Tailwind CSS (`app/tailwind/*.css`), Phlex views/components, locale copy, `content/*.md`, and the illustration/logo assets. Every numeric value here is lifted from those files; the CSS comments cite the Elm originals (`Global.elm`, `PageTemplate.elm`, `Index.elm`…).
- Live site (being retired): https://transdimension.uk
- Staging PlaceCal build: https://trans-dimension.placecal-staging.org
- Original Adobe XD design refs (not machine-readable here; kept for humans with access):
  - https://xd.adobe.com/view/f1786926-b132-4a19-8e22-b9cf5dbe7362-a42b/
  - https://xd.adobe.com/view/21a46e92-cce4-4007-b7c6-a3ca9b7d93ee-74f7/
  - https://user-images.githubusercontent.com/861172/181239098-bd114395-1059-4c0b-8c07-03ad5c594da0.png
- **XD exports** `uploads/td-xd-exports/` (desktop 1366 + mobile 320 PNGs of every page, event/partner variations, UI elements) — the original Squid design; tighter than the live build and the primary reference for the Final screens. Notable XD-only elements adopted: collapsible "Filter events +", square pink day-strip arrows, pink accessibility callout, LOCATION/TYPE/Search filter row, mauve iCal subscribe band, light-blue info panel and flash banner, pull quotes, Older/View more/Recent and Previous/Go back/Next button rows. Not adopted: the per-event wheelchair roundel (PlaceCal has no per-event accessibility flag) and white news cards (kept dark with a pink border, as live). Rule of thumb: where the live site and XD differ, the live site wins unless a PlaceCal feature needs a new pattern.
- Review pack `uploads/td-design-review-lite/` — side-by-side 1440px and 450px captures (PlaceCal theme left, live Elm site right) of home, events, event, partners, partner, news, article, about, privacy, join.
- Upstream PlaceCal core: https://github.com/geeksforsocialchange/PlaceCal (the host the theme styles; explore for the markup TD dresses).

Readers with repo access should explore `app/tailwind/pages.css` in particular — it is the route-by-route spec.

## Products / surfaces

One product: the **Trans Dimension website on PlaceCal**. Pages: Home, Events (listing + day strip + region filter), Event, Partners (listing), Partner, News (listing), Article, About, Privacy, Join us / Get in touch, plus the shared header nav and three-band footer. There is also a PlaceCal admin, which TD does not theme.

## CONTENT FUNDAMENTALS

**Voice.** Warm, plain, first-person plural. "We" is the partnership; "you" is a trans person looking for somewhere to go. Never clinical, never corporate. Copy is honest about limits ("We're not here to play accessibility cop or judge and jury") and about ambition ("Always expanding.").

**Casing.** Sentence case for titles, buttons and headings ("See what's on", "View all events", "Read the rest", "Upcoming events & activities for you."). Small allcaps *labels* are a typographic style, not a casing rule — the source string is sentence case and CSS uppercases it (`UPCOMING EVENTS`, `FOLLOW US OUT THERE`, `CONTACT INFORMATION`).

**Punctuation.** Standfirsts end with a full stop even when they're fragments: "Updates & articles from our partners." Ampersands are used freely in headings ("Space & spaces for us", "events & activities"). Dates are ordinal and long on detail pages ("14th January 2025", "2nd September 2026") and compact on cards ("07 SEP" — zero-padded day over a three-letter month). Times use "4:30pm — 7:00pm" on the live site; PlaceCal prints "4:30pm–7pm".

**Bylines.** "Partner name • 14th January 2025" on one line, bold. Organisers on event cards are prefixed "by " ("by Geeks for Social Change").

**Buttons.** Verb-first, short, friendly: See what's on · View all events · View all news · Read the rest · Find out more · Go to all partners · Join us · Donate · Sign up · Submit.

**Region filter.** "Everywhere / London / Manchester" (not "All").

**Exclamation marks** appear in community-facing copy ("The Trans Dimension Launches!", "trying out new events can sometimes be daunting!") but never in UI chrome.

**No emoji, anywhere.** The playfulness comes from illustration, italics and pink.

**Strapline:** "Space & spaces for us." Site description: "The Trans Dimension is an online community hub connecting trans communities in London and Manchester. We collate news, events and services by and for trans people."

## VISUAL FOUNDATIONS

**Colour.** A three-colour brand: dark blue `#040F39` ground, hot pink `#FF7AA7` accent, white `#FFFFFF` copy. Light pink `#FFBCD3` is the hover for pink buttons; purple `#814470` is the hover fill for white and dark buttons; dark purple `#432955` is the badge ground and the third homepage background. Pink is the *only* rule/border colour on the whole site. Copy on pink panels is dark blue; copy on the ground is white; small labels and section headings inside boxes are pink. Two XD-only supporting colours: **mauve `#7B4A6E`** (badges, search field, subscribe band) and **light blue `#4FBDF5`** ("Need help?" panel, maintenance flash banner). Illustration accents (yellow, teal, orange) never enter the UI.

**Type.** One family: **Covik Sans** (Adobe Fonts kit `qwi3qrw`; no local files — see Caveats). Body 400 at 16px root (PlaceCal core's 18px is overridden). Weights: body 400, intro/standfirst 500, buttons and nav 600, bold and allcaps labels 700, event-day numeral 900 → month, 400 → day. **Italic is the display voice**: page titles, standfirsts, event/partner/news titles and pull-quotes are all italic 500 (or 400 for news titles). Allcaps labels track at `1.9px`. Titles: 2.1rem → 2.5rem (600px) → 3.1rem (900px), line-height 1.5 (not tight). Standfirst 1.6 → 1.9 → 2.5rem. Section subtitle on the homepage 2.1 → 3.2rem italic. Odd values (0.8777rem, 1.877rem, 3.1222rem) are the Elm site's; keep them.

**Grid (from the 1366 XD refs).** Page column 1138px (114px margins) inside a 1186px container with 24px gutters; content boxes inset 32px; two-column event/partner grid with a 28px gutter; event date column 70px + 10px; detail lines 28px leading; 48px between event rows; intro panel 46–56px vertical padding with a 34px italic standfirst; page title 40px with 58px above / 26px below; homepage panels 916px wide; prose 560px; iCal band 20px under the box, ~50px tall; footer pink band 150px.

**Spacing.** Rem-based, no 4px grid. Buttons `0.375rem 1.25rem 0.5rem`. Content boxes inset `0.75rem` mobile / `2rem` tablet / `1.5rem` at ≥1500px. Sections have big vertical breathing room (150–250px) to give illustrations space. Page column max 1150px; intro/news panels 982px; events box 1182px; prose measure 636px; standfirst measure 838px.

**Backgrounds.** The whole site sits on a **tiling starfield PNG** (800px tile on mobile, 1080px from 900px) over dark blue, edge to edge. No gradients. No photography as background. Pink panels are flat fills.

**Illustration.** Harry Woodgate's hand-drawn space objects (planets, rocket, hourglass, clock, constellations, book, spiral galaxy, comet, satellite) and five trans/non-binary characters. Illustrations are painted as full-viewport-wide PNG bands *behind* content (`z-index:-1`, decorative, not in the a11y tree): a header band behind the wordmark and title on every inner page, a footer band (rocket, planet, nebula) under the content box, and on the homepage three bands between sections. The About page has its own header (character + galaxy). Artwork is delivered at 320/768/1024/1366/1920px widths.

**Corner radius.** `0.3rem` on every box, button, input, badge and image. **TD has no pills.** News cards use `0.2rem`.

**Borders.** Boxes: `1px solid pink`. Inputs: `2px solid pink`. Buttons: `0.2rem solid` (same colour as fill, or pink on dark). Card title underline: `2px solid pink`, turning white on hover. `hr`: `0.5px pink`.

**Shadows.** None on UI. Flat everywhere. (Map markers carry `0 2px 6px rgba(0,0,0,.25)`.)

**Cards.** Dark blue fill, 1px pink border, 0.3rem radius, no shadow. Event cards inside a box are *borderless*: a date stack (big white day, small pink allcaps month) beside an italic title underlined in pink, then 0.8777rem/1.2rem detail lines. News cards are individual bordered boxes with image left, italic title, bold byline, 3-line clamped summary and a pink button hanging on the bottom edge.

**Floating elements.** Small allcaps section titles hang 3rem *above* a box; buttons hang 2rem *below* it, straddling the border. This "floating title / floating button" pattern is the homepage's signature.

**Panels.** Intro panels are flat pink with dark blue italic copy, centred, sitting flush on top of the content box (no gap, shared border). Show pages put the item name in the same pink panel at the top of the box.

**Hover.** Colour only, 300ms (buttons/nav) or 500ms linear (links, card titles). Links: white → pink, underline pink → white. White button → purple fill with white text. Pink button → light pink. Dark button → purple with white border. Nav link: dark blue → white (mobile), underline dark blue (desktop). Event card: title pink, underline white, month white. Only under `(hover:hover) and (pointer:fine)`.

**Press/focus.** Inversion: white button → dark blue fill/white text; pink → white fill; dark → pink fill/dark text. No shrink, no shadow.

**Layout rules.** Nav is a full-width flat pink bar (desktop) with links packed left and a white Donate button at the far right; mobile shows the small wordmark left and a "Menu +" toggle right, menu items as stacked pink blocks. Footer is three full-width bands: pink (wordmark + links) / dark (social + created-by [+ newsletter]) / pink (legal, credits, Powered by PlaceCal). Nothing is fixed/sticky.

**Transparency & blur.** None. The one alpha value is a 15% white overlay token and the 35% pink focus ring.

**Imagery.** Photography appears only as article/partner images: full-colour, warm, community photos, rounded 0.3rem, `object-fit: cover`, 303×202 aspect on news cards. No filters or grain.

**Maps.** Pink-tinted OpenFreeMap style (pink ground, dark blue roads, white marker), flush to the box edges with the box radius.

**Iconography.** See ICONOGRAPHY.

**Motion.** No entrance animations, no bounces, no parallax. Just colour transitions.

## ICONOGRAPHY

- **No icon font, no icon system** on the Elm site. The only icons are three **social glyphs as SVG files** (Instagram, Twitter, Facebook — `assets/icons/`), 40×40 in pink, in the footer.
- The event-detail icons that appear on PlaceCal's event page (calendar, clock, hourglass, repeat, pin, phone, email, globe, Facebook, Twitter) are **PlaceCal core's inline SVGs**, coloured TD pink via `currentColor`. They are not in the theme repo; when you need them, use PlaceCal core's set or a plain-stroke CDN set (Lucide, 2px stroke) as a stand-in and flag it.
- **Unicode as icon:** the footer separates the two maker logos with a literal `+` (2rem white); the news byline uses `•`; markdown bullets are `■` (U+25A0) in pink; the mobile menu toggle is a pink `+`.
- **Logos** (`assets/logos/`): TD wordmark with strapline (pink, for dark ground), TD wordmark for the footer (dark blue, for pink ground), small header wordmark, GFSC roundel + wordmark (pink), Gendered Intelligence wordmark (pink), "Powered by PlaceCal" lockup (dark blue). Favicon mark and Safari pinned-tab SVG in `assets/brand/`.
- **No emoji.**

## Intentional additions

- `Badge` — the neighbourhood/postcode tag on partner previews exists in the source CSS but not as a named element; exposed as a component so kits can reuse it.
- `Wordmark` — a thin wrapper choosing the right logo file for the ground it sits on.
- `Icon` — Lucide glyphs masked pink, standing in for PlaceCal core's inline SVG detail icons until those are copied in.
- `Select`, `Pagination`, `MetaLinks`, `AccessibilityInfo` — TD-styled versions of PlaceCal core features (listing filters, news paging, iCal/CSV links, venue accessibility) the Elm site never had; needed for the consolidated PlaceCal frontend.

## Index

- `styles.css` — imports everything in `tokens/` (fonts, colors, typography, spacing, effects, base).
- `tokens/` — `fonts.css` (Typekit + fallback), `colors.css`, `typography.css`, `spacing.css`, `effects.css`, `base.css` (body ground, links).
- `assets/` — `logos/`, `icons/` (social SVGs), `backgrounds/` (starfield tiles), `illustrations/1366px|320px/` (Harry Woodgate bands), `brand/` (favicon, OG share image).
- `guidelines/` — foundation specimen cards (Colors, Type, Spacing, Brand, Illustration).
- `components/core/` — Button, IntroPanel, ContentBox, PageTitle, FloatingTitle, SectionHeading, Badge, Wordmark, Icon, Callout, FlashMessage, PullQuote.
- `components/navigation/` — NavBar, Footer, RegionFilter, DayStrip, FilterToggle, DatePicker, Pagination.
- `components/listings/` — EventCard, NewsCard, PartnerPreview, OpeningTimes, MetaLinks, AccessibilityInfo, SubscribeBand, EmptyState.
- `components/forms/` — TextField, TextArea, Checkbox, FormField, Select, SearchInput.
- `ui_kits/transdimension/` — the site: Home, Events, Event, Partners, Partner, News, Article, About, Join (hash-routed, interactive).
- `github.md` — upstream repo association and sync record.
- `SKILL.md` — agent skill entry point.

## Caveats

- Covik Sans is self-hosted from `assets/fonts/` (licensed files supplied by the site owner; 400–700 roman + italic, 800 italic, 900 roman). Use only for Trans Dimension work.
- Illustrations are copyright Gendered Intelligence; use only for Trans Dimension work.
- The XD links could not be read by machine; the design here is grounded in the theme CSS and live-site captures.
