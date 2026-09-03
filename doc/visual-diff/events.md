# Visual diff: events index and event page

Method as in home.md (1250px bands over `events__wide.png`, `events_416614__wide.png`; measured in px). Coordinator, 2026-09-03.

| Region | Page | Width(s) | Ours | Golden | Status | Category | Justification |
|---|---|---|---|---|---|---|---|
| Nav, illustration band, strapline wordmark, "Events" title | index | 1250 | identical positions | | matches | | |
| Nav current-page rule on an event page | event | 1250 | no rule | rule under Events | differs | core slot | `active_link_to` marks exact matches only; a section-aware `aria-current` on `/events/:id` needs core |
| Intro panel | index | 1250 | x 50 to 1200, same copy and type | same | matches | | |
| Region buttons | index | 1250 | centred, same labels | same | matches | | |
| Day strip: seven day buttons on one row, "Future events" on its own row | index | 1250 | was 6 plus 2 wrapped, 140px buttons | 7 in a row, 130px, 14px gaps, then Past events / Future events | fixed | | button width, gap and last-item row; Past events dropped |
| Day strip labels | index | all | Sat 05 Sep | Sat 05 Sep | matches | | theme override of the date format key |
| Day button height and type | index | 1250 | 36px, 16.8px | 40px, 18px | differs | | bug, 4px; left as is this pass |
| "Filter and sort" toggle and rule above the list | index | all | present | absent | differs | 4a deviation | "Event filters: PlaceCal's period, neighbourhood, repeating and sort filters plus the region selector" |
| Event cards: numeral, month, italic title with pink rule, by organiser | index | 1250, 390 | 03 / SEP / by X | 02 / SEP / by X | matches | | |
| Event card time range | index | all | start only | start to end | differs | data | dev fixtures have no end time |
| Event card location line | index | all | street address | postcode | differs | core slot | `Components::Event#render_place` prints the first address line; a postcode option is a core slot |
| iCal and permalink links under the list | index | all | present | absent | differs | 4a deviation | "PlaceCal layouts ... iCal, CSV" |
| Section name above the title panel | event | 1250 | "Events" floating above the box | same | fixed | | core WP 1.15 `hero section:` plus theme override and CSS |
| Title panel | event | 1250 | full width of the box, flush | same | fixed | | |
| Date line | event | 1250 | 3RD SEPTEMBER 2026, bold caps | 2ND SEPTEMBER 2026 | fixed | | core WP 1.15 page date format with ordinal day |
| Time line | event | 1250 | 10AM pink | 8:00AM - 9:00AM pink | matches | data | dev event has no end time |
| Contact and address blocks | event | 1250 | three columns (contact, address, organiser), no icons, body-size type | two columns plus "By organiser" link | differs | 4a deviation | "Partner and event pages: PlaceCal layouts (map, opening times, iCal, CSV, accessibility info) styled to TD"; type size and icon removal fixed |
| Map | event | 1250 | pink ground, zoom controls, no tiles in headless capture | tiles | differs | capture | tiles need JS and network in the capture |
| "All events by X" and "All events" buttons under the box | event | 1250 | absent (core shows "Problem with this listing" and permalink) | present | differs | core slot | back links on the event page |
