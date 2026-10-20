# Handoff: The Trans Dimension → native PlaceCal theme (Final designs)

## Prompt for Claude Code

> You are working in `geeksforsocialchange/placecal-theme-transdimension` (a Rails/Tailwind theme for PlaceCal core). Implement the "Final" Trans Dimension designs described in this folder. The theme is CSS + Phlex components over PlaceCal core's markup (`app/tailwind/pages.css`, `app/components/transdimension/*.rb`). Where core's markup lacks a slot the design needs, record it in `doc/core-slots-needed.md` rather than faking it. Keep TD's breakpoints (600 / 900 / 1200 / 1500). Work screen by screen in the order below; after each, run the site locally and compare against `screens/*.png`.

## About the design files
Source files under `reference/` carry a `.txt` suffix (`Final.jsx.txt`, `Button.jsx.txt`) so the design-system compiler ignores them — read them as plain JSX/TS. `reference/ui_kit/index.html` is a copy for reading only; the runnable prototype lives in the design-system project.
Everything in `reference/` is an **HTML/React design reference**, not production code. Recreate the look and behaviour in the theme's existing environment (Tailwind CSS layers + Phlex components over core views). Do not port the React.

## Fidelity
**High-fidelity.** Colours, type, spacing, and grid are final and measured against the original 1366px Adobe XD artboards. Copy the numeric values below exactly (no 4/8px snapping).

## Sources of truth, in priority order
1. `screens/*.png` — the seven Final screens at 1440px.
2. `reference/ui_kit/Final.jsx.txt` (+ `Home.jsx.txt`, `data.jsx.txt`) — the page compositions, with every inline style value.
3. `reference/components/*` — component-level styles (Button, EventCard, NavBar, Footer, Select, DayStrip…).
4. `reference/tokens/*.css` — colour/type/spacing tokens; `reference/DESIGN_SYSTEM_README.md` — brand, tone, foundations.

## Design tokens
Colours: dark blue `#040f39` (ground), pink `#ff7aa7` (primary), light pink `#ffbcd3` (hover / muted), purple `#814470` (hover fill on dark), dark purple `#432955`, mauve `#7b4a6e` (badges, search field), light blue `#4fbdf5` (flash/info), white `#ffffff`.
Type: Covik Sans (Typekit `covik-sans`, weights 400/500/600/700/900). Body 16px/1.5. Italic 500 for titles. Allcaps labels: 700, 0.9rem, letter-spacing 1.9px.
Radius: 0.3rem everywhere. Rules: 1px pink. Boxes: dark blue with 1px pink border.
Buttons: 2px solid border, radius 0.3rem, 600 weight; `dark` = dark blue fill / pink border / white text; `pink` = pink fill / dark blue text; `white` = white fill; sizes md (1rem, 0.375rem 1.25rem 0.5rem) and sm (0.875rem, 0.2rem 0.9rem 0.3rem). Hover: 300ms colour transitions; dark→purple fill, pink→light pink.

## Grid & spacing (from the 1366 XD refs)
- Page: 1186px container, 24px gutters → 1138px column. Wordmark centred 56px from top (290px wide); listing page title 40px italic 500, 58px above / 26px below.
- Intro panel (pink): 46px 64px 50px padding; 34px italic 500 standfirst, line-height 44px, 838px measure.
- Content box: inset 28px 32px 52px; 2-col grids with 28px gutter (1 col < 900px).
- Event card: date column 70px + 10px gap; day 2.6rem/1, month 0.85rem 900 caps pink; title 1.25rem italic 500 with 2px pink underline, 8px padding-below, 10px margin-below; detail lines 1rem on a 28px line; 48px between rows (first row 0).
- Show-page pink panel: 26px 64px 34px padding; kicker link 0.8rem caps + 12px; name 2.1rem italic 500 / 1.3.
- Show-page box: 0 32px inset; rules 34px vertical; prose 20px/1.55 standfirst then 16px/1.65 in a 560px measure.
- Button rows below a box: 40px above, 28px gap, centred. Page bottom margin 160px before footer illustration.
- Footer: pink band 150px min-height, 28px 32px; middle band 24px 56px 28px; headings never wrap.

## Screens

### 1 Home (`screens/01-home.png`)
Unchanged from the live port except: hero panel 916px wide, 64/72/56 padding, title 2.5rem; "Featured events" box (inset 28px 32px 96px) with 4 events; "Latest update" white news card + "View more news" button.

### 2 Events index (`02-events-index.png`)
Nav: region segmented control (Everywhere / London / Manchester) in the bar + Donate. Intro panel copy: "Events & activities upcoming in {your area|region}."
Inside the box: two centred allcaps toggles **FILTER EVENTS +** and **PICK A DATE +** (pink +/−). Filter opens a 4-up row of selects (Neighbourhood, Category, Repeating, Sort) with 28px gap; date opens the date picker. Day strip (Today, Tomorrow, then 5 day names) with square pink ◀ ▶ buttons, 14px above / 40px below. Events in the 2-col card grid; neighbourhood lozenge (mauve fill, pink 0.72rem 700 text) right-aligned in the title row on the underline. Below the box: **Subscribe with iCal** and **Download as CSV** as small dark buttons (40px above, 28px gap, −80px page margin).
Map core to: `.filters__toggle` → FILTER EVENTS; `.day-strip` → strip; `.paginator__buttons` → the ◀ ▶; `.meta` → the two buttons.

### 3 Event show (`03-event-show.png`)
No starfield title. Pink panel: "← ALL EVENTS" kicker then the name as the only `h1`. Header stack (centred, 10px gaps): date "07 SEP 2026" 1.75rem 700 caps; pink meta line "11:00AM — 1:00PM · 2 HOURS · WEEKLY" 0.9rem 700 caps 1.9px; "By {organiser}" link. Rule. Description (20px then 16px, 636px measure, left). Rule. Two columns (max 700px, 28px gap): CONTACT INFORMATION; EVENT ADDRESS (online → "Online event hosted on Zoom" + pink Meeting link button). Full-bleed map 330px if in-person. Below box: Partner's events / Add to calendar / Go back (dark buttons). "Problem with this listing? Let us know." 0.8777rem centred.
Core: hide `.hero` on `Events::Show`; `.event--full .event__details` becomes the stack; no accessibility callout.

### 4 Partners index (`04-partners-index.png`)
Intro: one line only. Box (inset 28px 32px 0): filter row LOCATION [select] TYPE [select] … [mauve search field 220px]; "ALL PARTNERS" heading 40px above list; 2-col PartnerPreview list (italic name, neighbourhood lozenge — neighbourhood not postcode — pink underline, summary); full-bleed map 330px closing the box.

### 5 Partner show (`05-partner-show.png`)
Pink panel with "← ALL PARTNERS" kicker + name `h1` (no badges). Body grid 6fr / 5fr, 40px gap, 34px above: left — standfirst 20px, description 16px (560px), GET IN TOUCH and ADDRESS columns (Directions link), then Visit website (pink) / Email / Call (dark) small buttons; right — 3:2 image, map 220px (16px below image), OPENING TIMES list. Rule. **Event browser**: header row "UPCOMING PARTNER EVENTS  N events across M days" left; right: "Show" select (All / Regular / One-off) + PICK A DATE toggle. One continuous 2-col event list in date order (no day headings), cards without "By organiser". Button row 44px below: "Show 4 more days" (pink, sm) + Subscribe with iCal + Download as CSV (dark, sm). Below box: "Go back to all partners".
Core: partner `#events-browser` (no paginator) flattened to one grid; add `repeating` + date params to that frame; `.meta` → buttons.

### 6 News index (`06-news-index.png`)
Intro panel. White cards (max 800px, 44px above / 56px below): 3:2 image left, title 1.5rem italic 500 dark blue, partner 0.8777rem 700 • date, 3-line summary, "Read more" pink button. Older news / View more news / Recent news buttons.

### 7 Article show (`07-article-show.png`)
Dark box 48px 32px 56px: "← ALL NEWS" kicker (white, pink arrow), pink title 2.1rem italic, partner • date line, 16:9 image 636px + italic credit line, first paragraph 1.4rem then 16px prose 560px, pull quote after paragraph 3 (italic 1.6rem between pink quote marks). Previous / Go back / Next buttons.

## Interactions
Region selector filters events and partners site-wide (persist in session/URL). Filters and day strip drive Turbo frame reloads. Toggles: + becomes − when open; only one of Filter/Date open at a time. Hover: 300ms linear colour transitions; event card hover → title pink, underline white, month white. All pagination is server-side; "Show more" appends.

## Assets
Wordmark, illustrations and fonts are already in the theme. Partner/article images are placeholders in the reference.

## Files
- `screens/` — 7 above-the-fold JPEGs (`NN-name.png`) plus full-page PNGs (`NN-name-full.png`, 1161px wide) of every screen.
- `reference/ui_kit/` — React prototype (open `index.html` for the clickable version).
- `reference/components/` — component sources with exact style values.
- `reference/tokens/`, `reference/DESIGN_SYSTEM_README.md` — foundations.
