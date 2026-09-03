# Visual diff: partners index and partner page

Method as in home.md (1250px bands over `partners__wide.png`, `partners_150__wide.png`). Coordinator, 2026-09-03.

| Region | Page | Width(s) | Ours | Golden | Status | Category | Justification |
|---|---|---|---|---|---|---|---|
| Nav, band, wordmark, "Partners" title | index | 1250 | identical | | matches | | |
| Intro panel: large line plus smaller paragraph | index | 1250 | two paragraphs in one panel, top padding 80px, gap 55px | top padding 100px, gap 85px | fixed (within 20px) | | core WP 1.13 standfirst_detail |
| "ALL PARTNERS" heading above region buttons | index | 1250 | absent | present | differs | core slot | list heading on the partners index |
| Category and neighbourhood filters and rule | index | all | present | absent | differs | 4a deviation | "PlaceCal's category and neighbourhood filters" |
| List width | index | 1250 | x 99 to 1150 | x 99 to 1150 | fixed | | |
| Partner names bold italic, rows aligned | index | 1250 | | | fixed | | |
| Badge | index | all | neighbourhood name, purple pill | postcode district, navy pill | differs | core slot | badge text is the neighbourhood in core |
| Section name and title panel | partner | 1250 | "Partners" above a full-width panel | same | fixed | | |
| Body layout | partner | 1250 | PlaceCal two-column (text, image, map, opening times) | centred summary, contact and address columns | differs | 4a deviation | "PlaceCal layouts (map, opening times ...) styled to TD" |
| Contact block | partner | 1250 | stacked links, no icons | same | fixed | | |
| Upcoming events cards | partner | 1250 | numeral, month, title, time, postcode | same | matches | | |
