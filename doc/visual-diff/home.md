# Visual diff: home page

Method: headless Chrome captures of http://transdimension.lvh.me:3031/ at 1250px (4000px tall) and at a true 390px (iframe harness), cut into 400px bands and stacked over `goldens/2026-09-02/home__wide.png` and `home__mobile.png`; geometry measured in px with ImageMagick column scans; computed styles checked with a temporary in-page script. Done by the coordinator on 2026-09-03.

The goldens themselves are gitignored and live only in a local working copy (recapture with `bash goldens/capture.sh`); these tables are the record.

Status: fixed = corrected in this pass; matches = no measurable difference; differs = remains, with a category (core slot, 4a deviation, data, capture, decision).

| Region | Width(s) | Ours | Golden | Status | Category | Justification |
|---|---|---|---|---|---|---|
| Nav bar height and link row | 1250 | 78px, links at y 30 to 44 | 78px, links at y 30 to 44 | matches | | |
| Nav current-page rule on Home | 1250 | dark rule under Home | no rule on the homepage | fixed | | PageHeader.elm draws no rule on Home; added `a[aria-current][href="/"]` override |
| Nav Donate button | all | absent | white Donate button, right | differs | decision | Dropped by Kim (2026-09-03) |
| Nav items | all | Home, Events, Partners, News, About, Get in touch | Home, Events, Partners, News, About | differs | 4a deviation | "Footer and nav: derived (D6) but rendering the same items in the same order"; Get in touch appears because the site has a contact email (D13); label chosen by Kim |
| Hero illustration position | 1250 | flag x 105, offset +45px | flag x 60 | fixed | | illustration band pseudo-elements now centred on the viewport (`left: 50%; translateX(-50%)`) instead of hand-tuned negative margins |
| Hero wordmark and strapline | 1250 | x 470 to 830, y 270 to 400 | same | matches | | |
| Intro panel | 1250 | x 210 to 1040, top y 844 | x 210 to 1040, top y 844 | matches | | |
| Intro copy and See what's on button | 1250 | identical text, button y 1250 | same | matches | | |
| Upcoming events box width | 1250 | x 146 to 1104 (958px) | x 97 to 1153 (1056px) | fixed | | an earlier `margin: 0 !important` pinned it to the container; now -3rem each side |
| Region buttons alignment | 1250 | left-aligned at x 155 | centred | fixed | | core `.region-filter` is `max-width: fit-content`; overridden to `none` |
| Region button labels | all | Everywhere, London, Manchester | same | matches | | via theme override of `region_filter.all` |
| Event cards: numeral, month, title rule, postcode, by organiser | 1250, 390 | 03 / SEP, italic title, pink rule, "by X" | 02 / SEP, same | matches | | day format and organiser prefix via theme overrides of core keys |
| Event card time | all | start time only (10:00am) | start to end (11:00pm to 3:30am) | differs | data | dev fixture events have no end time; core renders a range when `dtend` is set |
| Event card postcode line | all | postcode | postcode | matches | | |
| Illustrations around events and news (comet, planets, satellite, nebula) | 1250 | offset +48px | | fixed | | same viewport-centring fix as the hero |
| View all events button | 1250 | y 2400 | y 2430 | differs | data | box height follows card count and title wrapping; 30px |
| Latest news card | 1250 | image left 305px, title, meta, excerpt, Read the rest, View all news | same layout | matches | | |
| News excerpt shows raw markdown ("##", "**") | all | markdown syntax visible | plain text | differs | core slot | core `Article` summary does not strip markdown; PlaceCal's own news index shows the same; fix belongs in core (`app/views/news/index.rb` summary helper) |
| Footer pink band: wordmark and nav | 1250 | band 165px, links y 75, 18px gaps | same | fixed | | link size and gaps corrected; links vertically centred |
| Footer dark band | 1250 | 218px, two centred columns | 224px, three columns | differs | decision | Register for updates form dropped by Kim; 6px height difference from the missing form |
| Footer legal block spacing before Credits | 1250 | 76px | 51px | fixed | | block and title margins |
| Footer Log in link | all | small link under Powered by | absent | differs | decision | kept so site admins can reach admin; coordinator choice, easy to remove |
| Mobile nav toggle | 390 | pink hamburger icon | "Menu" text plus "+" | differs | core slot | `Components::Navigation` renders the label only when `@site.nil?` (doc/core-slots-needed.md item 9) |
| Mobile hero, panel, region buttons, cards, news, footer | 390 vs 450 golden | same composition; ours fits 390 with no overflow | golden rendered at 500px and clipped | matches | capture | headless Chrome cannot render below 500px, so the golden is a 500px render cropped to 450; ours is a true 390px render |
